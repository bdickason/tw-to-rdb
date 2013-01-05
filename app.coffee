express = require 'express'
cfg = require './cfg/config.js'
Twitter = (require './lib/twitter.js').Twitter
Readability = (require './lib/readability.js').Readability

Redis = require 'redis'
RedisStore = (require 'connect-redis')(express)

app = express()
app.use express.bodyParser()
app.use express.cookieParser()

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
  res.send "<HTML><BODY><A HREF='/tw'>Twitter: Get Favorites</A><br /><A HREF='/rdb/login'>Readability: Get Access Token</A></BODY></HTML>"

app.get '/logout', (req, res) ->
  # Allow the user to logout (clear local session)
  req.session.destroy()
  res.redirect '/'  

app.get '/tw', (req, res) ->
  tw.getFavorites 20, (callback) ->
    res.send callback
  
  
### Readability Auth to retrieve access tokens, etc. ###
app.get '/rdb/login', (req, res) ->
  # Allow user to login using Readability and collect request token
  rdb.login (callback) ->
    # Store oauth_token + secret in session
    req.session.oauth_token = callback.oauth_token
    req.session.oauth_token_secret = callback.oauth_token_secret
    res.redirect "https://www.readability.com/api/rest/v1/oauth/authorize/?oauth_token=#{callback.oauth_token}&oauth_token_secret=#{callback.oauth_token_secret}"

app.get '/rdb/callback', (req, res) ->
  rdb.handleCallback req.query.oauth_token, req.session.oauth_token_secret, req.query.oauth_verifier, (callback) ->
    req.session.oauth_access_token = callback.oauth_access_token
    req.session.oauth_access_token_secret = callback.oauth_access_token_secret
    res.send "<HTML><BODY><A HREF='/'>Home</A><BR /><BR /><STRONG>export RDB_ACCESS_TOKEN='#{req.session.oauth_access_token}'<BR />export RDB_ACCESS_TOKEN_SECRET='#{req.session.oauth_access_token_secret}</strong><br /><br /><em>Hint: copy/paste this into ~/.profile</BODY></HTML>"
  
### Support functions ###
checkTweets = =>
  console.log 'Checking tweets'
  count = 10  # Check last 10 tweets by default

  tw.getFavorites count, (callback) ->
    if callback.length > 0
      # There are tweets!
      for tweet in callback
        for url in tweet.entities.urls # Twitter creates an array of url's that have additional metadata
          rdb.addBookmark { url: url.expanded_url }, (callback) ->

### Start the App ###
app.listen '3000'

checkTweets -> # Run once immediately

###
# Trigger the loop to run every 4.01 mins. (Twitter rate limit is 15x/1hr aka every 4 minutes)
setInterval ->
  checkTweets
, 240000 # Run every 4 minutes aka 240,000ms
###
