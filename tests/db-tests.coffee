### Tests for Database /lib/db ###

cfg = require '../cfg/config.js'
should = require 'should'

Db = (require '../lib/db.js').Db
db = new Db cfg


describe 'Redis is running', ->

  # Stub data
  testKey = 'testKey'
  testValue = 'testValue'
  
  it 'Should be able to set a string', (done) ->
    db.redis.set testKey, testValue, done
    
  it 'Should be able to get the string we set', (done) ->
    db.redis.get testKey, (error, data) ->
      should.not.exist error
      data.should.equal testValue
      done()


describe 'Access Tokens', ->
  
  # Stub data
  testUsername = 'tester'
  testApp = 'TestApp'
  testAccessToken = '1234567890abcdef'
  testAccessTokenSecret = 'fedcba0987654321'
  
  it 'Should be able to set an access token', (done) ->
    db.setAccessTokens testUsername, testApp, testAccessToken, testAccessTokenSecret, (error, reply) ->
      should.not.exist error
      done()    
    
  it 'Should be able to get the access token we set', (done) ->
    db.getAccessTokens testUsername, testApp, (error, reply) ->
      should.not.exist.error
      reply.access_token.should.equal testAccessToken
      reply.access_token_secret.should.equal testAccessTokenSecret
      reply.active.should.equal '1'
      done()