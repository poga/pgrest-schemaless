{validate-storage-table-exists, validate-storage-table-schema} = require './validation'

export function mount-storage (plx, schema, table, cb)
  <- plx.mk-user-func 'plv8x.json apply_patch(json, json[])', 'jsonpatch:apply_patch'
  exists <- validate-storage-table-exists plx, schema, table
  if exists
    valid <- validate-storage-table-schema plx, schema, table
    if valid
      cb new Storage plx, schema, table
    else
      cb new Error "#schema.#table already exists and does not have correct schema"
  else
    <- create-storage-table(plx, schema, table)
    cb new Storage plx, schema, table

export function create-storage-table (plx, schema, table, cb)
  <- plx.query """
  DROP TABLE IF EXISTS #table;
  CREATE TABLE #table (
    name text,
    data json
  );
  """
  cb?!

class Storage
  (plx, schema, table) ->
    @plx = plx
    @schema = schema
    @table = table
