LOAD CSV WITH HEADERS FROM 'file:///edge_Gene_participates_CellularComponent.csv' AS row
MATCH (a:Gene {identifier: toInteger(row.source_id)})
MATCH (b:CellularComponent {identifier: toString(row.target_id)})
CREATE (a)-[r:PARTICIPATES_GpCC]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
