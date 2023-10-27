CREATE INDEX identifier_index_SideEffect FOR (n:SideEffect) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_SideEffect.csv' AS row
CREATE (n:SideEffect) SET n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
