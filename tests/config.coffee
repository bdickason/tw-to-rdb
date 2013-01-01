### Tests for Config /cfg ###

cfg = require '../cfg/config.js'
should = require 'should'

describe 'Twitter credentials', ->
  it 'Should have a consumer key', ->
    tmp = cfg.TW_CONSUMER_KEY
    tmp.should.not.eql ''
    
  it 'Should have a consumer secret', ->
    tmp = cfg.TW_CONSUMER_SECRET
    tmp.should.not.eql ''
    
  it 'Should have an access token', ->
    tmp = cfg.TW_ACCESS_TOKEN
    tmp.should.not.eql ''
    
  it 'Should have an access token secret', ->
    tmp = cfg.TW_ACCESS_TOKEN_SECRET
    tmp.should.not.eql ''

describe 'Readability credentials', ->
  it 'Should have a consumer key', ->
    tmp = cfg.RDB_CONSUMER_KEY
    tmp.should.not.eql ''

  it 'Should have a consumer secret', ->
    tmp = cfg.RDB_CONSUMER_SECRET
    tmp.should.not.eql ''

  it 'Should have an access token', ->
    tmp = cfg.RDB_ACCESS_TOKEN
    tmp.should.not.eql ''

  it 'Should have an access token secret', ->
    tmp = cfg.RDB_ACCESS_TOKEN_SECRET
    tmp.should.not.eql ''

