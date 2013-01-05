# Redis usage

__Users__
Add a user: sadd users user:bdickason
List Users: smembers users

__Applicatons__
Add an application: sadd "user:bdickason" "Twitter"
List Applications: smembers user:bdickason
	
__Application Settings__
Add settings: hmset "user:bdickason:Twitter" "username" "bdickason" "access_token" "asjdkfajkhfjk132" "access_token_secret" "asjdfhj123hk"
List all settings: hgetall user:bdickason:Twitter
BAD. List keys: hkeys user:bdickason:Twitter
List values: hvals user:bdickason:Twitter

__Sessions__
Set userid by session: hset sessionID 120340104 user:bdickason
Get userid by session: hget sessionID 120340104 (returns:"user:bdickason")