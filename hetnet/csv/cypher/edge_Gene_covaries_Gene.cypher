LOAD CSV WITH HEADERS FROM 'file:///edge_Gene_covaries_Gene.csv' AS row
MATCH (a:Gene {identifier: toInteger(row.source_id)}), (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:COVARIES_GcG]->(b)
SET r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
