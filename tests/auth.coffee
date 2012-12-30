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
  

### Usage 
describe('test', function(){
  it('should work with objects', function(){
    var a = { name: 'tobi', age: 2, species: 'ferret' };
    var b = { name: 'jane', age: 8, species: 'ferret' };
    a.should.eql(b);
  })

  it('should work with arrays', function(){
    var a = [1,2,{ name: 'tobi' },4,5]
    var b = [1,2,{ name: 'jane' },4,4, 'extra stuff', 'more extra']
    a.should.eql(b);
  })

  it('should work with strings', function(){
    'some\nfoo\nbar'.should.equal('some\nbar\nbaz');
  })
})

###