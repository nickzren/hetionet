#!/usr/bin/env python3
"""
Export Neo4j schema (node labels, relationship types, properties **and**
explicit endpoint labels for every relationship) to `neo4j_schema.json`.

Usage
-----
python export_neo4j_schema.py --output_dir data/input
"""

import os
import argparse
import json
from pathlib import Path
from neo4j import GraphDatabase


# ------------------------------------------------------------------ #
#  Small helper: env var fetch with clear error
# ------------------------------------------------------------------ #
def get_env_variable(key: str) -> str:
    value = os.getenv(key)
    if not value:
        raise EnvironmentError(f"Environment variable {key!r} is not set.")
    return value


# ------------------------------------------------------------------ #
#  Main
# ------------------------------------------------------------------ #
def main():
    parser = argparse.ArgumentParser(description="Export Neo4j schema.")
    parser.add_argument(
        "--output_dir", required=True, help="Directory to write neo4j_schema.json"
    )
    args = parser.parse_args()

    uri     = get_env_variable("DB_URL")
    db_name = get_env_variable("DB_NAME")

    out_dir = Path(args.output_dir).expanduser().resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    # ---- auth (adjust if DB requires username/password) -------------
    driver = GraphDatabase.driver(uri, auth=None)

    with driver.session(database=db_name) as session:
        node_schema = get_node_schema(session)
        rel_schema  = get_relationship_schema(session)

    schema = {"NodeTypes": node_schema, "RelationshipTypes": rel_schema}
    out_path = out_dir / "neo4j_schema.json"
    out_path.write_text(json.dumps(schema, indent=2))
    print(f"Schema exported → {out_path}")


# ------------------------------------------------------------------ #
#  Helpers: collect node + relationship metadata
# ------------------------------------------------------------------ #
def get_node_schema(session):
    q = """
    CALL db.schema.nodeTypeProperties()
    YIELD nodeType, propertyName, propertyTypes
    RETURN nodeType, propertyName, propertyTypes
    """
    schema = {}
    for rec in session.run(q):
        label = rec["nodeType"].strip(":`")
        prop  = rec["propertyName"]
        types = ", ".join(rec["propertyTypes"]) or "Unknown"
        schema.setdefault(label, {})[prop] = types
    return schema


def get_relationship_schema(session):
    """
    Build a map for each relType:
      { property: type, ... , "_endpoints": [srcLabel, tgtLabel] }
    """
    # 1) gather property definitions
    q_props = """
    CALL db.schema.relTypeProperties()
    YIELD relType, propertyName, propertyTypes
    RETURN relType, propertyName, propertyTypes
    """
    rel_schema = {}
    for rec in session.run(q_props):
        rtype = rec["relType"].strip(":`")
        prop  = rec["propertyName"]
        if prop:
            types = ", ".join(rec["propertyTypes"]) or "Unknown"
            rel_schema.setdefault(rtype, {})[prop] = types

    # 2) sample one relationship for endpoints
    for rtype in rel_schema:
        q_sample = f"""
        MATCH (s)-[r:`{rtype}`]->(t)
        WITH labels(s)[0] AS src, labels(t)[0] AS tgt
        RETURN src, tgt LIMIT 1
        """
        rec = session.run(q_sample).single()
        if rec:
            rel_schema[rtype]["_endpoints"] = [rec["src"], rec["tgt"]]
        else:
            rel_schema[rtype]["_endpoints"] = ["Unknown", "Unknown"]

    return rel_schema


# ------------------------------------------------------------------ #
if __name__ == "__main__":
    main()