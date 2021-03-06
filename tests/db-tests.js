// Generated by CoffeeScript 1.4.0

/* Tests for Database /lib/db
*/


(function() {
  var Db, cfg, db, should;

  cfg = require('../cfg/config.js');

  should = require('should');

  Db = (require('../lib/db.js')).Db;

  db = new Db(cfg);

  describe('Redis is running', function() {
    var testKey, testValue;
    testKey = 'testKey';
    testValue = 'testValue';
    it('Should be able to set a string', function(done) {
      return db.redis.set(testKey, testValue, done);
    });
    return it('Should be able to get the string we set', function(done) {
      return db.redis.get(testKey, function(error, data) {
        should.not.exist(error);
        data.should.equal(testValue);
        return done();
      });
    });
  });

  describe('Access Tokens', function() {
    var testAccessToken, testAccessTokenSecret, testApp, testUsername, testUsernameNew;
    testUsername = 'tester';
    testUsernameNew = 'tester2';
    testApp = 'TestApp';
    testAccessToken = '1234567890abcdef';
    testAccessTokenSecret = 'fedcba0987654321';
    it('Should be able to create a new account', function(done) {
      return db.createAccount(testUsername, testApp, function(error, reply) {
        should.not.exist.error;
        return done();
      });
    });
    it('Should be able to check if an existing account exists in the db', function(done) {
      return db.doesAccountExist(testUsername, testApp, function(error, reply) {
        should.not.exist.error;
        reply.should.equal(1);
        return done();
      });
    });
    it('Should be able to check if a new account exists in the db', function(done) {
      return db.doesAccountExist(testUsernameNew, testApp, function(error, reply) {
        should.not.exist.error;
        reply.should.equal(0);
        return done();
      });
    });
    it('Should be able to set an access token', function(done) {
      return db.setAccessTokens(testUsername, testApp, testAccessToken, testAccessTokenSecret, function(error, reply) {
        should.not.exist(error);
        return done();
      });
    });
    return it('Should be able to get the access token we set', function(done) {
      return db.getAccessTokens(testUsername, testApp, function(error, reply) {
        should.not.exist.error;
        reply.access_token.should.equal(testAccessToken);
        reply.access_token_secret.should.equal(testAccessTokenSecret);
        reply.active.should.equal('1');
        return done();
      });
    });
  });

}).call(this);
