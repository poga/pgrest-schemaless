#!/usr/bin/env lsc -cj
author:
  name: ['Poga Po']
  email: 'poga@poga.tw'
name: 'pgrest-schemaless'
description: 'a schemaless database with firebase API on PgREST'
version: '0.0.1'
main: \lib/index.js
repository:
  type: 'git'
  url: '{VCS}'
scripts:
  test: """
    mocha
  """
  prepublish: """
  lsc -bc -o lib src/
  """
engines: {node: '*'}
dependencies:
  sockjs: \*
  'lodash-node': \*
  jsonpatch: \*
devDependencies:
  mocha: \*
  supertest: \0.7.x
  chai: \*
  'chai-things': \*
  LiveScript: \1.2.x
  pgrest: \0.1.x
peerDependencies:
  pgrest: \0.1.x
