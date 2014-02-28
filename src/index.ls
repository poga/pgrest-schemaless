require! pgrest

# To tell pgrest that the plugin is actived.
export function isactive (opts)
  ...

# To hook command line options processing.
export function process-opts (opts)
  ...

# Plugin initialized
# - called in load-plugins().
export function initialize (opts)
  ...

# To hook plx8 instance.
# - called after plx8 is created in cli().
export function posthook-cli-create-plx (opts, plx)
  ...

# To hook express app
# - called after express app is created in cli().
export function posthook-cli-create-app (opts, app)
  ...

# To hook plx8 instance, express app, middleware
# - called before routing setup, mount models in cli().
export function prehook-cli-mount-default (opts, plx, app, middleware)
  ...

# To hook http server.
# - called after http server is created in cli()
export function posthook-cli-create-server (opts, server)
  ...

# To hook http server.
# - called after http server starts to listen in cli()
export function posthook-cli-server-listen (opts, plx, app, server)
  ...
