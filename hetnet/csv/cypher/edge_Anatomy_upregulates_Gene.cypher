LOAD CSV WITH HEADERS FROM 'file:///edge_Anatomy_upregulates_Gene.csv' AS row
MATCH (a:Anatomy {identifier: toString(row.source_id)})
MATCH (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:UPREGULATES_AuG]->(b)
SET r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
