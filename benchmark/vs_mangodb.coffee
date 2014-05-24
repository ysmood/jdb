Benchmark = require('benchmark')
suite = new Benchmark.Suite;
Benchmark.support.timeout = false

MongoClient = require('mongodb').MongoClient

MongoClient.connect 'mongodb://127.0.0.1:27017/test', (err, db) ->
	collection = db.collection 'test_db'

	suite
	.add('* insert', {
		defer: true
		fn: (deferred) ->
			collection.insert { a: Math.random() }, (err, docs) ->
				deferred.resolve()
	})
	.add('* query', {
		defer: true
		fn: (deferred) ->
			collection.find().limit(Math.random() * 100).toArray (err, docs) ->
				deferred.resolve()
	})
	.on 'cycle', (e) ->
		console.log e.target.toString()
	.on 'complete', (e) ->
		db.close()
	.run()
