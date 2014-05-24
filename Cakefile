require 'coffee-script/register'
fs = require 'fs'
glob = require 'glob'
{ spawn } = require 'child_process'

get_right_bin = (cmd) ->
	if process.platform == 'win32'
		win_cmd = cmd + '.cmd'
		if fs.existsSync win_cmd
			cmd = win_cmd
		else if not fs.existsSync cmd
			cmd = which.sync(cmd)
	return cmd

coffee_bin = get_right_bin 'node_modules/.bin/coffee'
mocha_bin = get_right_bin 'node_modules/.bin/mocha'

task 'test', 'Basic test', ->
	spawn mocha_bin, [
		'-r'
		'coffee-script/register'
		'test/basic.coffee'
	], {
		stdio: 'inherit'
	}

	spawn mocha_bin, [
		'-r'
		'coffee-script/register'
		'test/robust.coffee'
	], {
		stdio: 'inherit'
	}

task 'benchmark', 'Performance benchmark', ->
	spawn coffee_bin, [
		'./benchmark/basic.coffee'
	], {
		stdio: 'inherit'
	}

task 'build', 'Compile coffee to js', ->
	console.log ">> Compile coffee..."

	spawn coffee_bin, [
		'-c'
		'lib'
	], {
		stdio: 'inherit'
	}

task 'publish_done', 'Clean js', ->
	console.log ">> Clean js..."

	glob.sync 'lib/**/*.js', (err, paths) ->
		for path in paths
			fs.unlinkSync path
