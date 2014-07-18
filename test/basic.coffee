assert = require 'assert'
fs = require 'fs'

db_path = 'test/baisc.db'

jdb = new (require '../') {
	db_path
	compact_db_file: false
	promise: true
	error: (err) ->
		if err
			console.error err.stack
			process.exit 1
}

try
	fs.unlinkSync db_path

describe 'Basic: ', ->
	it 'set value should work', (tdone) ->
		jdb.exec (db) ->
			db.doc.a = 10
			db.save()
		, (err) ->
			tdone err

	it 'set value via data should work', (tdone) ->
		jdb.exec
			data: 10
			command: (db, data) ->
				db.doc.a = data
				db.save()
			callback: (err) ->
				tdone err

	it 'test promise should work', (tdone) ->
		jdb.exec 10, (db, data) ->
			db.send db.doc.a
		.done (data) ->
			try
				assert.equal data, 10
				tdone()
			catch e
				tdone e

	it 'get value should work', (tdone) ->
		jdb.exec (db) ->
			db.send ++db.doc.a
		, (err, data) ->
			try
				assert.equal 11, data
				tdone()
			catch e
				tdone e

	it 'compact_db_file: the doc should be { a: 12 }', (tdone) ->
		"use strict"

		jdb.compact_db_file_sync()

		str = fs.readFileSync db_path, 'utf8'
		db = eval str + '; jdb;'

		try
			assert.equal 11, db.doc.a
			tdone()
		catch e
			tdone e

	it 'closing db should be peaceful', (tdone) ->
		jdb.close ->
			tdone()
