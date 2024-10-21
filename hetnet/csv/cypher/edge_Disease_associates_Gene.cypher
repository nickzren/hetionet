LOAD CSV WITH HEADERS FROM 'file:///edge_Disease_associates_Gene.csv' AS row
MATCH (a:Disease {identifier: toString(row.source_id)})
MATCH (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:ASSOCIATES_DaG]->(b)
SET r.license = toString(row.license),
 r.sources = split(replace(replace(replace(row.sources, '[', ''), ']', ''), "'", ''), ','),
 r.unbiased = toBoolean(row.unbiased);
