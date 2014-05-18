Jdb = require '../'
jdb = new Jdb

# Save value.
jdb.exec (doc) ->
	doc.a ?= 0

# Get value.
jdb.exec((d, done) ->
	done ++d.a
, (err, data) ->
	console.log data

	jdb.compact_db_file ->
		process.exit()
)
