assert = require 'assert'
fs = require 'fs'

db_path = 'test/baisc.db'

try
	fs.unlinkSync db_path

jdb = new (require '../')

describe 'Basic: ', ->
	before ->
		jdb.init {
			db_path
			compact_db_file: false
		}

	it 'set value', (tdone) ->
		jdb.exec (db) ->
			db.doc.a = 10
			db.save()
		, (err) ->
			tdone err

	it 'set value via data', (tdone) ->
		jdb.exec
			data: 10
			command: (db, data) ->
				db.doc.a = data
				db.save()
			callback: (err) ->
				tdone err

	it 'test promise', (tdone) ->
		jdb.exec 10, (db, data) ->
			db.send db.doc.a
		.done (data) ->
			try
				assert.equal data, 10
				tdone()
			catch e
				tdone e

	it 'get value', (tdone) ->
		jdb.exec (db) ->
			db.send ++db.doc.a
		, (err, data) ->
			try
				assert.equal 11, data
				tdone()
			catch e
				tdone e

	it 'compact_db_file', (tdone) ->
		"use strict"

		jdb.compact_db_file_sync()

		str = fs.readFileSync db_path, 'utf8'
		db = eval str + '; jdb;'

		try
			assert.equal 11, db.doc.a
			tdone()
		catch e
			tdone e

	it 'close db', ->
		jdb.close()
