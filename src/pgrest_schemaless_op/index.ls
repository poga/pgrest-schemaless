export function pgrest_schemaless_set (params)
  patch = JSON.stringify params.patch
  query = "select apply_patch('{}'::json, ARRAY['#patch'::json]) as ret;"
  return plv8.execute query
pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

