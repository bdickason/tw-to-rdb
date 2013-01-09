### Tests for Readability /lib/readability ###

cfg = require '../cfg/config.js'
should = require 'should'
Readability = (require '../lib/readability.js').Readability
Redis = require 'redis'

# Start up redis
redis = Redis.createClient cfg.REDIS_PORT, cfg.REDIS_HOSTNAME
redis.on 'error', (err) ->
  console.log 'REDIS Error:' + err

# Initialize controller
rdb = new Readability cfg, redis


### Having issues with jenkins configuration
describe 'Readability connection', ->
  it 'Can retrieve your bookmarks', (done) ->
    rdb.getBookmarks (callback) ->
      done()
    
  it 'Successfully adds an item to your list', (done) ->
    item = {
      url: "http://braddickason.com/my-daily-checklist/"
    }
    
    rdb.addBookmark item, (callback) ->
      done()
      
###