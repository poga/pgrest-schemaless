require! pgrest
require! sockjs
{mount-schemaless} = require './schemaless'

# To tell pgrest that the plugin is actived.
export function isactive (opts)
  opts.schemaless?

# To hook command line options processing.
export function process-opts (opts)
  console.log 'process-opts'
  opts.schemaless = opts.argv.schemaless or opts.cfg.schemaless
  opts.schemaless_schema = \public
  opts.schemaless_table = \pgrest_schemaless
  console.log opts

# Plugin initialized
# - called in load-plugins().
export function initialize (opts)
  void

# To hook plx8 instance.
# - called after plx8 is created in cli().
export function posthook-cli-create-plx (opts, plx)
  console.log 'mounting...'
  <- mount-schemaless plx, opts.schemaless_schema, opts.schemaless_table

export function posthook-cli-create-server (opts, server)
  console.log 'mounting...'
  sock = sockjs.createServer!
  sock.on \connection, (conn) ->
    conn.on \data ->
      conn.write it
  sock.installHandlers server, prefix: '/schemaless'
