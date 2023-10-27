import os
from neo4j import GraphDatabase
import glob
import logging

logging.basicConfig(level=logging.INFO)

def get_env_variable(var_name):
    try:
        return os.environ[var_name]
    except KeyError:
        error_msg = f"Environment variable {var_name} not set."
        logging.error(error_msg)
        raise Exception(error_msg)

def execute_single_query(session, query):
    try:
        session.run(query)
    except Exception as e:
        logging.error(f"Failed to execute query: {query}. Error: {e}")

def execute_cypher_file(session, cypher_file):
    with open(cypher_file, 'r') as f:
        content = f.read()
        queries = content.split(';')
        for query in queries:
            query = query.strip()
            if query:
                execute_single_query(session, query)
    logging.info(f"Loaded {cypher_file}")

def execute_cypher_files(driver, cypher_files, label, database_name):
    logging.info(f"Starting to load {label} into {database_name}...")
    with driver.session(database=database_name) as session:
        for cypher_file in cypher_files:
            execute_cypher_file(session, cypher_file)
    logging.info(f"Finished loading {label} into {database_name}.")

def main():
    DB_URL = get_env_variable("DB_URL")
    DB_USERNAME = get_env_variable("DB_USERNAME")
    DB_PASSWORD = get_env_variable("DB_PASSWORD")
    DB_NAME = get_env_variable("DB_NAME")

    driver = GraphDatabase.driver(DB_URL, auth=(DB_USERNAME, DB_PASSWORD))

    node_cypher_files = glob.glob("cypher/node_*.cypher")
    execute_cypher_files(driver, node_cypher_files, "nodes", DB_NAME)

    edge_cypher_files = glob.glob("cypher/edge_*.cypher")
    execute_cypher_files(driver, edge_cypher_files, "edges", DB_NAME)

if __name__ == "__main__":
    main()
