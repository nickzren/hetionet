LOAD CSV WITH HEADERS FROM 'file:///edge_Compound_causes_SideEffect.csv' AS row
MATCH (a:Compound {identifier: toString(row.source_id)})
MATCH (b:SideEffect {identifier: toString(row.target_id)})
CREATE (a)-[r:CAUSES_CcSE]->(b)
SET r.license = toString(row.license),
 r.source = toString(row.source),
 r.unbiased = toBoolean(row.unbiased),
 r.url = toString(row.url);
