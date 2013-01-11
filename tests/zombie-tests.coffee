### Tests for Zombie (headless browser) /lib/zombie ###

cfg = require '../cfg/config.js'
should = require 'should'

Browser = require 'zombie'

browser = new Browser

describe 'Zombie is eating braiiiiinssssss', ->
  # Stub Data
  pageTitle = "Twitter Reading List"
  
  it 'Should be able to visit the homepage', (done) ->
    browser.visit 'http://localhost:3000', (callback) ->
      browser.success.should.equal true
      browser.text('title').should.equal pageTitle
      done()

describe 'Sessions', ->  

  # Stub Data
  pageTitle = "Twitter Reading List"  
  logoutHtml = "<a href=\"/tw/login\">Sign In with Twitter</a><a href=\"#\" class=\"disabled\">Sign In with Readability</a>"
  loggedInHtml = "<a href=\"http://www.twitter.com/#{cfg.TW_USERNAME}\" target=\"_blank\">#{cfg.TW_USERNAME}</a><a href=\"/rdb/login\">Sign In with Readability</a>"

  it 'Should be able to logout', (done) ->
    browser.visit 'http://localhost:3000', (callback) ->
      browser.success.should.equal true
      browser.clickLink 'logout', ->        
        browser.success.should.equal true
        browser.html('.auth #twitter a').should.equal logoutHtml 
        done()

  it 'Should be able to login with Twitter', (done) ->
    @timeout 30000
    browser.visit 'http://localhost:3000', (callback) ->
      browser.success.should.equal true
      browser.clickLink 'Sign In with Twitter', ->
        browser.success.should.equal true
        browser.fill('session[username_or_email]', cfg.TW_USERNAME)
          .fill('session[password]', cfg.TW_PASSWORD)
          .pressButton 'Sign In', ->
            browser.wait 20, ->
              browser.statusCode.should.equal 200
              browser.clickLink 'click here to continue', ->
                browser.success.should.equal true
                browser.text('title').should.equal pageTitle
                browser.html('.auth #twitter a').should.equal loggedInHtml
                done()

