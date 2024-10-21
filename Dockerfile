# Use the official Neo4j image as the base
FROM neo4j:5.17

# Set environment variables for Neo4j
ENV NEO4J_AUTH=none \
    NEO4J_dbms_default__database=hetionet \
    NEO4J_dbms_memory_heap_initial__size=1G \
    NEO4J_dbms_memory_heap_max__size=2G \
    NEO4JLABS_PLUGINS='["apoc", "graph-data-science"]'

# Create necessary directories inside the container
RUN mkdir -p /var/lib/neo4j/import /var/lib/neo4j/scripts

# Copy data, Cypher files, and scripts into the container
COPY hetnet/csv/data /var/lib/neo4j/import/data
COPY hetnet/csv/cypher /var/lib/neo4j/import/cypher
COPY hetnet/csv/load_to_neo4j.py /var/lib/neo4j/scripts/load_to_neo4j.py
COPY entrypoint.sh /var/lib/neo4j/scripts/entrypoint.sh

# Install git to use git commands for cleanup
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Unzip the .csv.gz files in the /var/lib/neo4j/import/data directory, forcing overwrite
RUN gunzip -f /var/lib/neo4j/import/data/*.csv.gz

# Modify neo4j.conf to set bolt.listen_address and disable auth
RUN echo "dbms.connector.bolt.listen_address=0.0.0.0:7687" >> /var/lib/neo4j/conf/neo4j.conf && \
    echo "dbms.security.auth_enabled=false" >> /var/lib/neo4j/conf/neo4j.conf

# Set permissions on entrypoint script and make it executable
RUN chmod +x /var/lib/neo4j/scripts/entrypoint.sh

# Expose the Neo4j Bolt and HTTP ports
EXPOSE 7474 7687

# Set the entrypoint to the new script
ENTRYPOINT ["/var/lib/neo4j/scripts/entrypoint.sh"]