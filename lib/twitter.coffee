### Handle integration with Twitter API ###
OAuth = (require 'oauth').OAuth

exports.Twitter = class Twitter
  constructor: (cfg, redis) ->
    @cfg = cfg
    @redis = redis
  
    # Generate oauth object
    @oa = oa = new OAuth 'request_url', 'access_url', @cfg.TW_CONSUMER_KEY, @cfg.TW_CONSUMER_SECRET, '1.0', 'http://localhost:3000/tw/callback', 'HMAC-SHA1'
    
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