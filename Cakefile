require 'coffee-script/register'
{ spawn } = require 'child_process'

task 'test', 'Basic test', ->
	test = spawn 'mocha', [
		'-r'
		'coffee-script/register'
		'test/basic.coffee'
	], {
		stdio: 'inherit'
	}

	test = spawn 'mocha', [
		'-r'
		'coffee-script/register'
		'test/robust.coffee'
	], {
		stdio: 'inherit'
	}

