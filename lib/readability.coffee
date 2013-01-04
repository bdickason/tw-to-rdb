### Handle integration with Readability API ###
OAuth = (require 'oauth').OAuth

exports.Readability = class Readability
  constructor: (cfg, redis) ->
    @cfg = cfg  # Save config values
    @redis = redis
    
    # Generate oauth object
    @oa = oa = new OAuth 'https://www.readability.com/api/rest/v1/oauth/request_token/', 'https://www.readability.com/api/rest/v1/oauth/access_token/', @cfg.RDB_CONSUMER_KEY, @cfg.RDB_CONSUMER_SECRET, '1.0', 'http://localhost:3000/rdb/callback', 'HMAC-SHA1'
    console.log cfg.RDB_ACCESS_TOKEN
    console.log cfg.RDB_ACCESS_TOKEN_SECRET

  
  getBookmarks: (callback) ->
    @redis.hgetall "user:#{@cfg.TW_USERNAME}:Readability", (error, reply) =>
      if error
        console.log error
      else
        @oa.getProtectedResource 'https://www.readability.com/api/rest/v1/bookmarks', 'GET', reply.access_token, reply.access_token_secret, (error, data, response) ->
          if error
            console.log error
            callback 'Error: getting OAuth resource: '
          else
            callback data

  addBookmark: (item, callback) ->
    @redis.hgetall "user:#{@cfg.TW_USERNAME}:Readability", (error, reply) =>
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

    handleCallback:  (oauth_token, oauth_token_secret, oauth_verifier, callback) ->
      # Grab Access Token
      @oa.getOAuthAccessToken oauth_token, oauth_token_secret, oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, response) ->
        if error
          console.log 'error :' + JSON.stringify error
        if response is undefined
          console.log 'error: ' + response

        callback { oauth_access_token, oauth_access_token_secret }