
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
				str = fs.readFileSync ego.db_path, 'utf8'
				try
					eval str
					ego.doc = doc if typeof doc == 'object'
				catch err
					process.send {
						type: 'db_file_error'
						message: err.message
						stack: err.stack
					}

			else
				ego.compact_db_file()

		compact_db_file: (id) ->
			try
				fs.writeFileSync(
					ego.db_path
					"""
						var doc = #{JSON.stringify(ego.doc)},
							send = function () {};\n
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

			send = (data) ->
				process.send {
					type: 'callback'
					id
					data
				}

			cmd = "(#{handler})(doc, send);\n"

			try
				eval cmd
			catch err
				process.send {
					type: 'callback'
					id
					error: {
						message: err.message
						stack: err.stack
					}
				}

			fs.appendFile ego.db_path, cmd
	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self
