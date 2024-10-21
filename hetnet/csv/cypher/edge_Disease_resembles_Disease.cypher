LOAD CSV WITH HEADERS FROM 'file:///edge_Disease_resembles_Disease.csv' AS row
MATCH (a:Disease {identifier: toString(row.source_id)})
MATCH (b:Disease {identifier: toString(row.target_id)})
CREATE (a)-[r:RESEMBLES_DrD]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
