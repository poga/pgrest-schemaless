export function pgrest_schemaless_set (params)
  # TODO: select data from params.table where name='#{params.name}', assign to data variable
  old-data = JSON.stringify data
  patch = JSON.stringify params.patch
  query = "select apply_patch('#old-data'::json, ARRAY['#patch'::json]) as ret;"
  # TODO: update row which name='#{params.name}' with new json
  return plv8.execute query
pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

export function pgrest_schemaless_get (params)
  # TODO: get a child within data json according to params.path
pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

