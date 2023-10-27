CREATE INDEX identifier_index_Compound FOR (n:Compound) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_Compound.csv' AS row
CREATE (n:Compound) SET n.identifier = toString(row.identifier), n.inchi = toString(row.inchi), n.inchikey = toString(row.inchikey), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
