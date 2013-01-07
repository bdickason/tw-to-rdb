express = require 'express'
cfg = require './cfg/config.js'
Twitter = (require './lib/twitter.js').Twitter
Readability = (require './lib/readability.js').Readability

Redis = require 'redis'
RedisStore = (require 'connect-redis')(express)

app = express()
app.use express.bodyParser()
app.use express.cookieParser()
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.static __dirname + '/static'  

app.use express.session
  store: new RedisStore # Populates req.session, req.sessionStore, req.sessionID
    'db': '1'
    maxAge: 1209600000 # 14 day max age
  secret: 'blahblahblah'  # Random hash for session store

# Start up redis
redis = Redis.createClient cfg.REDIS_PORT, cfg.REDIS_HOSTNAME
redis.on 'error', (err) ->
  console.log 'REDIS Error:' + err


### Controllers ###
tw = new Twitter cfg, redis
rdb = new Readability cfg, redis

### Routes ###      
app.get '/', (req, res) ->
  user_name = null
  if req.session.tw
    if req.session.tw.user_name
      user_name = req.session.tw.user_name
  res.render 'index', { "session": req.session, "user_name": user_name }

app.get '/check', (req, res) ->
  # Check for new favorites, save to readability
  checkTweets()
  console.log "Checking Tweets"
  res.redirect '/'
    
app.get '/logout', (req, res) ->
  # Allow the user to logout (clear local session)
  req.session.destroy()
  res.redirect '/'  

app.get '/tw', (req, res) ->
  tw.getFavorites 20, (callback) ->
    res.send callback

app.get '/rdb', (req, res) ->
  rdb.getBookmarks (callback) ->
    res.send callback
  

### Readability Auth to retrieve access tokens, etc. ###
app.get '/tw/login', (req, res) ->
  # Allow user to login using Twitter and collect request token
  tw.login (callback) ->
    # Store oauth_token + secret in session
    if !req.session.tw
      req.session.tw = {}
    req.session.tw.oauth_token = callback.oauth_token
    req.session.tw.oauth_token_secret = callback.oauth_token_secret
    res.redirect "https://api.twitter.com/oauth/authenticate?oauth_token=#{callback.oauth_token}&oauth_token_secret=#{callback.oauth_token_secret}"

app.get '/tw/callback', (req, res) ->
  tw.handleCallback req.query.oauth_token, req.session.tw.oauth_token_secret, req.query.oauth_verifier, (callback) ->
    req.session.tw.user_name = callback.user_name
    redis.sismember "user:#{callback.user_name}", "Twitter", (error, reply) =>
      if reply != 1  # User hasn't auth'd with twitter before
        console.log "adding new Twitter account for user: #{callback.user_name}"
        redis.sadd "users", "user:#{callback.user_name}", (error) =>
          redis.sadd "user:#{callback.user_name}", "Twitter", (error) =>      
            if error
              console.log "Error: " + error
      redis.hmset "user:#{callback.user_name}:Twitter", "access_token", callback.oauth_access_token, "access_token_secret", callback.oauth_access_token_secret, (error, reply) ->
        if error
          console.log "Error: " + error
        else
          res.redirect '/'

### Readability Auth to retrieve access tokens, etc. ###
app.get '/rdb/login', (req, res) ->
  # Allow user to login using Readability and collect request token
  rdb.login (callback) ->
    if !req.session.rdb
      req.session.rdb = {}

    # Store oauth_token + secret in session
    req.session.rdb.oauth_token = callback.oauth_token
    req.session.rdb.oauth_token_secret = callback.oauth_token_secret
    res.redirect "https://www.readability.com/api/rest/v1/oauth/authorize/?oauth_token=#{callback.oauth_token}&oauth_token_secret=#{callback.oauth_token_secret}"

app.get '/rdb/callback', (req, res) ->
  rdb.handleCallback req.query.oauth_token, req.session.rdb.oauth_token_secret, req.query.oauth_verifier, (callback) ->
    redis.sismember "user:#{cfg.TW_USERNAME}", "Readability", (error, reply) =>
      if reply != 1  # User hasn't auth'd with readability before
        console.log "adding Readability account for user: #{cfg.TW_USERNAME}"
        redis.sadd "user:#{cfg.TW_USERNAME}", "Readability", (error) ->      
          if error
            console.log "Error: " + error
      redis.hmset "user:#{cfg.TW_USERNAME}:Readability", "access_token", callback.oauth_access_token, "access_token_secret", callback.oauth_access_token_secret, (error, reply) ->
        if error
          console.log "Error: " + error
        else
          res.redirect '/'
  
### Support functions ###
checkTweets = (callback) =>
  count = 10  # Check last 10 tweets by default

  tw.getFavorites count, (callback) ->
    if callback.length > 0
      # There are tweets!
      for tweet in callback
        for url in tweet.entities.urls # Twitter creates an array of url's that have additional metadata
          rdb.addBookmark { url: url.expanded_url }, (cb) ->      
      
### Start the App ###
app.listen '3000'

# checkTweets -> # Run once immediately

###
# Trigger the loop to run every 4.01 mins. (Twitter rate limit is 15x/1hr aka every 4 minutes)
setInterval ->
  checkTweets
, 240000 # Run every 4 minutes aka 240,000ms
###
