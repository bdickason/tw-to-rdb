### Handle integration with Readability API ###
OAuth = (require 'oauth').OAuth

exports.Readability = class Readability
  constructor: (cfg, db) ->
    @cfg = cfg  # Save config values
    @db = db
    @appname = "Readability"
    
    # Generate oauth object
    @oa = oa = new OAuth 'https://www.readability.com/api/rest/v1/oauth/request_token/', 'https://www.readability.com/api/rest/v1/oauth/access_token/', @cfg.RDB_CONSUMER_KEY, @cfg.RDB_CONSUMER_SECRET, '1.0', "http://#{@cfg.HOSTNAME}:#{@cfg.PORT}/rdb/callback", 'HMAC-SHA1'

  getBookmarks: (user_name, callback) ->
    @db.getAccessTokens user_name, @appname, (error, reply) =>
      if error
        console.log error
      else 
        @oa.getProtectedResource 'https://www.readability.com/api/rest/v1/bookmarks', 'GET', reply.access_token, reply.access_token_secret, (error, data, response) ->
          if error
            console.log error
            callback 'Error: getting OAuth resource: '
          else
            callback data

  addBookmark: (user_name, item, callback) ->
    @db.getAccessTokens user_name, @appname, (error, reply) =>
      if error
        console.log error
      else
        @oa.post 'https://www.readability.com/api/rest/v1/bookmarks', reply.access_token, reply.access_token_secret, item, (error, data, response) ->
          if error
            if error.statusCode = 409
              # Item already exists
              callback "Warning: Item already exists."
            else
              console.log error
              callback 'Error: getting OAuth resource.'
          else
            # Success!
            console.log "Successfully added: "
            console.log item
            callback data
        
        
  login: (callback) ->
      console.log 'Getting OAuth Request Token'
      @oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) ->
        if error
          console.log 'error :' + JSON.stringify error

        callback { oauth_token, oauth_token_secret }

  handleCallback: (user_name, oauth_token, oauth_token_secret, oauth_verifier, callback) =>
    # We use twitter usernames to identify users (user_name)
    # Grab Access Token
    @oa.getOAuthAccessToken oauth_token, oauth_token_secret, oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, response) =>
      if error
        console.log 'error :' + JSON.stringify error
      if !response
        console.log 'error: ' + response
      @db.doesAccountExist user_name, @appname, (error, reply) =>
        if reply != 1  # User hasn't auth'd with twitter before
          console.log "adding new #{@appname} account for user: #{user_name}"          
          @db.createAccount user_name, @appname, (error) =>
            if error
              console.log "Error: " + error 
        @db.setAccessTokens user_name, @appname, oauth_access_token, oauth_access_token_secret, (error, reply) =>
          if error
            console.log "Error: " + error
          callback error, { oauth_access_token, oauth_access_token_secret }