// Generated by CoffeeScript 1.4.0
(function() {
  var Db, Readability, RedisStore, Twitter, app, cfg, checkTweets, db, express, rdb, tw,
    _this = this;

  express = require('express');

  cfg = require('./cfg/config.js');

  Twitter = (require('./lib/twitter.js')).Twitter;

  Readability = (require('./lib/readability.js')).Readability;

  Db = (require('./lib/db.js')).Db;

  RedisStore = (require('connect-redis'))(express);

  app = express();

  app.use(express.bodyParser());

  app.use(express.cookieParser());

  app.set('views', __dirname + '/views');

  app.set('view engine', 'jade');

  app.use(express["static"](__dirname + '/static'));

  app.use(express.session({
    store: new RedisStore({
      'db': '1',
      maxAge: 1209600000
    }),
    secret: 'blahblahblah'
  }));

  /* Controllers
  */


  db = new Db(cfg);

  tw = new Twitter(cfg, db);

  rdb = new Readability(cfg, db);

  /* Routes
  */


  app.get('/', function(req, res) {
    var user_name;
    user_name = null;
    if (req.session.tw) {
      if (req.session.tw.user_name) {
        user_name = req.session.tw.user_name;
      }
    }
    return res.render('index', {
      "session": req.session,
      "user_name": user_name
    });
  });

  app.get('/check', function(req, res) {
    checkTweets(req.session.tw.user_name);
    console.log("Checking Tweets");
    return res.redirect('/');
  });

  app.get('/status', function(req, res) {});

  app.get('/logout', function(req, res) {
    req.session.destroy();
    return res.redirect('/');
  });

  app.get('/tw', function(req, res) {
    return tw.getFavorites(req.session.tw.user_name, 20, function(callback) {
      return res.send(callback);
    });
  });

  app.get('/rdb', function(req, res) {
    return rdb.getBookmarks(req.session.tw.user_name, function(callback) {
      return res.send(callback);
    });
  });

  /* Readability Auth to retrieve access tokens, etc.
  */


  app.get('/tw/login', function(req, res) {
    return tw.login(function(callback) {
      if (!req.session.tw) {
        req.session.tw = {};
      }
      req.session.tw.oauth_token = callback.oauth_token;
      req.session.tw.oauth_token_secret = callback.oauth_token_secret;
      return res.redirect("https://api.twitter.com/oauth/authenticate?oauth_token=" + callback.oauth_token + "&oauth_token_secret=" + callback.oauth_token_secret);
    });
  });

  app.get('/tw/callback', function(req, res) {
    if (req.query.denied) {
      return res.redirect('/');
    } else {
      return tw.handleCallback(req.query.oauth_token, req.session.tw.oauth_token_secret, req.query.oauth_verifier, function(callback) {
        var _this = this;
        req.session.tw.user_name = callback.user_name;
        return db.redis.sismember("user:" + callback.user_name, "Twitter", function(error, reply) {
          if (reply !== 1) {
            console.log("adding new Twitter account for user: " + callback.user_name);
            db.redis.sadd("users", "user:" + callback.user_name, function(error) {
              return db.redis.sadd("user:" + callback.user_name, "Twitter", function(error) {
                if (error) {
                  return console.log("Error: " + error);
                }
              });
            });
          }
          return db.setAccessTokens(req.session.tw.user_name, "Twitter", callback.oauth_access_token, callback.oauth_access_token_secret, function(error, reply) {
            if (error) {
              return console.log("Error: " + error);
            } else {
              console.log(reply);
              req.session.tw.active = 1;
              return res.redirect('/');
            }
          });
        });
      });
    }
  });

  /* Readability Auth to retrieve access tokens, etc.
  */


  app.get('/rdb/login', function(req, res) {
    return rdb.login(function(callback) {
      if (!req.session.rdb) {
        req.session.rdb = {};
      }
      req.session.rdb.oauth_token = callback.oauth_token;
      req.session.rdb.oauth_token_secret = callback.oauth_token_secret;
      return res.redirect("https://www.readability.com/api/rest/v1/oauth/authorize/?oauth_token=" + callback.oauth_token + "&oauth_token_secret=" + callback.oauth_token_secret);
    });
  });

  app.get('/rdb/callback', function(req, res) {
    return rdb.handleCallback(req.query.oauth_token, req.session.rdb.oauth_token_secret, req.query.oauth_verifier, function(callback) {
      var _this = this;
      return db.redis.sismember("user:" + cfg.TW_USERNAME, "Readability", function(error, reply) {
        if (reply !== 1) {
          console.log("adding Readability account for user: " + cfg.TW_USERNAME);
          db.redis.sadd("user:" + cfg.TW_USERNAME, "Readability", function(error) {
            if (error) {
              return console.log("Error: " + error);
            }
          });
        }
        return db.setAccessTokens(req.session.tw.user_name, "Readability", callback.oauth_access_token, callback.oauth_access_token_secret, function(error, reply) {
          if (error) {
            return console.log("Error: " + error);
          } else {
            req.session.tw.active = 1;
            return res.redirect('/');
          }
        });
      });
    });
  });

  /* Support functions
  */


  checkTweets = function(user_name, callback) {
    var count;
    count = 10;
    return tw.getFavorites(user_name, count, function(callback) {
      var tweet, url, _i, _len, _results;
      if (callback.length > 0) {
        _results = [];
        for (_i = 0, _len = callback.length; _i < _len; _i++) {
          tweet = callback[_i];
          _results.push((function() {
            var _j, _len1, _ref, _results1;
            _ref = tweet.entities.urls;
            _results1 = [];
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              url = _ref[_j];
              _results1.push(rdb.addBookmark(user_name, {
                url: url.expanded_url
              }, function(cb) {}));
            }
            return _results1;
          })());
        }
        return _results;
      }
    });
  };

  /* Start the App
  */


  app.listen("" + cfg.PORT);

  /*
  # Trigger the loop to run every 4.01 mins. (Twitter rate limit is 1x/min)
  setInterval ->
    checkTweets
  , 70000 # Run every 1.17 minutes aka 70,000ms
  */


}).call(this);
