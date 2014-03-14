require! pgrest
require! sockjs
{mount-schemaless, create-storage} = require './schemaless'

var plx

# To tell pgrest that the plugin is actived.
export function isactive (opts)
  opts.schemaless?

# To hook command line options processing.
export function process-opts (opts)
  opts.schemaless = opts.argv.schemaless or opts.cfg.schemaless
  opts.schemaless_schema = opts.argv.schemaless_schema or \public
  opts.schemaless_table = opts.argv.schemaless_table or \pgrest_schemaless
  unless opts.argv.schemaless_storage_name
    throw "storage name is empty"
  opts.schemaless_storage_name = opts.argv.schemaless_storage_name

# To hook plx8 instance.
# - called after plx8 is created in cli().
export function posthook-cli-create-plx (opts, _plx)
  _plx.schemaless_storage_name = opts.schemaless_storage_name
  plx := _plx
  <- mount-schemaless plx, opts.schemaless_schema, opts.schemaless_table
  <- create-storage plx, opts.schemaless_schema, opts.schemaless_table, opts.schemaless_storage_name

export function posthook-cli-create-server (opts, server)
  sock = sockjs.createServer!
  sock.broadcast = {}
  do
    conn <- sock.on \connection
    sock.broadcast[conn.id] = conn;
    conn.on \data -> handler sock, conn, it
    conn.on \close -> delete sock.broadcast[conn.id]
  sock.installHandlers server, prefix: '/schemaless'

function handler (sock, conn, message)
  o = JSON.parse message
  unless o.op
    conn.write "error: invalid op"
    return

  switch o.op
  | "get"
    <- plx['schemaless_get'].call plx, {
      table: plx.schemaless_table
      name: plx.schemaless_storage_name
      path: o.path
    }, _, (err) -> throw err
    conn.write JSON.stringify it
  | <[add remove replace]>
    <- plx['schemaless_set'].call plx, {
      table: plx.schemaless_table
      name: plx.schemaless_storage_name
      patch:
        op: o.op
        path: o.path
        value: o.value
    }, _, (err) -> throw err
    conn.write JSON.stringify it
    for let id, c of sock.broadcast when id != conn.id
      c.write "broadcast: #{JSON.stringify(o)}"
