CREATE INDEX identifier_index_Pathway FOR (n:Pathway) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_Pathway.csv' AS row
CREATE (n:Pathway) SET n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
