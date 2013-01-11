### Creates a timer to manage ###

exports.Timer = class Timer
  constructor: (user_name, cfg, db) ->
    @cfg = cfg
    @db = db
    
    @id = user_name
    @active = false
    @interval = {}
      
  startTimer: (time, callback) ->
    error = null
    if @active is true
      console.log "Timer is already started"
      callback "Error: Timer is already started"

    else
      # Timer is stopped, let's go!
      @active = true
      @interval = setInterval =>
        console.log @id
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