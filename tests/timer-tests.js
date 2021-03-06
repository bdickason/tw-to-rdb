// Generated by CoffeeScript 1.4.0

/* Tests for Timers /lib/timer
*/


(function() {
  var Db, Timer, cfg, db, should;

  cfg = require('../cfg/config.js');

  should = require('should');

  Db = (require('../lib/db.js')).Db;

  db = new Db(cfg);

  Timer = (require('../lib/timer.js')).Timer;

  describe('Timers', function() {
    var user_name;
    user_name = "testuser";
    it('Should be able to start a timer', function(done) {
      var timer;
      timer = new Timer(user_name, cfg, db);
      return timer.startTimer(500, function(error, callback) {
        should.not.exist(error);
        timer.id.should.equal(user_name);
        callback.should.equal('Done!');
        return done();
      });
    });
    return it('Should be able to stop a timer', function(done) {
      return done();
    });
  });

}).call(this);
