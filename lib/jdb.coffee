
class JDB.Jdb then constructor: (options) ->

	# Public
	self = {

		exec: (handler, callback) ->
			if not handler
				return

			id = ego.callback_uid()

			ego.callback_list[id] = ->
				callback?.apply this, arguments

			ego.daemon.send {
				type: 'handler'
				id
				handler: handler.toString(-1)
			}

		compact_db_file: (callback) ->
			id = ego.callback_uid()

			ego.callback_list[id] = callback if callback

			ego.daemon.send {
				type: 'compact_db_file'
				id
			}

		uncaught_exception: (msg) ->
			console.error msg.type
			console.error msg.message
			console.error msg.stack

		db_parsing_error: (msg) ->
			console.error msg.type
			console.error msg.message
			console.error msg.stack

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

		callback_uid: ->
			ego.callback_list_count++

		init_jworker: ->
			child_process = require 'child_process'
			process.env.JDB_launch = 'jworker'
			process.env.JDB_db_path = ego.opts.db_path

			ego.daemon = child_process.fork __dirname + '/../app.js'

			ego.daemon.on 'message', (msg) ->
				switch msg.type
					when 'uncaught_exception'
						self.uncaught_exception msg

					when 'db_parsing_error'
						self.db_parsing_error msg

					when 'callback'
						if typeof msg.id != 'undefined'
							ego.callback_list[msg.id] msg.error, msg.data
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
