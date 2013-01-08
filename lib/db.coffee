### Data models and interface with Redis ###
Redis = require 'redis'

exports.Db = class Db
  constructor: (cfg) ->
    # Start up redis
    @redis = Redis.createClient cfg.REDIS_PORT, cfg.REDIS_HOSTNAME
    @redis.on 'error', (err) ->
      console.log 'REDIS Error:' + err

  getAccessTokens: (user_name, app_name, callback) ->
    if user_name and app_name
      @redis.hgetall "user:#{user_name}:#{app_name}", (error, reply) =>
        callback error, reply
    else
      callback "Error."
      