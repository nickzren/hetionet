LOAD CSV WITH HEADERS FROM 'file:///edge_Disease_upregulates_Gene.csv' AS row
MATCH (a:Disease {identifier: toString(row.source_id)}), (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:UPREGULATES_DuG]->(b)
SET r.license = toString(row.license),
 r.log2_fold_change = toFloat(row.log2_fold_change),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
