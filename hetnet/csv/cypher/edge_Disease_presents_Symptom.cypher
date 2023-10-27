LOAD CSV WITH HEADERS FROM 'file:///edge_Disease_presents_Symptom.csv' AS row
MATCH (a:Disease {identifier: toString(row.source_id)}), (b:Symptom {identifier: toString(row.target_id)})
CREATE (a)-[r:PRESENTS_DpS]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
