export function pgrest_schemaless_set (params)
  query = "select apply_patch('{}'::json, ARRAY['{\"op\": \"add\", \"path\": \"/new\", \"value\": \"new\"}'::json]) as ret;"
  return plv8.execute query
pgrest_schemaless_set.$plv8x = '(plv8x.json):plv8x.json'

