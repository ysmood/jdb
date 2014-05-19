Benchmark = require('benchmark')
suite = new Benchmark.Suite;
Benchmark.support.timeout = false

jdb = new (require '../')

suite.add('# insert', {
	defer: true
	fn: (deferred) ->
		jdb.exec {
			command: (jdb) ->
				jdb.doc.a = 10
				jdb.save()
			callback: (err, data) ->
				deferred.resolve()
		}
}).on 'cycle', (e) ->
	console.log e.target.toString()
.on 'complete', (e) ->
	jdb.exit()
	fs = require 'fs'
	fs.unlink 'jdb.db'
.run()
