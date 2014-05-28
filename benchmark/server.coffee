Benchmark = require('benchmark')
suite = new Benchmark.Suite;
Benchmark.support.timeout = false
http = require 'http'

suite

.add('* exec', {
	fn: (deferred) ->
		req = http.request {
			hostname: '127.0.0.1'
			port: 8137
			path: '/exec'
			method: 'POST'
		}, (res) ->
			res.on 'data', (data) ->
				data

		req.end JSON.stringify command: ((jdb) ->
			jdb.doc.a++
			jdb.save()
		).toString()
})

.on 'cycle', (e) ->
	console.log e.target.toString()
.on 'complete', (e) ->
	console.log "Done"
.run()
