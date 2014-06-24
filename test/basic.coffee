assert = require 'assert'

db_path = 'test/baisc.db'

jdb = new (require '../') {
	db_path
	compact_db_file: false
	promise: true
	error: (err) ->
		console.error err
}

describe 'set value', ->
	it 'should work without error', (tdone) ->
		jdb.exec
			command: (db) ->
				db.doc.a = 10
				db.save()
			callback: (err) ->
				tdone err if err
				tdone()

describe 'set value via data', ->
	it 'should work without error', (tdone) ->
		jdb.exec
			data: 10
			command: (db, data) ->
				db.doc.a = data
				db.save()

			callback: (err) ->
				tdone err if err
				tdone()

describe 'test promise', ->
	it 'should work without error', (tdone) ->
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

describe 'get value', ->
	it 'should work without error', (tdone) ->
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


describe 'compact_db_file', ->
	it 'the doc should be { a: 11 }', (tdone) ->
		fs = require 'fs'
		str = fs.readFileSync db_path, 'utf8'
		eval str

		try
			assert.equal 11, jdb.doc.a
			setTimeout(->
				fs.unlinkSync db_path
				tdone()
			, 100)
		catch e
			tdone e

