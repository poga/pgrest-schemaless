require! url

class Reference
  (uri) ->
    {@host, pathname} = url.parse uri, true, true
    console.log @host
    @path = pathname.split "/" .slice 1
    console.log @path
    @@sock = new SockJS "http://#{@host}/schemaless"

window.Reference = Reference
console.log 'client'
