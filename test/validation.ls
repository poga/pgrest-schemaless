should = (require \chai).should!
{expect} = require \chai
{mk-pgrest-fortest} = require \./testlib
{validate-table-exists, validate-table-schema} = require \../lib/validation

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
    describe 'validate-table-exist', -> ``it``
      .. 'should return false if table doesn\'t exist' (done) ->
        <- validate-table-exists plx, SCHEMA, TABLE
        it.should.be.not.ok
        done!
      .. 'should return true if table exist' (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          data json
        );
        """
        <- validate-table-exists plx, SCHEMA, TABLE
        it.should.be.ok
        done!
    describe 'validate-table-schema', -> ``it``
      .. 'should return false if table does not have a correct schema' (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          foo int
        );
        """
        <- validate-table-schema plx, SCHEMA, TABLE
        it.should.not.ok
        done!
      .. 'should return true if table have a correct schema' (done) ->
        <- plx.query """
        CREATE TABLE #TABLE (
          name text,
          data json
        );
        """
        <- validate-table-schema plx, SCHEMA, TABLE
        it.should.be.ok
        done!
