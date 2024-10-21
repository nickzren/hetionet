LOAD CSV WITH HEADERS FROM 'file:///edge_Gene_interacts_Gene.csv' AS row
MATCH (a:Gene {identifier: toInteger(row.source_id)})
MATCH (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:INTERACTS_GiG]->(b)
SET r.sources = split(replace(replace(replace(row.sources, '[', ''), ']', ''), "'", ''), ','),
 r.unbiased = toBoolean(row.unbiased);
