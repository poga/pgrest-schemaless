#!/usr/bin/env lsc -cj
author:
  name: ['Poga Po']
  email: 'poga@poga.tw'
name: 'pgrest-firebase'
description: 'firebase api with schemaless storage on PgREST'
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
  primus: \*
  'lodash-node': \*
devDependencies:
  mocha: \*
  supertest: \0.7.x
  chai: \*
  LiveScript: \1.2.x
  pgrest: \0.1.x
  gulp: \*
  'gulp-livescript': \*
  'gulp-util': \*
peerDependencies:
  pgrest: \0.1.x
