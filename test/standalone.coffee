
spawn = require 'win-spawn'
assert = require 'assert'

port = 9023
server = null
max_retry = 10
retry_count = 0

start_server = ->
	server = spawn(
		'node'
		['bin/jdb.js', '-p', port]
		{ stdio: 'inherit' }
	)

	process.on 'SIGINT', ->
		exit()

exit = (code = 0) ->
	server.kill 'SIGINT'
	process.exit(code)

test_api = ->
	http = require 'http'
	cmd = '{ "data": 10, "command": "function(jdb, data) { jdb.doc.a = 1; jdb.save(jdb.doc); }" }'

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
			if data == '{"a":1}'
				console.log '\n>> Server test passed.'
				exit()
			else
				exit(1)

	req.on 'error', (e) ->
		retry_count++
		if retry_count > max_retry
			console.log '\n>> Max retried, server test failed.'
			exit(1)
			return

		span = 200
		setTimeout(test_api, span)
		console.log e.message, "Wait for #{span}ms and retry..."

	req.end cmd

start_server()

test_api()
