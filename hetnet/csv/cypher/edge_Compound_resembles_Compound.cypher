LOAD CSV WITH HEADERS FROM 'file:///edge_Compound_resembles_Compound.csv' AS row
MATCH (a:Compound {identifier: toString(row.source_id)}), (b:Compound {identifier: toString(row.target_id)})
CREATE (a)-[r:RESEMBLES_CrC]->(b)
SET r.license = toString(row.license),
 r.similarity = toFloat(row.similarity),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased);
