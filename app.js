// Generated by CoffeeScript 1.4.0
(function() {
  var Readability, Redis, RedisStore, Twitter, app, cfg, checkTweets, express, rdb, redis, tw,
    _this = this;

  express = require('express');

  cfg = require('./cfg/config.js');

  Twitter = (require('./lib/twitter.js')).Twitter;

  Readability = (require('./lib/readability.js')).Readability;

  Redis = require('redis');

  RedisStore = (require('connect-redis'))(express);

  app = express();

  app.use(express.bodyParser());

  app.use(express.cookieParser());

  app.set('views', __dirname + '/views');

  app.set('view engine', 'jade');

  app.use(express["static"](__dirname + '/public'));

  app.use(express.session({
    store: new RedisStore({
      'db': '1',
      maxAge: 1209600000
    }),
    secret: 'blahblahblah'
  }));

  redis = Redis.createClient(cfg.REDIS_PORT, cfg.REDIS_HOSTNAME);

  redis.on('error', function(err) {
    return console.log('REDIS Error:' + err);
  });

  /* Controllers
  */


  tw = new Twitter(cfg, redis);

  rdb = new Readability(cfg, redis);

  /* Routes
  */


  app.get('/', function(req, res) {
    return res.render('index', {
      "session": req.session
    });
  });

  app.get('/check', function(req, res) {
    checkTweets();
    console.log("Checking Tweets");
    return res.redirect('/');
  });

  app.get('/logout', function(req, res) {
    req.session.destroy();
    return res.redirect('/');
  });

  app.get('/tw', function(req, res) {
    return tw.getFavorites(20, function(callback) {
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
    return tw.handleCallback(req.query.oauth_token, req.session.tw.oauth_token_secret, req.query.oauth_verifier, function(callback) {
      var _this = this;
      req.session.tw.user_name = callback.user_name;
      return redis.sismember("user:" + callback.user_name, "Twitter", function(error, reply) {
        if (reply !== 1) {
          console.log("adding new Twitter account for user: " + callback.user_name);
          redis.sadd("users", "user:" + callback.user_name, function(error) {
            return redis.sadd("user:" + callback.user_name, "Twitter", function(error) {
              if (error) {
                return console.log("Error: " + error);
              }
            });
          });
        }
        return redis.hmset("user:" + callback.user_name + ":Twitter", "access_token", callback.oauth_access_token, "access_token_secret", callback.oauth_access_token_secret, function(error, reply) {
          if (error) {
            return console.log("Error: " + error);
          } else {
            return res.send("<HTML><BODY><A HREF='/'>Home</A><BR /><BR />                    <STRONG>export TW_ACCESS_TOKEN='" + callback.oauth_access_token + "'<BR />          export TW_ACCESS_TOKEN_SECRET='" + callback.oauth_access_token_secret + "'</strong><br /><br />                    <em>Hint: copy/paste this into ~/.profile          </BODY></HTML>");
          }
        });
      });
    });
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
      return redis.sismember("user:" + cfg.TW_USERNAME, "Readability", function(error, reply) {
        if (reply !== 1) {
          console.log("adding Readability account for user: " + cfg.TW_USERNAME);
          redis.sadd("user:" + cfg.TW_USERNAME, "Readability", function(error) {
            if (error) {
              return console.log("Error: " + error);
            }
          });
        }
        return redis.hmset("user:" + cfg.TW_USERNAME + ":Readability", "access_token", callback.oauth_access_token, "access_token_secret", callback.oauth_access_token_secret, function(error, reply) {
          if (error) {
            return console.log("Error: " + error);
          } else {
            return res.send("<HTML><BODY>          <A HREF='/'>Home</A><BR /><BR />                    <STRONG>export RDB_ACCESS_TOKEN='" + callback.oauth_access_token + "'<BR />          export RDB_ACCESS_TOKEN_SECRET='" + callback.oauth_access_token_secret + "'</strong><br /><br />                    <em>Hint: copy/paste this into ~/.profile          </BODY></HTML>");
          }
        });
      });
    });
  });

  /* Support functions
  */


  checkTweets = function(callback) {
    var count;
    count = 10;
    return tw.getFavorites(count, function(callback) {
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
              _results1.push(rdb.addBookmark({
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


  app.listen('3000');

  /*
  # Trigger the loop to run every 4.01 mins. (Twitter rate limit is 15x/1hr aka every 4 minutes)
  setInterval ->
    checkTweets
  , 240000 # Run every 4 minutes aka 240,000ms
  */


}).call(this);
