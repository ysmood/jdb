Jdb = require '../'
jdb = new Jdb

console.log jdb

# Save value.
jdb.exec (doc) ->
	doc.a ?= 0
	doc = null

# Get value.
jdb.exec((d, done) ->
	done ++d.a
, (data) ->
	console.log data
)
