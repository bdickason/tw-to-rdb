### Data models and interface with Redis ###
Redis = require 'redis'

exports.Db = class Db
  constructor: (cfg) ->
    # Start up redis
    @redis = Redis.createClient cfg.REDIS_PORT, cfg.REDIS_HOSTNAME
    @redis.on 'error', (err) ->
      console.log 'REDIS Error:' + err

  
  setAccessTokens: (user_name, app_name, access_token, access_token_secret, callback) ->
    if user_name and app_name
      @redis.hmset "user:#{user_name}:#{app_name}", "access_token", access_token, "access_token_secret", access_token_secret, "active", 1, (error, reply) ->
        callback error, reply
    else
      if !user_name
        callback "Error: User Name not set"
      else if !app_name
        callback "Error: App Name not set"
        
  getAccessTokens: (user_name, app_name, callback) ->
    if user_name and app_name
      @redis.hgetall "user:#{user_name}:#{app_name}", (error, reply) =>
        callback error, reply
    else
      if !user_name
        callback "Error: User Name not set"
      else if !app_name
        callback "Error: App Name not set"
      
  doesAccountExist: (user_name, app_name, callback) ->
    if user_name and app_name
      @redis.sismember "user:#{user_name}", app_name, (error, reply) =>
        callback error, reply
    else
      if !user_name
        callback "Error: User Name not set"
      else if !app_name
        callback "Error: App Name not set"        
  
  createAccount: (user_name, app_name, callback) ->
    if user_name and app_name
      @redis.sadd "users", "user:#{user_name}", (error, reply) =>
        @redis.sadd "user:#{user_name}", app_name, (error, reply) =>
          callback error, reply
    else
      if !user_name
        callback "Error: User Name not set"
      else if !app_name
        callback "Error: App Name not set"        
