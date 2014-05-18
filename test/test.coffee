assert = require 'assert'

Jdb = require '../'
jdb = new Jdb

describe 'set value', ->
	it 'should work without error', (tdone) ->
		jdb.exec((doc, done) ->
			doc.a = 10
			done()
		, (err) ->
			throw err if err
			tdone()
		)

describe 'get value', ->
	it 'should work without error', (tdone) ->
		jdb.exec((d, done) ->
			done ++d.a
		, (err, data) ->
			assert.equal 11, data

			jdb.compact_db_file ->
				tdone()
		)
