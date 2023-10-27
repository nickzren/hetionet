LOAD CSV WITH HEADERS FROM 'file:///edge_Gene_regulates_Gene.csv' AS row
MATCH (a:Gene {identifier: toInteger(row.source_id)}), (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:REGULATES_GrG]->(b)
SET r.method = toString(row.method),
 r.source = toString(row.source),
 r.subtypes = split(replace(replace(replace(row.subtypes, '[', ''), ']', ''), "'", ''), ','),
 r.unbiased = toBoolean(row.unbiased);
