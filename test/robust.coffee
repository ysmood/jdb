fs = require 'fs'
assert = require 'assert'

db_path = 'test/robust.db'

jdb = new (require '../') { db_path }

describe '# Handle exception', ->
	it 'the error should be catched properly', (tdone) ->
		jdb.exec((doc, send) ->
			doc.a = 10
			doc.b = a
			send()
		, (err) ->
			if not err
				throw 'error not catched'
			else
				tdone()
		)

	it 'handlers follows the error one should work poperly', (tdone) ->
		jdb.exec((doc, send) ->
			send doc.a
		, (err, data) ->
			if err or assert.equal(data, 10)
				throw err
			else
				setTimeout(->
					fs.unlinkSync db_path
					tdone()
				, 100)
		)
