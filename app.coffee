express = require 'express'
cfg = require './cfg/config.js'
Twitter = (require './lib/twitter.js').Twitter
  
app = express()
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session
  secret: 'blahblahblah'  # Random hash for session store

### Controllers ###
tw = new Twitter

### Routes ###      
      
app.get '/', (req, res) ->
  tw.getFavorites (callback) ->
    res.send callback
  
app.get '/logout', (req, res) ->
  # Allow the user to logout (clear local cookies)
  console.log '--- LOGOUT ---'
  console.log req.session
  console.log '--- LOGOUT ---'
  req.session.destroy()
  res.redirect '/'  

### Start the App ###

app.listen '3000'
