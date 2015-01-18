
kit = require 'nokit'
assert = require 'assert'

port = 8237
server = null
max_retry = 10
retry_count = 0

describe 'Standalone Mode:', ->
	before (tdone) ->
		server = kit.spawn(
			'node'
			['bin/jdb.js', '-p', port]
		).process
		setTimeout ->
			tdone()
		, 1000

	exit = ->
		server.kill 'SIGINT'

	it 'the server should return right value.', (tdone) ->
		http = require 'http'
		cmd = '{ "data": 10, "command": "function(jdb, data) { jdb.doc.ys = 1; jdb.save(jdb.doc); }" }'

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
				data = JSON.parse data
				try
					assert.equal data.ys, 1
					tdone()
				catch e
					tdone e
				finally
					exit()

		req.on 'error', (e) ->
			tdone e.message
			exit()

		req.end cmd
