LOAD CSV WITH HEADERS FROM 'file:///edge_Gene_participates_BiologicalProcess.csv' AS row
MATCH (a:Gene {identifier: toInteger(row.source_id)}), (b:BiologicalProcess {identifier: toString(row.target_id)})
CREATE (a)-[r:PARTICIPATES_GpBP]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
