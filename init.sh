#!/bin/bash

# Stop and remove containers, networks, volumes, and images created by `up`.
docker compose down

echo "Starting Neo4j service with Docker Compose..."
docker compose up -d

echo "Waiting for Neo4j to be ready..."
until $(curl --output /dev/null --silent --head --fail http://localhost:7474); do
    printf '.'
    sleep 5
done
echo "Neo4j is ready."

# Copy Hetionet data files into the container
docker cp hetnet/csv/data/. hetionet:/var/lib/neo4j/import/
docker cp hetnet/csv/cypher/. hetionet:/var/lib/neo4j/import/
docker cp hetnet/csv/load_to_neo4j.py hetionet:/var/lib/neo4j/import/

# Unzip the .csv.gz files directly inside the Neo4j container
docker exec -it hetionet bash -c "gunzip -f /var/lib/neo4j/import/*.csv.gz"

# Execute the data loading script
docker exec -it hetionet bash -c "python3 /var/lib/neo4j/import/load_to_neo4j.py"

echo "Hetionet deployment and data loading complete."