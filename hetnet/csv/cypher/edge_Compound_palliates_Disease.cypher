LOAD CSV WITH HEADERS FROM 'file:///edge_Compound_palliates_Disease.csv' AS row
MATCH (a:Compound {identifier: toString(row.source_id)})
MATCH (b:Disease {identifier: toString(row.target_id)})
CREATE (a)-[r:PALLIATES_CpD]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
