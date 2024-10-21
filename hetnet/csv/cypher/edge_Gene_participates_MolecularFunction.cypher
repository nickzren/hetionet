LOAD CSV WITH HEADERS FROM 'file:///edge_Gene_participates_MolecularFunction.csv' AS row
MATCH (a:Gene {identifier: toInteger(row.source_id)})
MATCH (b:MolecularFunction {identifier: toString(row.target_id)})
CREATE (a)-[r:PARTICIPATES_GpMF]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
