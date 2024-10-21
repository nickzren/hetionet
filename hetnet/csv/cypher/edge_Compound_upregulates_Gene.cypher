LOAD CSV WITH HEADERS FROM 'file:///edge_Compound_upregulates_Gene.csv' AS row
MATCH (a:Compound {identifier: toString(row.source_id)})
MATCH (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:UPREGULATES_CuG]->(b)
SET r.method = toString(row.method),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased),
 r.z_score = toFloat(row.z_score);
