require 'coffee-script/register'
{ spawn } = require 'child_process'

task 'test', 'Basic test', ->
	spawn 'mocha', [
		'-r'
		'coffee-script/register'
		'test/test.coffee'
	], {
		stdio: 'inherit'
	}
