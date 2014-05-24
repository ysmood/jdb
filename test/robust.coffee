fs = require 'fs'
assert = require 'assert'

db_path = 'test/robust.db'

jdb = new (require '../') {
	db_path
	promise: true
}

describe 'Handle exception', ->
	it 'the error should be catched properly', (tdone) ->
		jdb.exec
			command: (db) ->
				db.doc.a = 10
				db.doc.b = a
			callback: (err) ->
				if not err
					throw 'error not catched'
				else
					tdone()

	it 'should work with specific error', (tdone) ->
		jdb.exec
			command: (db) ->
				db.doc.a.un_defined = 10
		.catch (err) ->
			assert.equal err.message.indexOf('un_defined'), 21
		.done ->
			tdone()

	it 'the db should rollback properly', (tdone) ->
		jdb.exec
			command: (db) ->
				db.send db.doc.a
			callback: (err, data) ->
				if err or assert.equal(data, undefined)
					throw err
				else
					setTimeout(->
						fs.unlinkSync db_path
						tdone()
					, 100)
