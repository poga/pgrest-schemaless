{validate-table-exists, validate-table-schema} = require './validation'

export function mount-all (plx, cb)
  next <- plx.import-bundle-funcs 'jsonpatch', require.resolve("jsonpatch/package.json")
  <- next!
  <- plx.mk-user-func 'plv8x.json apply_patch(json, json[])', 'jsonpatch:apply_patch'
  next <- plx.import-bundle-funcs 'pgrest_schemaless_op', require.resolve('./pgrest_schemaless_op/package.json')
  <- next!
  <- plx.mk-user-func 'plv8x.json pgrest_schemaless_set_uf(json)', 'pgrest_schemaless_op:pgrest_schemaless_set'
  <[schemaless_set]>.forEach (method) ->
    plx[method] = (params, cb, onError) ->
      # TODO: wrap this into a serializable transaction to avoid race condition
      err, {rows}? <- @conn.query "select pgrest_#{method}_uf($1) as ret", [params]
      return onError(err) if err
      ret = rows.0.ret
      cb? JSON.parse ret.0.ret
  cb?!

export function mount-schemaless (plx, schema, table, cb)
  <- mount-all plx
  exists <- validate-table-exists plx, schema, table
  if exists
    valid <- validate-table-schema plx, schema, table
    if valid
      cb? void
    else
      cb new Error "#schema.#table already exists and does not have correct schema"
  else
    <- create-table(plx, schema, table)
    cb? void

export function create-table (plx, schema, table, cb)
  <- plx.query """
  CREATE TABLE #table (
    name text,
    data json
  );
  """
  cb?!

