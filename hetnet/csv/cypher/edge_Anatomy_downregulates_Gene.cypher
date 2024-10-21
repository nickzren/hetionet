LOAD CSV WITH HEADERS FROM 'file:///edge_Anatomy_downregulates_Gene.csv' AS row
MATCH (a:Anatomy {identifier: toString(row.source_id)})
MATCH (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:DOWNREGULATES_AdG]->(b)
SET r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
