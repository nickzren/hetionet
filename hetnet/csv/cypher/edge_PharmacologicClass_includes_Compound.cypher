LOAD CSV WITH HEADERS FROM 'file:///edge_PharmacologicClass_includes_Compound.csv' AS row
MATCH (a:PharmacologicClass {identifier: toString(row.source_id)}), (b:Compound {identifier: toString(row.target_id)})
CREATE (a)-[r:INCLUDES_PCiC]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
