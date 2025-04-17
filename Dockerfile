FROM neo4j:5.17

ENV \
  NEO4J_AUTH=none \
  NEO4J_initial_dbms_default__database=hetionet \
  NEO4JLABS_PLUGINS='["apoc","graph-data-science"]' \
  NEO4J_dbms_security_auth__enabled=false \
  NEO4J_server_bolt_listen__address=0.0.0.0:7687

RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    pip3 install neo4j && \
    rm -rf /var/lib/apt/lists/*