Jdb = require '../'
jdb = new Jdb

# Save value.
jdb.exec (doc) ->
	doc.a = 10
	doc = null

# Get value.
jdb.exec((d, done) ->
	done ++d.a
, (data) ->
	console.log data
)
