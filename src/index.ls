require! pgrest
require! sockjs
{mount-schemaless} = require './schemaless'

# To tell pgrest that the plugin is actived.
export function isactive (opts)
  opts.schemaless?

# To hook command line options processing.
export function process-opts (opts)
  opts.schemaless = opts.argv.schemaless or opts.cfg.schemaless
  opts.schemaless_schema = \public
  opts.schemaless_table = \pgrest_schemaless

# Plugin initialized
# - called in load-plugins().
export function initialize (opts)
  void

# To hook plx8 instance.
# - called after plx8 is created in cli().
export function posthook-cli-create-plx (opts, plx)
  <- mount-schemaless plx, opts.schemaless_schema, opts.schemaless_table

export function posthook-cli-create-server (opts, server)
  sock = sockjs.createServer!
  do
    conn <- sock.on \connection
    conn.on \data ->
      conn.write it
  sock.installHandlers server, prefix: '/schemaless'
