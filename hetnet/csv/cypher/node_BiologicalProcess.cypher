CREATE INDEX identifier_index_BiologicalProcess FOR (n:BiologicalProcess) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_BiologicalProcess.csv' AS row
CREATE (n:BiologicalProcess) SET n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
