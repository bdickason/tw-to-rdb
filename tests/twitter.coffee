### Tests for Twitter /lib/twitter ###

cfg = require '../cfg/config.js'
should = require 'should'
Twitter = (require '../lib/twitter.js').Twitter

# Initialize controller
tw = new Twitter

describe 'Twitter connection', ->
  it 'Should retrieve at least one favorite', (done) ->
    tw.getFavorites (callback) ->
      done()