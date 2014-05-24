Benchmark = require('benchmark')
suite = new Benchmark.Suite;
Benchmark.support.timeout = false

redis = require 'redis'
client = redis.createClient()

count = 0

suite
.add('* insert', {
	defer: true
	fn: (deferred) ->
		client.set count++, Math.random(), ->
			deferred.resolve()
})

.add('* query', {
	defer: true
	fn: (deferred) ->
		client.get Math.floor(Math.random() * count), (err, data) ->
			deferred.resolve()
})

.on 'cycle', (e) ->
	console.log e.target.toString()
.on 'complete', (e) ->
	client.end()
.run()
