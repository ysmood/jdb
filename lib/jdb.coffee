
class JDB.Jdb then constructor: (options) ->

	# Public
	self = {

		exec: (opts) ->
			if not opts.command
				return

			id = ego.callback_uid()

			# TODO: it may result in memory leak.
			ego.callback_list[id] = ->
				opts.callback?.apply this, arguments

			ego.jworker.send {
				type: 'command'
				id
				command: opts.command.toString(-1)
				data: opts.data
			}

		compact_db_file: (callback) ->
			id = ego.callback_uid()

			ego.callback_list[id] = callback if callback

			ego.jworker.send {
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

		exit: ->
			ego.jworker.kill('SIGINT')
	}

	# Private
	ego = {

		callback_list: {}
		callback_list_count: 0
		jworker: null
		opts: {
			db_path: 'jdb.db'
			compact_db_file: true
		}

		init: ->
			ego.init_options()
			ego.init_jworker()

		init_options: ->
			return if not options

			for k, v of ego.opts
				ego.opts[k] = options[k] if options[k] != undefined

		callback_uid: ->
			ego.callback_list_count++

		init_jworker: ->
			child_process = require 'child_process'

			env = {
				JDB_launch: 'jworker'
				JDB_db_path: ego.opts.db_path
				JDB_compact_db_file: ego.opts.compact_db_file
			}
			for k, v of process.env
				env[k] = v

			ego.jworker = child_process.fork(
				__dirname + '/../app.js'
				[]
				{ env }
			)

			ego.jworker.on 'message', (msg) ->
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
