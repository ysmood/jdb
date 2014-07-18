fs = require 'fs'
assert = require 'assert'

db_path = 'test/robust.db'

jdb = new (require '../') {
	db_path
	promise: true
}

describe 'Handle exception', ->
	it 'the error should be catched properly', (tdone) ->
		jdb.exec (db) ->
			db.doc.a = 10
			db.doc.b = a
		, (err) ->
			if not err
				tdone 'error not catched'
			else
				tdone()

	it 'should work with specific error', (tdone) ->
		jdb.exec (db) ->
			db.doc.a.un_defined = 10
			db.save()
		.catch (err) ->
			try
				assert.equal err.message.indexOf('un_defined'), 21
				tdone
			catch e
				tdone e
		.done ->
			tdone()

	it 'the db should rollback properly', (tdone) ->
		jdb.exec (db) ->
			db.send db.doc.a
		, (err, data) ->
			if err or data == undefined
				tdone err
			else
				setTimeout(->
					fs.unlinkSync db_path
					tdone()
				, 100)
