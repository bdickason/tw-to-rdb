express = require 'express'
cfg = require './cfg/config.js'
Twitter = (require './lib/twitter.js').Twitter
Readability = (require './lib/readability.js').Readability
Db = (require './lib/db.js').Db

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



### Controllers ###
db = new Db cfg
tw = new Twitter cfg, db
rdb = new Readability cfg, db

### Routes ###      
app.get '/', (req, res) ->
  user_name = null
  if req.session.tw
    if req.session.tw.user_name
      user_name = req.session.tw.user_name
  res.render 'index', { "session": req.session, "user_name": user_name }

app.get '/check', (req, res) ->
  # Check for new favorites, save to readability
  checkTweets(req.session.tw.user_name)
  console.log "Checking Tweets"
  res.redirect '/'
  
app.get '/status', (req, res) ->
  # Admin debug screen to show all active timers
  
    
app.get '/logout', (req, res) ->
  # Allow the user to logout (clear local session)
  req.session.destroy()
  res.redirect '/'  

app.get '/tw', (req, res) ->
  tw.getFavorites req.session.tw.user_name, 20, (callback) ->
    res.send callback

app.get '/rdb', (req, res) ->
  rdb.getBookmarks req.session.tw.user_name, (callback) ->
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
  if req.query.denied
    # Twitter denied auth or user hit cancel
    res.redirect '/'
  else    
    tw.handleCallback req.query.oauth_token, req.query.oauth_token_secret, req.query.oauth_verifier, (error, callback) ->
      console.log callback
      req.session.tw.oauth_access_token = callback.oauth_access_token
      req.session.tw.oauth_access_token_secret = callback.oauth_access_token_secret
      req.session.tw.user_name = callback.user_name
      req.session.tw.active = 1
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
    db.doesAccountExist req.session.tw.user_name, "Readability", (error, reply) =>
      if reply != 1  # User hasn't auth'd with Readability before
        console.log "adding new Readability account for user: #{req.session.tw.user_name}"
        db.createAccount req.session.tw.user_name, "Readability", (error) =>
          if error
            console.log "Error: " + error
      db.setAccessTokens req.session.tw.user_name, "Readability", callback.oauth_access_token, callback.oauth_access_token_secret, (error, reply) =>
        if error
          console.log "Error: " + error
        else
          req.session.rdb.active = 1
          res.redirect '/'
  
### Support functions ###
checkTweets = (user_name, callback) =>
  count = 10  # Check last 10 tweets by default
  tw.getFavorites user_name, count, (callback) ->
    if callback.length > 0
      # There are tweets!
      for tweet in callback
        for url in tweet.entities.urls # Twitter creates an array of url's that have additional metadata
          rdb.addBookmark user_name, { url: url.expanded_url }, (cb) ->      
      
### Start the App ###
app.listen "#{cfg.PORT}"

# checkTweets -> # Run once immediately

###
# Trigger the loop to run every 4.01 mins. (Twitter rate limit is 1x/min)
setInterval ->
  checkTweets
, 70000 # Run every 1.17 minutes aka 70,000ms
###
