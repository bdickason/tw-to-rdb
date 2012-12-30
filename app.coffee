express = require 'express'
cfg = require './cfg/config.js'
  
app = express()
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.session
  secret: 'blahblahblah'  # Random hash for session store

### Controllers ###

### Routes ###      
      
app.get '/', (req, res) ->
    

app.get '/logout', (req, res) ->
  # Allow the user to logout (clear local cookies)
  console.log '--- LOGOUT ---'
  console.log req.session
  console.log '--- LOGOUT ---'
  req.session.destroy()
  res.redirect '/'  

### Start the App ###

app.listen '3000'
