### Tests for Twitter /lib/twitter ###

cfg = require '../cfg/config.js'
should = require 'should'
Twitter = (require '../lib/twitter.js').Twitter
Redis = require 'redis'

# Start up redis
redis = Redis.createClient cfg.REDIS_PORT, cfg.REDIS_HOSTNAME
redis.on 'error', (err) ->
  console.log 'REDIS Error:' + err
  
# Initialize controller
tw = new Twitter cfg, redis

### Having issues with Jenkins configuration
describe 'Twitter connection', ->
  it 'Should retrieve at least one favorite', (done) ->
    tw.getFavorites 10, (callback) ->
      done()
###