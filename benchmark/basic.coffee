Benchmark = require('benchmark')
suite = new Benchmark.Suite
Benchmark.support.timeout = false

jdb = require('../')()

count = 0

suite

.add('* insert', {
	defer: true
	fn: (deferred) ->
		jdb.exec {
			command: (jdb) ->
				jdb.doc.arr[count++] = Math.random()
				jdb.save()
			callback: (err, data) ->
				return deferred.reject err if err
				deferred.resolve()
		}
})

.add('* query', {
	fn: ->
		val = jdb.doc.arr.slice 0, Math.random() * 100
})

.on 'cycle', (e) ->
	console.log e.target.toString()
.on 'complete', (e) ->
	fs = require 'fs'
	fs.unlink 'jdb.db'


jdb.init({ promise: false }).then ->
	jdb.exec (jdb) ->
		jdb.doc.arr = []
		jdb.save()

	suite.run()
