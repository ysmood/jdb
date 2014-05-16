Jdb = require '../'
jdb = new Jdb

# Save value.
jdb.exec (jdb) ->
	jdb.doc.a = 10

# Get value.
jdb.exec((jdb, done) ->
	done jdb.doc.a
, (data) ->
	console.log data
)
