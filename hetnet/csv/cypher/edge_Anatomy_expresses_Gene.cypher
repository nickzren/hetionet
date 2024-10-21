LOAD CSV WITH HEADERS FROM 'file:///edge_Anatomy_expresses_Gene.csv' AS row
MATCH (a:Anatomy {identifier: toString(row.source_id)})
MATCH (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:EXPRESSES_AeG]->(b)
SET r.license = toString(row.license),
 r.sources = split(replace(replace(replace(row.sources, '[', ''), ']', ''), "'", ''), ','),
 r.unbiased = toBoolean(row.unbiased);
