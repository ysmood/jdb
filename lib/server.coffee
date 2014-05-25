
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
			ego.init_server()

		init_options: ->
			commander = require 'commander'
			commander
			.usage '[options] [config_path.json or config_path.js]'
			.option '-d, --db_path <path>', 'Data base file path'
			.option '-p, --port <port>', 'Port to listen to. Default is ' + ego.opts.port, parseInt
			.option '--host <host>', "Host to listen to. Default is #{ego.opts.host} only"
			.option '-c, --compact_db_file', 'Whether compact db file at start up or not'
			.parse process.argv

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

			console.log ">> Listen: #{ego.opts.host}:#{ego.opts.port}"

		init_routes: (req, res) ->
			console.log req.url

			ht = { req, res }

			switch req.url
				when '/favicon.ico'
					ego.favicon ht

				when '/exec'
					ego.exec ht

				else
					ego.not_found ht

		send: (ht, body = '', status = 200, type = 'application/json') ->
			ht.res.writeHead status, {
				'Content-Type': type
				'Content-Length': body.length
			}
			ht.res.end body

		favicon: (ht) ->
			smallest_gif = new Buffer('R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==', 'base64')
			ego.send ht, smallest_gif, 200, 'image/x-icon'

		exec: (ht) ->
			ego.send ht, 'jdb'

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

