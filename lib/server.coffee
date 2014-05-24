
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

		opts: require './commander'

		init: ->
			ego.init_options()

		init_options: ->
			ego.opts
			.option '-d, --db-path <path>', 'Data base file path'
			.option '-p, --port <port>', 'Port to listen to. Default is 8137'
			.option '--host <host>', 'Host to listen to. Default is 127.0.0.1 only'
			.option '-c, --compact-db-file', 'Whether compact db file at start up or not'
			.parse process.argv

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self

