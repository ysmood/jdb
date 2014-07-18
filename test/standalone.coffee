
{ spawn } = require '../lib/kit'
assert = require 'assert'

port = 8237
server = null
max_retry = 10
retry_count = 0

describe 'standalone mode test', ->
	server = spawn(
		'node'
		['bin/jdb.js', '-p', port]
		{ stdio: 'inherit' }
	).process

	exit = ->
		server.kill 'SIGINT'

	it 'the server should return right value.', (tdone) ->
		try_contact_api = ->
			http = require 'http'
			cmd = '{ "data": 10, "command": "function(jdb, data) { jdb.doc.a = 1; jdb.save(jdb.doc.a); }" }'

			req = http.request {
				host: '127.0.0.1'
				port: port
				path: '/exec'
				method: 'POST'
			}, (res) ->
				data = ''
				res.on 'data', (chunk) ->
					data += chunk

				res.on 'end', ->
					try
						assert.equal data, 1
						tdone()
					catch e
						tdone e
					finally
						exit()

			req.on 'error', (e) ->
				tdone e.message
				exit()

			req.end cmd

		setTimeout try_contact_api, 1000
