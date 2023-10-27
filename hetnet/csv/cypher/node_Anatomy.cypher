CREATE INDEX identifier_index_Anatomy FOR (n:Anatomy) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_Anatomy.csv' AS row
CREATE (n:Anatomy) SET n.bto_id = toString(row.bto_id), n.identifier = toString(row.identifier), n.license = toString(row.license), n.mesh_id = toString(row.mesh_id), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
