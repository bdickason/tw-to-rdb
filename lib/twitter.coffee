### Handle integration with Twitter API ###
cfg = require '../cfg/config.js'
OAuth = (require 'oauth').OAuth

exports.Twitter = class Twitter
  constructor: ->
    # Generate oauth object
    
    @oa = oa = new OAuth 'request_url', 'access_url', cfg.TW_CONSUMER_KEY, cfg.TW_CONSUMER_SECRET, '1.0', 'http://localhost:3000/tw/callback', 'HMAC-SHA1'
    
  getFavorites: (callback) ->
    @oa.getProtectedResource 'https://api.twitter.com/1.1/favorites/list.json', 'GET', cfg.TW_ACCESS_TOKEN, cfg.TW_ACCESS_TOKEN_SECRET, (error, data, response) ->
      if error
        callback 'Error: getting OAuth resource: ' + error
      else
        callback data
  
  
  getFavoritesFrom: (since, callback) ->
    console.log since
    @oa.getProtectedResource "https://api.twitter.com/1.1/favorites/list.json?since_id=#{since}", 'GET', cfg.TW_ACCESS_TOKEN, cfg.TW_ACCESS_TOKEN_SECRET, (error, data, response) ->
      if error
        callback 'Error: getting OAuth resource: '
        console.log error
      else
        callback JSON.parse data
    