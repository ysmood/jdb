
require '../'

###
    JDB.Server
###
class JDB.Server then constructor: ->

	# Public
	self = {

	}

	# Private
	ego = {

		opts: {
			db_path: 'jdb.db'
			port: 8137
			host: '127.0.0.1'
			compact_db_file: true
			config_path: null
		}

		init: ->
			ego.init_options()

			ego.jdb = new JDB.Jdb ego.opts

			ego.init_server()

		init_options: ->
			commander = require 'commander'
			commander
			.usage '[options] [config.json or config.js]'
			.option '-d, --db_path <path>', 'Data base file path'
			.option '-p, --port <port>', 'Port to listen to. Default is ' + ego.opts.port, parseInt
			.option '--host <host>', "Host to listen to. Default is #{ego.opts.host} only"
			.option '-c, --compact_db_file <true>', 'Whether compact db file at start up or not', (data) ->
				data == 'true'
			.option '-v, --ver', 'Print JDB version'
			.parse process.argv

			if commander.ver
				conf = require '../package'
				console.log 'JDB v' + conf.version
				process.exit()

			if commander.args[0]
				ego.opts.config_path = commander.args[0]

			if ego.opts.config_path
				config = require ego.opts.config_path

			defaults = (opts) ->
				return if not opts
				for k, v of ego.opts
					if opts[k]
						ego.opts[k] = opts[k]

			defaults config
			defaults commander

		init_server: ->
			http = require 'http'
			ego.server = http.createServer ego.init_routes
			ego.server.listen ego.opts.port, ego.opts.host

			ego.log "Listen: #{ego.opts.host}:#{ego.opts.port}"

		init_routes: (req, res) ->
			ht = { req, res }

			switch req.url
				when '/exec'
					ego.exec ht

				when '/compact_db_file'
					ego.compact_db_file ht

				else
					ego.not_found ht

		log: (msg, level = 0) ->
			console.log ">>", msg

		send: (ht, body = '', status = 200, type = 'application/json') ->
			ht.res.writeHead status, {
				'Content-Type': type
				'Content-Length': body.length
			}
			ht.res.end body

		exec: (ht) ->
			body = ''
			ht.req.on 'data', (chunk) -> body += chunk
			ht.req.on 'end', ->
				try
					cmd = JSON.parse body
				catch e
					ego.send ht, "JSON syntax error: \n" + body, 500
					return

				if not cmd.command
					ego.send ht, 'Empty command', 403
					return

				try
					command = eval "(#{cmd.command})"
				catch e
					ego.send ht, 'Command syntax error: \n' + cmd.command, 500
					return

				ego.jdb.exec
					data: cmd.data
					command: command
					callback: (err, data) ->
						if err
							ego.send ht, JSON.stringify(
								{ error: err.message }
							), 500
						else
							ego.send ht, JSON.stringify(data or 'ok')

		compact_db_file: (ht) ->
			ego.jdb.compact_db_file (err) ->
				if err
					ego.send ht, JSON.stringify(
						{ error: err.message }
					), 500
				else
					ego.send ht, 'OK'

		not_found: (ht) ->
			ego.send ht, 'not found', 404
	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self

