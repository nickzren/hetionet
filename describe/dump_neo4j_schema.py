import os
import argparse
import json
from neo4j import GraphDatabase

def get_env_variable(key: str) -> str:
    value = os.getenv(key)
    if not value:
        raise EnvironmentError(f"Environment variable {key!r} is not set.")
    return value

def main():
    parser = argparse.ArgumentParser(description='Dump Neo4j schema.')
    parser.add_argument('--output_dir', type=str, required=True, help='Output directory path')
    args = parser.parse_args()

    uri = get_env_variable('DB_URL')
    db_name = get_env_variable('DB_NAME')

    os.makedirs(args.output_dir, exist_ok=True)

    driver = GraphDatabase.driver(uri, auth=None)

    # Pass the database name here:
    with driver.session(database=db_name) as session:
        node_schema = get_node_schema(session)
        rel_schema = get_relationship_schema(session)

    combined_schema = {
        "NodeTypes": node_schema,
        "RelationshipTypes": rel_schema
    }

    combined_schema_path = os.path.join(args.output_dir, 'neo4j_schema.json')
    with open(combined_schema_path, 'w') as schema_file:
        json.dump(combined_schema, schema_file, indent=4)

    print("Schema dumped successfully.")

def get_node_schema(session):
    query = """
    CALL db.schema.nodeTypeProperties()
    YIELD nodeType, propertyName, propertyTypes
    RETURN nodeType, propertyName, propertyTypes
    """
    result = session.run(query)
    schema = {}
    for record in result:
        node_type = record["nodeType"].strip(":`")
        property_name = record["propertyName"]
        property_types = record["propertyTypes"]
        types_str = ", ".join(property_types) if property_types else "Unknown"
        schema.setdefault(node_type, {})[property_name] = types_str
    return schema

def get_relationship_schema(session):
    query = """
    CALL db.schema.relTypeProperties()
    YIELD relType, propertyName, propertyTypes
    RETURN relType, propertyName, propertyTypes
    """
    result = session.run(query)
    schema = {}
    for record in result:
        rel_type = record["relType"].strip(":`")
        prop = record["propertyName"]
        types = record["propertyTypes"]
        if prop:
            schema.setdefault(rel_type, {})[prop] = ", ".join(types) if types else "Unknown"
    return schema

def infer_source_target_nodes(rel_type):
    parts = rel_type.split('_')
    if len(parts) < 3:
        return "Unknown", "Unknown"
    return parts[0], parts[-1]

if __name__ == "__main__":
    main()