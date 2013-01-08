### Handle integration with Twitter API ###
OAuth = (require 'oauth').OAuth

exports.Twitter = class Twitter
  constructor: (cfg, redis) ->
    @cfg = cfg
    @redis = redis
  
    # Generate oauth object
    @oa = oa = new OAuth 'https://api.twitter.com/oauth/request_token', 'https://api.twitter.com/oauth/access_token', @cfg.TW_CONSUMER_KEY, @cfg.TW_CONSUMER_SECRET, '1.0', "http://#{@cfg.HOSTNAME}:#{@cfg.PORT}/tw/callback", 'HMAC-SHA1'
    
    console.log 
  getFavorites: (count, callback) ->
    
    @redis.hgetall "user:#{@cfg.TW_USERNAME}:Twitter", (error, reply) =>
      if error
        console.log error
      else
        @oa.getProtectedResource 'https://api.twitter.com/1.1/favorites/list.json?count=#{count}', 'GET', reply.access_token, reply.access_token_secret, (error, data, response) ->
          if error
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
    @oa.getOAuthAccessToken oauth_token, oauth_token_secret, oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, response) ->
      if error
        console.log 'error :' + JSON.stringify error
      if response is undefined
        console.log 'error: ' + response

      callback { oauth_access_token, oauth_access_token_secret, "user_name": response.screen_name }