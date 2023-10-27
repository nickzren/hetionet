LOAD CSV WITH HEADERS FROM 'file:///edge_Disease_localizes_Anatomy.csv' AS row
MATCH (a:Disease {identifier: toString(row.source_id)}), (b:Anatomy {identifier: toString(row.target_id)})
CREATE (a)-[r:LOCALIZES_DlA]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
