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

  it 'Should have a twitter username set', ->
    tmp = cfg.TW_USERNAME
    tmp.should.not.eql '' 


describe 'Readability credentials', ->
  it 'Should have a consumer key', ->
    tmp = cfg.RDB_CONSUMER_KEY
    tmp.should.not.eql ''

  it 'Should have a consumer secret', ->
    tmp = cfg.RDB_CONSUMER_SECRET
    tmp.should.not.eql ''
    
    
describe 'Server Config', ->
  it 'Should have a hostname', ->
    tmp = cfg.HOSTNAME
    tmp.should.not.eql ''
    
  it 'Should have a port number', ->
    tmp = cfg.PORT
    tmp.should.not.eql ''