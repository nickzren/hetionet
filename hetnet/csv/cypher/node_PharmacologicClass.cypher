CREATE INDEX identifier_index_PharmacologicClass FOR (n:PharmacologicClass) ON (n.identifier);
LOAD CSV WITH HEADERS FROM 'file:///node_PharmacologicClass.csv' AS row
CREATE (n:PharmacologicClass) SET n.class_type = toString(row.class_type), n.identifier = toString(row.identifier), n.license = toString(row.license), n.name = row.name, n.source = toString(row.source), n.url = toString(row.url);
