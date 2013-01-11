### Tests for Timers /lib/timer ###

cfg = require '../cfg/config.js'
should = require 'should'

Db = (require '../lib/db.js').Db
db = new Db cfg

Timer = (require '../lib/timer.js').Timer

describe 'Timers', ->
  
  # Stub data
  user_name = "testuser"
  
  it 'Should be able to start a timer', (done) ->
      timer = new Timer user_name, cfg, db
      timer.startTimer 500, (error, callback) ->
        should.not.exist error
        callback.should.equal 'Done!'
        done()

  it 'Should be able to stop a timer', (done) ->
      done()
      