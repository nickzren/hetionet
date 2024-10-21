LOAD CSV WITH HEADERS FROM 'file:///edge_Compound_binds_Gene.csv' AS row
MATCH (a:Compound {identifier: toString(row.source_id)})
MATCH (b:Gene {identifier: toInteger(row.target_id)})
CREATE (a)-[r:BINDS_CbG]->(b)
SET r.actions = split(replace(replace(replace(row.actions, '[', ''), ']', ''), "'", ''), ','),
 r.affinity_nM = toFloat(row.affinity_nM),
 r.license = toString(row.license),
 r.pubmed_ids = split(replace(replace(replace(row.pubmed_ids, '[', ''), ']', ''), "'", ''), ','),
 r.sources = split(replace(replace(replace(row.sources, '[', ''), ']', ''), "'", ''), ','),
 r.unbiased = toBoolean(row.unbiased),
 r.urls = split(replace(replace(replace(row.urls, '[', ''), ']', ''), "'", ''), ',');
