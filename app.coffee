express = require 'express'
cfg = require './cfg/config.js'
Twitter = (require './lib/twitter.js').Twitter
Readability = (require './lib/readability.js').Readability

app = express()
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session
  secret: 'blahblahblah'  # Random hash for session store

### Controllers ###
tw = new Twitter
rdb = new Readability

### Routes ###      
app.get '/', (req, res) ->
  res.send "<HTML><BODY><A HREF='/tw'>Twitter: Get Favorites</A><br /><A HREF='/rdb/login'>Readability: Get Access Token</A></BODY></HTML>"
  
app.get '/tw', (req, res) ->
  
  checkTweets req, res
    
  # Trigger the loop to run every 4.01 mins. (Twitter rate limit is 15x/1hr aka every 4 minutes)
  setInterval ->
    checkTweets req, res
  , 24000 # Run every 4 minutes aka 240,000ms

  
app.get '/logout', (req, res) ->
  # Allow the user to logout (clear local cookies)
  req.session.destroy()
  res.redirect '/'  
  
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
  
### Start the App ###
app.listen '3000'


checkTweets = (req, res) =>
  console.log 'Checking tweets'
  count = 10  # Check last 10 tweets by default
  if !req.session.lastFavorite
    count = 20 # Checking the first time so grab last 20 tweets.

  tw.getFavorites count, (callback) ->
    if callback.length > 0
      # There are tweets!
      for tweet in callback
        for url in tweet.entities.urls # Twitter creates an array of url's that have additional metadata
          rdb.addBookmark { url: url.expanded_url }, (callback) ->
            
      req.session.lastFavorite = true
