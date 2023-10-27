LOAD CSV WITH HEADERS FROM 'file:///edge_Compound_downregulates_Gene.csv' AS row
MATCH (a:Compound {identifier: toString(row.source_id)}), (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:DOWNREGULATES_CdG]->(b)
SET r.method = toString(row.method),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased),
 r.z_score = toFloat(row.z_score);
