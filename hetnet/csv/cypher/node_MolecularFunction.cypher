CREATE INDEX identifier_index_MolecularFunction FOR (n:MolecularFunction) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_MolecularFunction.csv' AS row
CREATE (n:MolecularFunction) SET n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
