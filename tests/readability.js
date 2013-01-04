// Generated by CoffeeScript 1.4.0

/* Tests for Readability /lib/readability
*/


(function() {
  var Readability, cfg, rdb, should;

  cfg = require('../cfg/config.js');

  should = require('should');

  Readability = (require('../lib/readability.js')).Readability;

  rdb = new Readability(cfg);

  describe('Readability connection', function() {
    it('Can retrieve your bookmarks', function(done) {
      return rdb.getBookmarks(function(callback) {
        return done();
      });
    });
    return it('Successfully adds an item to your list', function(done) {
      var item;
      item = {
        url: "http://braddickason.com/my-daily-checklist/"
      };
      return rdb.addBookmark(item, function(callback) {
        return done();
      });
    });
  });

}).call(this);
