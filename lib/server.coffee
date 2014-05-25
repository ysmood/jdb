
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
			net = require 'net'
			ego.server = new net.Server

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self

