require! chai
should = chai.should!
chai.use require 'chai-things'
{expect} = require \chai
{mk-pgrest-fortest} = require \./testlib
{mount-storage, create-storage-table} = require \../lib/storage
{validate-storage-table-exists, validate-storage-table-schema} = require \../lib/validation
lo = require 'lodash-node'

require! pgrest

var plx

SCHEMA = \public
TABLE = \pgrest_schemaless_storage

describe 'Storage' ->
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
    describe 'create-storage-table', -> ``it``
      .. 'should create valid storage table', (done) ->
        <- create-storage-table plx, SCHEMA, TABLE
        <- validate-storage-table-exists plx, SCHEMA, TABLE
        it.should.be.ok
        <- validate-storage-table-schema plx, SCHEMA, TABLE
        it.should.be.ok
        done!
  describe 'mount storage' ->
    beforeEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    afterEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    describe 'when table does not exist', -> ``it``
      .. 'should create table and return a Storage object', (done) ->
        storage <- mount-storage plx, SCHEMA, TABLE
        storage.should.be.ok
        done!
    describe 'when a valid table already exists', -> ``it``
      .. 'should return a storage object with existing table', (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          data json
        );
        """
        storage <- mount-storage plx, SCHEMA, TABLE
        storage.should.be.ok
        done!
    describe 'when a invalid table already exists', -> ``it``
      .. 'should throw error', (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          foo int
        );
        """
        storage <- mount-storage plx, SCHEMA, TABLE
        storage.should.be.an.instanceof Error
        done!
    describe 'mount-storage', -> ``it``
      .. 'should import jsonpatch into plv8', (done) ->
        storage <- mount-storage plx, SCHEMA, TABLE
        <- plx.query """
        select ~> 'require("jsonpatch").apply_patch({}, [{op: "add", path: "/new", value: "new_value"}])' as result;
        """
        it.should.deep.eq [ {result: { new: 'new_value'}}]
        done!
      .. 'should define jsonpatch as user function in pg', (done) ->
        storage <- mount-storage plx, SCHEMA, TABLE
        <- plx.query """
        SELECT  proname
        FROM    pg_catalog.pg_namespace n
        JOIN    pg_catalog.pg_proc p
        ON      pronamespace = n.oid
        WHERE   nspname = 'public'
        """
        it.should.include.something.that.deep.equals proname: 'apply_patch'
        done!

