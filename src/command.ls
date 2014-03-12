require! pgrest
pgrest-schemaless = require \../
pgrest.use pgrest-schemaless
app <- pgrest.cli! {}, {}, [], null, null

