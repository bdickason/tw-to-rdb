### Configuration file - Set your Readabiliy/Twitter variables here ###

# Twitter Developer Keys
exports.TW_CONSUMER_KEY = process.env.TW_CONSUMER_KEY || ''
exports.TW_CONSUMER_SECRET = process.env.TW_CONSUMER_SECRET || ''

exports.TW_USERNAME = process.env.TW_USERNAME || ''

# Readability Developer Keys
exports.RDB_CONSUMER_KEY = process.env.RDB_CONSUMER_KEY || ''
exports.RDB_CONSUMER_SECRET = process.env.RDB_CONSUMER_SECRET || ''

# Redis Setup
exports.REDIS_PORT = process.env.REDIS_PORT || '6379'
exports.REDIS_HOSTNAME = process.env.REDIS_HOSTNAME || 'localhost'

# Server Setup
exports.HOSTNAME = process.env.HOSTNAME || 'localhost'
exports.PORT = process.env.PORT || '3000'


### Only needed for test suite ###
# Twitter Password
exports.TW_PASSWORD = process.env.TW_PASSWORD || ''
# Readability Login
# Readability Password