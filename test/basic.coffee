assert = require 'assert'
fs = require 'fs'

dbPath = 'test/baisc.db'

try
	fs.unlinkSync dbPath

jdb = require('../lib/jdb')()

describe 'Basic: ', ->
	before ->
		jdb.init {
			dbPath
			compactDBFile: false
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

	it 'get value', ->
		assert.equal jdb.doc.a + 1, 11

	it 'compactDBFileSync', (tdone) ->
		"use strict"

		jdb.compactDBFileSync()

		str = fs.readFileSync dbPath, 'utf8'
		db = eval str + '; jdb;'

		try
			assert.equal db.doc.a, 10
			tdone()
		catch e
			tdone e

	it 'compactDBFile', (tdone) ->
		"use strict"

		jdb.exec (jdb) ->
			jdb.doc.a = 12
			jdb.save()
		.then ->
			jdb.compactDBFile()
		.done ->
			str = fs.readFileSync dbPath, 'utf8'
			db = eval str + '; jdb;'

			try
				assert.equal 12, db.doc.a
				tdone()
			catch e
				tdone e

	it 'close db', ->
		jdb.close()
