fs = require 'fs'
readline = require 'readline'

path = 'test/fixtures/file.txt'


rl = readline.createInterface {
	input: fs.createReadStream path, {
		encoding: 'utf8'
	}
	output: process.stdout
	terminal: false
}

w = fs.createWriteStream path, { flags: 'a' }

w.write 'write\n'
w.write 'write\n'

rl.on 'line', (line) ->
	console.log line

rl.on 'close', ->
	fs.writeFileSync path, 'a\nb\nc\n'

