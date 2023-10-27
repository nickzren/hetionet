LOAD CSV WITH HEADERS FROM 'file:///edge_Gene_participates_Pathway.csv' AS row
MATCH (a:Gene {identifier: toInteger(row.source_id)}), (b:Pathway {identifier: toString(row.target_id)})
CREATE (a)-[r:PARTICIPATES_GpPW]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased),
 r.url = toString(row.url);
