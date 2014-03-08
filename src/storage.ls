export class Storage
  (plx, schema, table, name) ->
    @plx = plx
    @schema = schema
    @table = table
    @name = name
  
  # TODO: apply RFC 6902 JSON PATCH to json
  apply: (path, patch) ->
    ...

  # TODO: get child at path
  get: (path) ->
    ...
