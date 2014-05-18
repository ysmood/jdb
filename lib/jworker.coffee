
class JDB.Jworker then constructor: (options) ->
	# Public
	self = {}

	# Private
	fs = require 'fs'

	ego = {

		doc: {}

		db_path: process.env.JDB_db_path

		init: ->
			ego.init_messager()

			ego.init_db_file()

		init_messager: ->
			process.on 'uncaughtException', (err) ->
				process.send {
					type: 'uncaught_exception'
					message: err.message
					stack: err.stack
				}

			process.on 'message', (msg) ->
				switch msg.type
					when 'handler'
						ego.handle_command msg.handler, msg.id

					when 'compact_db_file'
						ego.compact_db_file msg.id

		init_db_file: ->
			if fs.existsSync ego.db_path
				ego.load_data()
			else
				ego.compact_db_file()

		load_data: ->
			str = fs.readFileSync ego.db_path, 'utf8'
			try
				eval str
				ego.doc = jdb.doc if typeof jdb.doc == 'object'
			catch err
				process.send {
					type: 'db_parsing_error'
					message: err.message
					stack: err.stack
				}

		compact_db_file: (id) ->
			try
				fs.writeFileSync(
					ego.db_path
					"""
						var jdb = {
							doc: #{JSON.stringify(ego.doc)},
							send: function () {}
						};\n
					"""
				)
			catch e
				error = e

			process.send {
				type: 'callback'
				id
				error
			}

		handle_command: (handler, id) ->
			doc = ego.doc

			is_sent = false

			is_rolled_back = false

			jdb = {
				doc: ego.doc

				send: (data) ->
					if is_sent
						return
					else
						is_sent = true

					process.send {
						type: 'callback'
						id
						data
					}

				save: (data) ->
					return if is_rolled_back

					if not is_sent
						jdb.send data

					fs.appendFile ego.db_path, jdb.cmd

				rollback: ->
					ego.load_data()
					is_rolled_back = true
			}

			# cmd is immutable.
			Object.defineProperty jdb, 'cmd', {
				configurable: false
				get: -> "(#{handler})(jdb);\n"
			}

			try
				eval jdb.cmd
			catch err
				jdb.rollback()

				process.send {
					type: 'callback'
					id
					error: {
						message: err.message
						stack: err.stack
					}
				}

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self
