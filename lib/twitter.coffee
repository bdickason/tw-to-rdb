### Handle integration with Twitter API ###
OAuth = (require 'oauth').OAuth

exports.Twitter = class Twitter
  constructor: (cfg, db) ->
    @cfg = cfg
    @db = db
    @appname = "Twitter"
  
    # Generate oauth object
    @oa = oa = new OAuth 'https://api.twitter.com/oauth/request_token', 'https://api.twitter.com/oauth/access_token', @cfg.TW_CONSUMER_KEY, @cfg.TW_CONSUMER_SECRET, '1.0', "http://#{@cfg.HOSTNAME}:#{@cfg.PORT}/tw/callback", 'HMAC-SHA1'
    
  getFavorites: (user_name, count, callback) ->
    @db.getAccessTokens user_name, @appname, (error, reply) =>
      console.log reply
      if error
        console.log error
      else
        @oa.getProtectedResource 'https://api.twitter.com/1.1/favorites/list.json?count=#{count}', 'GET', reply.access_token, reply.access_token_secret, (error, data, response) ->
          if error
            console.log error
            callback 'Error: getting OAuth resource: ' + error
          else
            callback JSON.parse data
  
  login: (callback) ->
      console.log 'Getting OAuth Request Token'
      @oa.getOAuthRequestToken (error, oauth_token, oauth_token_secret, results) =>
        if error
          console.log 'error :' + JSON.stringify error
                  
        callback { oauth_token, oauth_token_secret }

  handleCallback:  (oauth_token, oauth_token_secret, oauth_verifier, callback) ->
    # Grab Access Token
    @oa.getOAuthAccessToken oauth_token, oauth_token_secret, oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, response) =>
      if error
        console.log 'error :' + JSON.stringify error
      else if !response
        console.log 'error: ' + response

      user_name = response.screen_name

      @db.doesAccountExist user_name, @appname, (error, reply) =>
        if reply != 1  # User hasn't auth'd with twitter before
          console.log "adding new #{@appname} account for user: #{user_name}"
          @db.createAccount user_name, @appname, (error) =>
            if error
              console.log "Error: " + error 
        @db.setAccessTokens user_name, @appname, oauth_access_token, oauth_access_token_secret, (error, reply) =>
          if error
            console.log "Error: " + error
          callback error, { oauth_access_token, oauth_access_token_secret, "user_name": user_name }