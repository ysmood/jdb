Jdb = require '../app'
jdb = new Jdb

jdb.send_handler(
	(jdb, done) ->
		jdb.doc.a = 10
		done('asdf')
	(data) ->
		console.log data
)

