require! chai
should = chai.should!
assert = chai.assert
chai.use require 'chai-things'
{expect} = require \chai
{mk-pgrest-fortest} = require \./testlib
{mount-schemaless, create-table, create-storage} = require \../lib/schemaless
{validate-table-exists, validate-table-schema} = require \../lib/validation
lo = require 'lodash-node'

require! pgrest

var plx

SCHEMA = \public
TABLE = \pgrest_schemaless

describe 'Schemaless' ->
  beforeEach (done) ->
    _plx <- mk-pgrest-fortest!
    plx := _plx
    done!
  describe 'create table' ->
    beforeEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    afterEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    describe 'create-table', -> ``it``
      .. 'should create valid storage table', (done) ->
        <- create-table plx, SCHEMA, TABLE
        <- validate-table-exists plx, SCHEMA, TABLE
        it.should.be.ok
        <- validate-table-schema plx, SCHEMA, TABLE
        it.should.be.ok
        done!
  describe 'mount' ->
    beforeEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    afterEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    describe 'when table does not exist', -> ``it``
      .. 'should create table', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        assert.isUndefined err
        done!
    describe 'when a valid table already exists', -> ``it``
      .. 'should return a storage object with existing table', (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          data json
        );
        """
        err <- mount-schemaless plx, SCHEMA, TABLE
        assert.isUndefined err
        done!
    describe 'when a invalid table already exists', -> ``it``
      .. 'should throw error', (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          foo int
        );
        """
        err <- mount-schemaless plx, SCHEMA, TABLE
        err.should.be.an.instanceof Error
        done!
    describe 'storage row', -> ``it``
      .. 'should be created by create-storage', (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          data json
        );
        """
        storage <- create-storage plx, SCHEMA, TABLE, "test"
        <- plx.query """
        SELECT * from #TABLE;
        """
        it.should.deep.eq [ name: \test, data: {}]
        done!
    describe 'mount-schemaless', -> ``it``
      .. 'should import jsonpatch into plv8', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        <- plx.query """
        select ~> 'require("jsonpatch").apply_patch({}, [{op: "add", path: "/new", value: "new_value"}])' as result;
        """
        it.should.deep.eq [ {result: { new: 'new_value'}}]
        done!
      .. 'should define jsonpatch as user function in pg', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        <- plx.query """
        SELECT  proname
        FROM    pg_catalog.pg_namespace n
        JOIN    pg_catalog.pg_proc p
        ON      pronamespace = n.oid
        WHERE   nspname = 'public'
        """
        it.should.include.something.that.deep.equals proname: 'apply_patch'
        done!
      .. 'imported user function should work properly', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        <- plx.query """
        select apply_patch('{}'::json, ARRAY['{"op": "add", "path": "/new", "value": "new"}'::json]) as ret;
        """
        it.should.deep.eq [ ret: new: 'new']
        done!
      .. 'should define functions from user_func as user function in pg', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        <- plx.query """
        SELECT  proname
        FROM    pg_catalog.pg_namespace n
        JOIN    pg_catalog.pg_proc p
        ON      pronamespace = n.oid
        WHERE   nspname = 'public'
        """
        it.should.include.something.that.deep.equals proname: 'pgrest_schemaless_set'
        it.should.include.something.that.deep.equals proname: 'pgrest_schemaless_get'
        done!
      .. 'schemaless_set should apply a json patch to old json and update it', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        params =
          table: TABLE
          name: \test
          # RFC 6902 JSON Patch
          patch:
            op: 'add'
            path: '/new'
            value: 'new'
        storage <- create-storage plx, SCHEMA, TABLE, 'test'
        ret <- plx['schemaless_set'].call plx, params, _, (err) -> throw err
        ret.should.equals 1
        <- plx.query "select data from #TABLE where name='test'"
        it.0.data.should.deep.eq new: 'new'
        done!
      .. 'schemaless_get should return a root json with root path("/")', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        storage <- create-storage plx, SCHEMA, TABLE, 'test'
        get-params =
          table: TABLE
          name: \test
          path: "/"
        ret <- plx['schemaless_get'].call plx, get-params, _, (err) -> throw err
        ret.should.deep.equals {}
        set-params =
          table: TABLE
          name: \test
          patch:
            op: 'add'
            path: '/foo'
            value: { bar: \bar}
        ret <- plx['schemaless_set'].call plx, set-params, _, (err) -> throw err
        ret <- plx['schemaless_get'].call plx, get-params, _, (err) -> throw err
        ret.should.deep.equals foo: bar: \bar
        done!
      .. 'schemaless_get should return child json specified by path', (done) ->
        err <- mount-schemaless plx, SCHEMA, TABLE
        storage <- create-storage plx, SCHEMA, TABLE, 'test'
        set-params =
          table: TABLE
          name: \test
          patch:
            op: 'add'
            path: '/foo'
            value: { bar: \bar}
        ret <- plx['schemaless_set'].call plx, set-params, _, (err) -> throw err
        get-params =
          table: TABLE
          name: \test
          path: "/foo"
        ret <- plx['schemaless_get'].call plx, get-params, _, (err) -> throw err
        ret.should.deep.equals bar: \bar
        done!
