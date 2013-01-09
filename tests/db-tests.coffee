### Tests for Database /lib/db ###

cfg = require '../cfg/config.js'
should = require 'should'

Db = (require '../lib/db.js').Db
db = new Db cfg


describe 'Redis is running', ->
  
  testKey = 'testKey'
  testValue = 'testValue'
  
  it 'Should be able to set a string', (done) ->
    db.redis.set testKey, testValue, done
    
  it 'Should be able to get the string we set', (done) ->
    db.redis.get testKey, (err, data) ->
      should.not.exist err
      data.should.equal testValue
      done()


describe 'Access Tokens', ->
  # it 'Should be able to set an access token', (done) ->
    
  # it 'Should be able to get the access token we set', (done) ->
    