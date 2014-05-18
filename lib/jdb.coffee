
class JDB.Jdb then constructor: (options) ->

	# Public
	self = {

		exec: (handler, callback) ->
			id = Date.now() + ego.callback_list_count++

			ego.callback_list[id] = callback if callback

			ego.daemon.send {
				type: 'handler'
				id: id
				handler: handler.toString(-1)
			}

	}

	# Private
	ego = {

		callback_list: {}
		callback_list_count: 0
		daemon: null
		opts: {
			db_path: 'jdb.db'
		}

		init: ->
			ego.init_options()
			ego.init_jworker()

		init_options: ->
			return if not options

			for k, v of ego.opts
				ego.opts[k] = options[k] if options[k]

		init_jworker: ->
			child_process = require 'child_process'
			process.env.JDB_launch = 'jworker'
			process.env.JDB_db_path = ego.opts.db_path

			ego.daemon = child_process.fork __dirname + '/../app.js'

			ego.daemon.on 'message', (msg) ->
				switch msg.type
					when 'error'
						console.log msg.message
						console.log msg.stack

					when 'callback'
						ego.callback_list[msg.id] msg.data
						delete ego.callback_list[msg.id]

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self
