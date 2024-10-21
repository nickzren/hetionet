FROM neo4j:5.17

ENV NEO4J_AUTH=none \
    NEO4J_DBMS_DEFAULT__DATABASE=hetionet \
    NEO4JLABS_PLUGINS='["apoc", "graph-data-science"]' \
    NEO4J_DBMS_SECURITY_AUTHENTICATION__ENABLED=false \
    NEO4J_SERVER_BOLT_LISTEN__ADDRESS=0.0.0.0:7687

# Install Python and pip
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install neo4j && \
    rm -rf /var/lib/apt/lists/*