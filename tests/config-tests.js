// Generated by CoffeeScript 1.4.0

/* Tests for Config /cfg
*/


(function() {
  var cfg, should;

  cfg = require('../cfg/config.js');

  should = require('should');

  describe('Twitter credentials', function() {
    it('Should have a consumer key', function() {
      var tmp;
      tmp = cfg.TW_CONSUMER_KEY;
      return tmp.should.not.eql('');
    });
    it('Should have a consumer secret', function() {
      var tmp;
      tmp = cfg.TW_CONSUMER_SECRET;
      return tmp.should.not.eql('');
    });
    return it('Should have a twitter username set', function() {
      var tmp;
      tmp = cfg.TW_USERNAME;
      return tmp.should.not.eql('');
    });
  });

  describe('Readability credentials', function() {
    it('Should have a consumer key', function() {
      var tmp;
      tmp = cfg.RDB_CONSUMER_KEY;
      return tmp.should.not.eql('');
    });
    return it('Should have a consumer secret', function() {
      var tmp;
      tmp = cfg.RDB_CONSUMER_SECRET;
      return tmp.should.not.eql('');
    });
  });

  describe('Server Config', function() {
    it('Should have a hostname', function() {
      var tmp;
      tmp = cfg.HOSTNAME;
      return tmp.should.not.eql('');
    });
    return it('Should have a port number', function() {
      var tmp;
      tmp = cfg.PORT;
      return tmp.should.not.eql('');
    });
  });

}).call(this);
