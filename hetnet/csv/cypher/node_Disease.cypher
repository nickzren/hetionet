CREATE INDEX identifier_index_Disease FOR (n:Disease) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_Disease.csv' AS row
CREATE (n:Disease) SET n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
