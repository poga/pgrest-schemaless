should = (require \chai).should!
{expect} = require \chai
{mk-pgrest-fortest} = require \./testlib
{mount-storage, validate-storage-table-exists, validate-storage-table-schema, create-storage-table} = require \../lib/storage

require! pgrest

var plx

SCHEMA = \public
TABLE = \pgrest_schemaless_storage

describe 'Storage' ->
  beforeEach (done) ->
    _plx <- mk-pgrest-fortest!
    plx := _plx
    done!

  describe 'validation' ->
    beforeEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    afterEach (done) ->
      <- plx.query "DROP TABLE IF EXISTS #{TABLE};"
      done!
    describe 'validate-storage-table-exist', -> ``it``
      .. 'should return false if storage table doesn\'t exist' (done) ->
        <- validate-storage-table-exists plx, SCHEMA, TABLE
        it.should.be.not.ok
        done!
      .. 'should return true if storage table exist' (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          data json
        );
        """
        <- validate-storage-table-exists plx, SCHEMA, TABLE
        it.should.be.ok
        done!
    describe 'validate-storage-table-schema', -> ``it``
      .. 'should return false if storage table does not have a correct schema' (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          foo int
        );
        """
        <- validate-storage-table-schema plx, SCHEMA, TABLE
        it.should.not.ok
        done!
      .. 'should return true if storage table have a correct schema' (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          data json
        );
        """
        <- validate-storage-table-schema plx, SCHEMA, TABLE
        it.should.be.ok
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

