assert = require 'assert'
fs = require 'fs'

db_path = 'test/baisc.db'

jdb = new (require '../') {
	db_path
	compact_db_file: false
	promise: true
	error: (err) ->
		if err
			console.error err
			process.exit 1
}

describe 'Basic: ', ->
	it 'set value should work', (tdone) ->
		jdb.exec
			command: (db) ->
				db.doc.a = 10
				db.save()
			callback: (err) ->
				tdone err if err
				tdone()

	it 'set value via data should work', (tdone) ->
		jdb.exec
			data: 10
			command: (db, data) ->
				db.doc.a = data
				db.save()

			callback: (err) ->
				tdone err if err
				tdone()

	it 'test promise should work', (tdone) ->
		jdb.exec
			data: 10
			command: (db, data) ->
				db.send db.doc.a
		.done (data) ->
			try
				assert.equal data, 10
				tdone()
			catch e
				tdone e

	it 'get value should work', (tdone) ->
		jdb.exec
			command: (db) ->
				db.send ++db.doc.a
			callback: (err, data) ->
				try
					assert.equal 11, data
					jdb.compact_db_file ->
						tdone()
				catch e
					tdone e

	it 'compact_db_file: the doc should be { a: 11 }', (tdone) ->
		str = fs.readFileSync db_path, 'utf8'
		eval str

		try
			assert.equal 11, jdb.doc.a
			tdone()
		catch e
			tdone e

	it 'closing db should be peaceful', (tdone) ->
		jdb.close ->
			fs.writeFile db_path, '\n\n', tdone
