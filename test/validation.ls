should = (require \chai).should!
{expect} = require \chai
{mk-pgrest-fortest} = require \./testlib
{validate-storage-table-exists, validate-storage-table-schema} = require \../lib/validation

require! pgrest

var plx

SCHEMA = \public
TABLE = \pgrest_schemaless_storage

describe 'Validation' ->
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
