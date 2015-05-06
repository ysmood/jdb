fs = require 'fs'
assert = require 'assert'

dbPath = 'test/robust.db'

try
	fs.unlinkSync dbPath

Jdb = require('../lib/jdb')
jdb = Jdb()

describe 'Handle exception:', ->
	before ->
		jdb.init {
			dbPath
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
				.then (a) ->
					assert.equal a, 0
					tdone()

	it 'broken db', (tdone) ->
		jdb = Jdb()
		jdb.init {
			dbPath: 'test/fixtures/broken'
			compactDBFile: false
		}
		.catch (err) ->
			assert.equal jdb.doc.a, 10
			tdone()
