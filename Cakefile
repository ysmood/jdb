fs = require 'fs'
glob = require 'glob'


spawn: (cmd, args = [], options = {}) ->
	if process.platform == 'win32'
		cmd_ext = cmd + '.cmd'
		if fs.existsSync cmd_ext
			cmd = cmd_ext
		else
			which = kit._require 'which'
			cmd = which.sync(cmd)
		cmd = kit.path.normalize cmd

	deferred = Q.defer()

	opts = _.defaults options, { stdio: 'inherit' }

	{ spawn } = kit._require 'child_process'
	try
		ps = spawn cmd, args, opts
	catch err
		deferred.reject err

	ps.on 'error', (err) ->
		deferred.reject err

	deferred.promise.process = ps

	return deferred.promise


coffee_bin = 'node_modules/.bin/coffee'
mocha_bin = 'node_modules/.bin/mocha'

option '-n', '--no-server', 'Test without standalone test'
task 'test', 'Basic test', (options) ->
	list = [
		'test/basic.coffee'
		'test/robust.coffee'
		'test/standalone.coffee'
	]

	if options['no-server']
		list.splice 2, 1

	list.map (file) ->
		spawn(mocha_bin, [
			'-r'
			'coffee-script/register'
			file
		], { stdio: 'inherit' })
		.on 'exit', (code) ->
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
