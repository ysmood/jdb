Benchmark = require('benchmark')
suite = new Benchmark.Suite;
Benchmark.support.timeout = false

nedb = new (require 'nedb') { filename: 'nedb.db', autoload: true }

suite
.add('* insert', {
	defer: true
	fn: (deferred) ->
		nedb.insert { a: Math.random() }, (err) ->
			return deferred.reject err if err
			deferred.resolve()
})

.add('* query', {
	defer: true
	fn: (deferred) ->
		nedb.find({}).limit(Math.random() * 100).exec (err, docs) ->
			return deferred.reject err if err
			deferred.resolve()
})

.on 'cycle', (e) ->
	console.log e.target.toString()
.on 'complete', (e) ->
	fs = require 'fs'
	fs.unlink 'nedb.db'
.run()
