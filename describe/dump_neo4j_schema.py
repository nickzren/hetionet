import os
import argparse
import json
from neo4j import GraphDatabase

def get_env_variable(var_name, default_value=None):
    try:
        return os.environ[var_name]
    except KeyError:
        if default_value is not None:
            return default_value
        raise Exception(f"Environment variable {var_name} not set.")

def main():
    parser = argparse.ArgumentParser(description='Dump Neo4j schema.')
    parser.add_argument('--output_dir', type=str, required=True, help='Output directory path')
    args = parser.parse_args()

    # Get DB connection details from environment variables, with default fallback
    uri = get_env_variable('DB_URL', 'bolt://localhost:7687')
    db_name = get_env_variable('DB_NAME', 'hetionet')

    # Ensure output directory exists
    os.makedirs(args.output_dir, exist_ok=True)

    # Connect to the Neo4j database without authentication (no username or password)
    driver = GraphDatabase.driver(uri, auth=None)
    
    with driver.session(database=db_name) as session:
        node_schema = get_node_schema(session)
        rel_schema = get_relationship_schema(session)

    # Combine node and relationship schemas
    combined_schema = {
        "NodeTypes": node_schema,
        "RelationshipTypes": rel_schema
    }

    # Write the schema to a JSON file in the output directory
    combined_schema_path = os.path.join(args.output_dir, 'hetionet_neo4j_schema.json')

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
        property_types_str = ", ".join(property_types) if property_types else "Unknown"
        if node_type not in schema:
            schema[node_type] = {}
        schema[node_type][property_name] = property_types_str
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
        property_name = record["propertyName"]
        property_types = record["propertyTypes"]
        if rel_type not in schema:
            schema[rel_type] = {}
        if property_name:
            schema[rel_type][property_name] = ", ".join(property_types) if property_types else "Unknown"
    return schema

def infer_source_target_nodes(rel_type):
    # This function assumes a naming convention where relType is of the form SourceType_relType_TargetType
    parts = rel_type.split('_')
    if len(parts) < 3:
        return "Unknown", "Unknown"
    source_node = parts[0]
    target_node = parts[-1]
    return source_node, target_node

if __name__ == "__main__":
    main()