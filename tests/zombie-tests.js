// Generated by CoffeeScript 1.4.0

/* Tests for Zombie (headless browser) /lib/zombie
*/


(function() {
  var Browser, browser, cfg, should;

  cfg = require('../cfg/config.js');

  should = require('should');

  Browser = require('zombie');

  browser = new Browser;

  describe('Zombie is eating braiiiiinssssss', function() {
    var pageTitle;
    pageTitle = "Twitter Reading List";
    return it('Should be able to visit the homepage', function(done) {
      return browser.visit('http://localhost:3000', function(callback) {
        browser.success.should.equal(true);
        browser.text('title').should.equal(pageTitle);
        return done();
      });
    });
  });

  describe('Sessions', function() {
    var loggedInHtml, logoutHtml, pageTitle;
    pageTitle = "Twitter Reading List";
    logoutHtml = "<a href=\"/tw/login\">Sign In with Twitter</a><a href=\"#\" class=\"disabled\">Sign In with Readability</a>";
    loggedInHtml = "<a href=\"http://www.twitter.com/" + cfg.TW_USERNAME + "\" target=\"_blank\">" + cfg.TW_USERNAME + "</a><a href=\"/rdb/login\">Sign In with Readability</a>";
    it('Should be able to logout', function(done) {
      return browser.visit('http://localhost:3000', function(callback) {
        browser.success.should.equal(true);
        return browser.clickLink('logout', function() {
          browser.success.should.equal(true);
          browser.html('.auth #twitter a').should.equal(logoutHtml);
          return done();
        });
      });
    });
    return it('Should be able to login with Twitter', function(done) {
      this.timeout(30000);
      return browser.visit('http://localhost:3000', function(callback) {
        browser.success.should.equal(true);
        return browser.clickLink('Sign In with Twitter', function() {
          browser.success.should.equal(true);
          return browser.fill('session[username_or_email]', cfg.TW_USERNAME).fill('session[password]', cfg.TW_PASSWORD).pressButton('Sign In', function() {
            return browser.wait('20', function() {
              browser.statusCode.should.equal(200);
              return browser.clickLink('click here to continue', function() {
                browser.success.should.equal(true);
                browser.text('title').should.equal(pageTitle);
                browser.html('.auth #twitter a').should.equal(loggedInHtml);
                return done();
              });
            });
          });
        });
      });
    });
  });

}).call(this);
