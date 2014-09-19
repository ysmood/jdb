fs = require 'fs'
glob = require 'glob'
{ spawn } = require './lib/kit'

coffee_bin = 'node_modules/.bin/coffee'
mocha_bin = 'node_modules/.bin/mocha'

task 'test', 'Basic test', (options) ->
	spawn(mocha_bin, [
		'-r'
		'coffee-script/register'
		'-R', 'spec'
		'test/*.coffee'
	], { stdio: 'inherit' })
	.process.on 'exit', (code) ->
		if code != 0
			process.exit code

task 'benchmark', 'Performance benchmark', ->
	spawn coffee_bin, [
		'./benchmark/basic.coffee'
	], {
		stdio: 'inherit'
	}

task 'build', 'Compile coffee to js', ->
	console.log ">> Compile coffee..."

	spawn coffee_bin, [
		'-cb'
		'lib'
	], {
		stdio: 'inherit'
	}

task 'clean', 'Clean js', ->
	console.log ">> Clean js..."

	glob.sync 'lib/**/*.js', (err, paths) ->
		for path in paths
			fs.unlinkSync path

task 'dev', 'Start test server', ->
	ps = null
	# Redirect process io to stdio.
	start = ->
		ps = spawn 'node', [
			'./bin/jdb.js'
		], {
			stdio: 'inherit'
		}

	start()

	[
		'lib/*.coffee'
		'bin/jdb.js'
	].forEach (pattern) ->
		paths = glob.sync pattern

		paths.forEach (path) ->
			fs.watchFile(
				path
				{ persistent: false, interval: 500 }
				(curr, prev) ->
					if curr.mtime != prev.mtime
						console.log ">> Modified: " + path
						ps.exit()
						start()
			)
