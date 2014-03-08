export function pgrest_schemaless_set (params)
  query = "select data from #{params.table} where name='#{params.name}'"
  [{data}] = plv8.execute query
  old-data = JSON.stringify data
  patch = JSON.stringify params.patch
  query = "select apply_patch('#{old-data}'::json, ARRAY['#{patch}'::json]) as ret;"
  ret = plv8.execute query
  query = "update #{params.table} set data='#{ret.0.ret}'::json where name='#{params.name}'"
  return plv8.execute query
pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

export function pgrest_schemaless_get (params)
# TODO: get a child within data json according to params.path
  pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

