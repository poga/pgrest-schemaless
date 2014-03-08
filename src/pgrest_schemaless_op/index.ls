export function pgrest_schemaless_set (params)
  # TODO: select data from params.table where name='#{params.name}', assign to data variable
  plv8.elog(WARNING, params.table)
  plv8.elog(WARNING, params.name)
  plv8.elog(WARNING, JSON.stringify(params.patch))
  query = "select data from #{params.table} where name='#{params.name}'"
  plv8.elog(WARNING, query)
  [{data}] = plv8.execute query
  plv8.elog(WARNING, JSON.stringify(data))
  old-data = JSON.stringify data
  patch = JSON.stringify params.patch
  query = "select apply_patch('#{old-data}'::json, ARRAY['#{patch}'::json]) as ret;"
  # TODO: update row which name='#{params.name}' with new json
  plv8.elog(WARNING, query)
  ret = plv8.execute query
  plv8.elog(WARNING, JSON.stringify(ret))
  query = "update #{params.table} set data='#{ret.0.ret}'::json where name='#{params.name}'"
  plv8.elog(WARNING, query)
  result = plv8.execute query
  plv8.elog(WARNING, result)
  return result
pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

export function pgrest_schemaless_get (params)
# TODO: get a child within data json according to params.path
  pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

