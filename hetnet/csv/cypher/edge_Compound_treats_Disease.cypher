LOAD CSV WITH HEADERS FROM 'file:///edge_Compound_treats_Disease.csv' AS row
MATCH (a:Compound {identifier: toString(row.source_id)}), (b:Disease {identifier: toString(row.target_id)})
CREATE (a)-[r:TREATS_CtD]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
