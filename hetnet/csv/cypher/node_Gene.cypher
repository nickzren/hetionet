CREATE INDEX identifier_index_Gene FOR (n:Gene) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_Gene.csv' AS row
CREATE (n:Gene) SET n.chromosome = toString(row.chromosome), n.description = toString(row.description), n.identifier = toInteger(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
