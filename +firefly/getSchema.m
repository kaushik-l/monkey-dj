function obj = getSchema
persistent schemaObject
if isempty(schemaObject)
    schemaObject = dj.Schema(dj.conn, 'firefly', 'firefly');
end
obj = schemaObject;
end
