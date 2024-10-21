#!/bin/bash

# Start Neo4j in the background
neo4j start

# Wait for Neo4j to be ready
echo "Waiting for Neo4j to start..."
until curl -s http://localhost:7474 > /dev/null; do
  sleep 5
done
echo "Neo4j is ready."

# Run the data loading script
python3 /var/lib/neo4j/scripts/load_to_neo4j.py

# Stop Neo4j after data loading is done
neo4j stop

# Start Neo4j in the foreground
exec neo4j console