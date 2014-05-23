Benchmark = require('benchmark')
suite = new Benchmark.Suite;
Benchmark.support.timeout = false

jdb = new (require '../')

suite

.add('* insert', {
	defer: true
	fn: (deferred) ->
		jdb.exec {
			command: (jdb) ->
				jdb.doc.arr ?= []
				jdb.doc.arr.push Math.random()
				jdb.save()
			callback: (err, data) ->
				deferred.resolve()
		}
})

.add('* query', {
	fn: ->
		jdb.exec {
			command: (jdb) ->
				jdb.send jdb.doc.arr.slice(0, Math.random() * 100)
			callback: (err, data) ->
		}
})

.on 'cycle', (e) ->
	console.log e.target.toString()
.on 'complete', (e) ->
	jdb.exit()
	fs = require 'fs'
	fs.unlink 'jdb.db'
.run()
