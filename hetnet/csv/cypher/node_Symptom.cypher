CREATE INDEX identifier_index_Symptom FOR (n:Symptom) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_Symptom.csv' AS row
CREATE (n:Symptom) SET n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
