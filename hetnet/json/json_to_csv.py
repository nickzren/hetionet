import json
import csv
import os
import logging
import bz2

logging.basicConfig(level=logging.INFO)

DATA_DIR = 'csv/data'
CYPHER_DIR = 'csv/cypher'
JSON_FILE = 'hetionet-v1.0.json.bz2'
META_JSON_FILE = 'hetionet-v1.0-metagraph.json'

def create_directories():
    for dir_name in [DATA_DIR, CYPHER_DIR]:
        os.makedirs(dir_name, exist_ok=True)

def determine_type(value):
    type_map = {
        bool: 'toBoolean',
        int: 'toInteger',
        float: 'toFloat',
        list: 'toArray',
    }
    return type_map.get(type(value), 'toString')

def load_json(filename):
    if filename.endswith('.bz2'):
        with bz2.open(filename, 'rt', encoding='utf-8') as f:
            return json.load(f)
    else:
        with open(filename, 'r') as f:
            return json.load(f)

def initialize_csv_writer(filename, fieldnames):
    csv_file = open(f'{DATA_DIR}/{filename}', 'w', newline='')
    csv_writer = csv.DictWriter(csv_file, fieldnames=fieldnames)
    csv_writer.writeheader()
    logging.info(f"Created node file: {filename}")
    return csv_file, csv_writer

def initialize_cypher_file(label, filename, set_statements):
    cypher_file = open(f'{CYPHER_DIR}/{filename.replace(".csv", "")}.cypher', 'w')
    cypher_file.write(f"CREATE INDEX identifier_index_{label} FOR (n:{label}) ON (n.identifier);\n")
    cypher_file.write(f"LOAD CSV WITH HEADERS FROM 'file:///{filename}' AS row\n")
    cypher_file.write(f"CREATE (n:{label}) SET {', '.join(set_statements)};\n")
    logging.info(f"Created cypher file: {filename.replace('.csv', '')}.cypher")
    return cypher_file

def update_csv_and_cypher_files(label, filename, node, csv_writer, csv_file, cypher_file, set_statements):
    new_fields = set(node['data'].keys()) - set(csv_writer.fieldnames)
    if new_fields:
        csv_writer.fieldnames.extend(new_fields)
        csv_writer.fieldnames = sorted(csv_writer.fieldnames)
        csv_file.seek(0)
        csv_file.truncate()
        csv_writer.writeheader()

        cypher_file.seek(0)
        cypher_file.truncate()
        cypher_file.write(f"CREATE INDEX identifier_index_{label} FOR (n:{label}) ON (n.identifier);\n")
        cypher_file.write(f"LOAD CSV WITH HEADERS FROM 'file:///{filename}' AS row\n")

        for new_field in new_fields:
            data_type = determine_type(node['data'][new_field])
            if data_type == 'toArray':
                set_statements.append(f"r.{new_field} = split(replace(replace(replace(row.{new_field}, '[', ''), ']', ''), \"'\", ''), ',')")
            else:
                set_statements.append(f"n.{new_field} = {data_type}(row.{new_field})")

        sorted_set_statements = sorted(set_statements)
        cypher_file.write(f"CREATE (n:{label}) SET {', '.join(sorted_set_statements)};\n")

def write_csv_row(node, csv_writer):
    row = {'identifier': node['identifier'], 'name': node['name']}
    row.update(node['data'])
    csv_writer.writerow(row)

def close_files(files):
    for file in files.values():
        file.close()

def process_nodes(nodes):
    node_files = {}
    node_writers = {}
    node_cypher_files = {}
    node_set_statements_dict = {}

    for node in nodes:
        label = node['kind'].replace(" ", "")
        filename = f"node_{label}.csv"
        if filename not in node_files:
            node_files[filename], node_writers[filename] = initialize_csv_writer(filename, ['identifier', 'name'])
            node_set_statements_dict[filename] = [f"n.identifier = {determine_type(node['identifier'])}(row.identifier)", "n.name = row.name"]
            node_cypher_files[filename] = initialize_cypher_file(label, filename, node_set_statements_dict[filename])

        update_csv_and_cypher_files(label, filename, node, node_writers[filename], node_files[filename], node_cypher_files[filename], node_set_statements_dict[filename])
        write_csv_row(node, node_writers[filename])

    close_files(node_files)
    close_files(node_cypher_files)

def initialize_edge_files(filename, source_label):
    fieldnames = ['source_id', 'target_id']
    edge_file, edge_writer = initialize_csv_writer(filename, fieldnames)
    edge_set_statements = []
    edge_cypher_file = initialize_cypher_file(source_label, filename, edge_set_statements)
    logging.info(f"Created edge file: {filename}")
    return edge_file, edge_writer, edge_cypher_file, edge_set_statements

def update_edge_files_and_cypher_files(filename, edge, edge_writer, edge_file, edge_cypher_file, edge_set_statements, source_label, target_label, rel_type_formatted):
    new_fields = set(edge['data'].keys()) - set(edge_writer.fieldnames)
    if new_fields:
        edge_writer.fieldnames.extend(new_fields)
        edge_writer.fieldnames = sorted(edge_writer.fieldnames)
        edge_file.seek(0)
        edge_file.truncate()
        edge_writer.writeheader()

        edge_cypher_file.seek(0)
        edge_cypher_file.truncate()

        # Separate MATCH clauses to avoid Cartesian products
        edge_cypher_file.write(f"LOAD CSV WITH HEADERS FROM 'file:///{filename}' AS row\n")
        edge_cypher_file.write(f"MATCH (a:{source_label} {{identifier: {determine_type(edge['source_id'][1])}(row.source_id)}})\n")
        edge_cypher_file.write(f"MATCH (b:{target_label} {{identifier: {determine_type(edge['target_id'][1])}(row.target_id)}})\n")
        edge_cypher_file.write(f"CREATE (a)-[r:{rel_type_formatted}]->(b)\n")

        for new_field in new_fields:
            data_type = determine_type(edge['data'][new_field])
            if data_type == 'toArray':
                edge_set_statements.append(f"r.{new_field} = split(replace(replace(replace(row.{new_field}, '[', ''), ']', ''), \"'\", ''), ',')")
            else:
                edge_set_statements.append(f"r.{new_field} = {data_type}(row.{new_field})")

        sorted_set_statements = sorted(edge_set_statements)
        edge_cypher_file.write("SET ")
        edge_cypher_file.write(",\n ".join(sorted_set_statements))
        edge_cypher_file.write(";\n")

def write_edge_row(edge, edge_writer):
    row = {'source_id': edge['source_id'][1], 'target_id': edge['target_id'][1]}
    row.update(edge['data'])
    edge_writer.writerow(row)

def process_edges(edges, kind_to_abbrev):
    edge_files = {}
    edge_writers = {}
    edge_cypher_files = {}
    edge_set_statements_dict = {}

    for edge in edges:
        source_label = edge['source_id'][0].replace(" ", "")
        target_label = edge['target_id'][0].replace(" ", "")
        rel_type = edge['kind'].replace(" ", "")
        filename = f"edge_{source_label}_{rel_type}_{target_label}.csv"
        source_abbrev = kind_to_abbrev.get(source_label, source_label)
        target_abbrev = kind_to_abbrev.get(target_label, target_label)
        rel_type_abbrev = kind_to_abbrev.get(rel_type, rel_type)
        rel_type_formatted = f"{rel_type.upper()}_{source_abbrev}{rel_type_abbrev}{target_abbrev}"

        if filename not in edge_files:
            edge_files[filename], edge_writers[filename], edge_cypher_files[filename], edge_set_statements_dict[filename] = initialize_edge_files(filename, source_label)

        update_edge_files_and_cypher_files(filename, edge, edge_writers[filename], edge_files[filename], edge_cypher_files[filename], edge_set_statements_dict[filename], source_label, target_label, rel_type_formatted)
        write_edge_row(edge, edge_writers[filename])

    close_files(edge_files)
    close_files(edge_cypher_files)

if __name__ == "__main__":
    create_directories()

    data = load_json(JSON_FILE)
    meta_data = load_json(META_JSON_FILE)
    kind_to_abbrev = {key.replace(" ", ""): value for key, value in meta_data['kind_to_abbrev'].items()}

    nodes = data['nodes']
    edges = data['edges']

    process_nodes(nodes)
    process_edges(edges, kind_to_abbrev)
