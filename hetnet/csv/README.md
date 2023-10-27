# Hetionet CSV format

The purpose is to load Hetionet CSV data into a Neo4j database. The script performs the necessary operations to import this data into Neo4j for graph-based querying and analysis.

### Files

The `data` directory contains all compressed CSV files, which include both node and edge data.

The `cypher` directory houses all the Cypher scripts responsible for node creation, index generation, and edge establishment.

### Pre-requisites

#### 1. Decompress the Data:
```
gunzip data/*
```

#### 2. Move CSV Files:
Transfer all CSV files from current `data` directory into your Neo4j `import` directory.

#### 3. Install Neo4j Python Module:
```
pip install neo4j
```

#### 4. Environment Setup:
```
export DB_URL="YOUR_URL"
export DB_USERNAME="YOUR_USERNAME"
export DB_PASSWORD="YOUR_PASSWORD"
export DB_NAME="YOUR_DB_NAME"
```

### Execution

Run the script:
```
python load_to_neo4j.py
```


