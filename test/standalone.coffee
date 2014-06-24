
spawn = require 'win-spawn'
assert = require 'assert'

port = 8137
server = null
max_retry = 10
retry_count = 0

describe 'standalone mode test', ->
	# server = spawn(
	# 	'node'
	# 	['bin/jdb.js', '-p', port]
	# 	{ stdio: 'inherit' }
	# )

	exit = ->
		server.kill 'SIGINT'

	it 'the server should return right value.', (done) ->
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
						done()
					catch e
						done e
					finally
						exit()

			req.on 'error', (e) ->
				span = 200
				setTimeout(try_contact_api, span)
				console.error '>> Server:', e.message

			req.end cmd

		try_contact_api()
