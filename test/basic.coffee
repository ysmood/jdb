assert = require 'assert'

db_path = 'test/baisc.db'

jdb = new (require '../') { db_path }

describe 'set value', ->
	it 'should work without error', (tdone) ->
		jdb.exec((db) ->
			db.doc.a = 10
			db.save()
		, (err) ->
			throw err if err
			tdone()
		)

describe 'set value', ->
	it 'should work without error', (tdone) ->
		jdb.exec((db) ->
			db.doc.a = 10
			db.save()
		, (err) ->
			# throw err if err
			tdone()
		)

describe 'get value', ->
	it 'should work without error', (tdone) ->
		jdb.exec((db) ->
			db.send ++db.doc.a
		, (err, data) ->
			assert.equal 11, data

			jdb.compact_db_file ->
				tdone()
		)

describe 'compact_db_file', ->
	it 'the doc should be { a: 11 }', (tdone) ->
		fs = require 'fs'
		str = fs.readFileSync db_path, 'utf8'
		eval str
		assert.equal 11, jdb.doc.a

		setTimeout(->
			fs.unlinkSync db_path
			tdone()
		, 100)
