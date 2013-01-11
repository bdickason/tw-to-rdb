### Creates a timer to manage queues ###

exports.Timer = class Timer
  constructor: (user_name, cfg, db, tw, rdb) ->
    @cfg = cfg
    @db = db
    @tw = tw
    @rdb = rdb
    
    @id = user_name
    @active = false
    @interval = {}
    
    console.log "New timer created for user: #{user_name}"
      
  startTimer: (time, callback) ->
    error = null
    if @active is true
      console.log "Timer #{@id} is already started"
      error = "Error: Timer is already started"
      callback "Error: Timer is already started"
    else
      console.log "Starting Timer for user: #{@id}"
      # Timer is stopped, let's go!
      @active = true
      @interval = setInterval =>
        @checkTweets (callback) ->
          
      , time
      callback error, "Done!"
  
  stopTimer: (callback) ->
    if @active is false
      console.log "Timer is already stopped"
      callback "Error: Timer is already stopped"

    else
      # Timer is started, let's stop it!
      @active = false
      clearInterval @interval
      callback "Done."
      
  ### Support functions ###
  checkTweets: (callback) =>
    count = 10  # Check last 10 tweets by default
    @tw.getFavorites @id, count, (callback) =>
      console.log "Checking Tweets for: #{@id}"
      if callback.length > 0
        # There are tweets!
        for tweet in callback
          for url in tweet.entities.urls # Twitter creates an array of url's that have additional metadata
            @rdb.addBookmark @id, { url: url.expanded_url }, (cb) ->