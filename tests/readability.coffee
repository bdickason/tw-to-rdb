### Tests for Readability /lib/readability ###

cfg = require '../cfg/config.js'
should = require 'should'
Readability = (require '../lib/readability.js').Readability

# Initialize controller
rdb = new Readability cfg


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