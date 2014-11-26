fs = require 'fs'
assert = require 'assert'

dbPath = 'test/robust.db'

try
	fs.unlinkSync dbPath

jdb = new (require '../')

describe 'Handle exception:', ->
	before ->
		jdb.init {
			dbPath
			promise: true
		}

	it 'catch error', (tdone) ->
		jdb.exec (db) ->
			db.doc.b.a = 0
		, (err) ->
			if not err
				tdone 'error not catched'
			else
				tdone()

	it 'specific error', (tdone) ->
		jdb.exec (db) ->
			db.doc.a.un_defined = 10
			db.save()
		.catch (err) ->
			try
				assert.equal err.message.indexOf('un_defined'), 21
				tdone()
			catch e
				tdone e
		.done()

	it 'rollback', (tdone) ->
		jdb.exec (db) ->
			db.doc.a = 0
			db.save()
		.then ->
			jdb.exec (db) ->
				db.doc.a = 10
				db.doc.b.a = 0
		.catch (err) ->
			err.promise.then ->
				jdb.exec (db) ->
					db.send db.doc.a
				.done (a) ->
					assert.equal a, 0
					tdone()
