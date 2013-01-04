### Configuration file - Set your Readabiliy/Twitter variables here ###

# Twitter Developer Keys
exports.TW_CONSUMER_KEY = process.env.TW_CONSUMER_KEY || ''
exports.TW_CONSUMER_SECRET = process.env.TW_CONSUMER_SECRET || ''

exports.TW_ACCESS_TOKEN = process.env.TW_ACCESS_TOKEN || ''
exports.TW_ACCESS_TOKEN_SECRET = process.env.TW_ACCESS_TOKEN_SECRET || ''

exports.TW_USERNAME = process.env.TW_USERNAME || ''

# Readability Developer Keys
exports.RDB_CONSUMER_KEY = process.env.RDB_CONSUMER_KEY || ''
exports.RDB_CONSUMER_SECRET = process.env.RDB_CONSUMER_SECRET || ''

exports.RDB_ACCESS_TOKEN = process.env.RDB_ACCESS_TOKEN || ''
exports.RDB_ACCESS_TOKEN_SECRET = process.env.RDB_ACCESS_TOKEN_SECRET || ''

# Redis Setup
exports.REDIS_PORT = process.env.REDIS_PORT || '6379'
exports.REDIS_HOSTNAME = process.env.REDIS_HOSTNAME || 'localhost'