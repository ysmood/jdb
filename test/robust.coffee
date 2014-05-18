fs = require 'fs'
assert = require 'assert'

db_path = 'test/robust.db'

jdb = new (require '../') { db_path }

describe 'Handle exception', ->
	it 'the error should be catched properly', (tdone) ->
		jdb.exec((db) ->
			db.doc.a = 10
			db.doc.b = a
		, (err) ->
			if not err
				throw 'error not catched'
			else
				tdone()
		)

	it 'the db should rollback properly', (tdone) ->
		jdb.exec((db) ->
			db.send db.doc.a
		, (err, data) ->
			if err or assert.equal(data, undefined)
				throw err
			else
				setTimeout(->
					fs.unlinkSync db_path
					tdone()
				, 100)
		)
