### Tests for Twitter /lib/twitter ###

cfg = require '../cfg/config.js'
should = require 'should'
Twitter = (require '../lib/twitter.js').Twitter

# Initialize controller
tw = new Twitter cfg

describe 'Twitter connection', ->
  it 'Should retrieve at least one favorite', (done) ->
    tw.getFavorites 10, (callback) ->
      done()