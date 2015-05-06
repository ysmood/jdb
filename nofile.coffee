kit = require 'nokit'

module.exports = (task) ->

	task 'test', 'Basic test', ->
		kit.spawn('mocha', [
			'-r'
			'coffee-script/register'
			'-R', 'spec'
			'test/*.coffee'
		]).catch ({ code }) ->
			process.exit code

	task 'benchmark', 'Performance benchmark', ->
		kit.spawn 'coffee', [
			'./benchmark/basic.coffee'
		]

	task 'build', 'Compile coffee to js', ->
		kit.log "Compile coffee..."

		kit.spawn 'coffee', [
			'-cb'
			'lib'
		]

	task 'clean', 'Clean js', ->
		kit.log "Clean js..."

		kit.remove 'lib', { filter: '**/*.js' }

	task 'dev', 'Start test server', ->
		kit.monitorApp {
			args: ['./bin/jdb.js']
			watchList: ['lib/*.coffee', 'bin/jdb.js']
		}
