CREATE INDEX identifier_index_CellularComponent FOR (n:CellularComponent) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_CellularComponent.csv' AS row
CREATE (n:CellularComponent) SET n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
