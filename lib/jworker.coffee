
class JDB.Jworker then constructor: (options) ->
	# Public
	self = {

	}

	# Private
	ego = {
		doc: {}

		db_path: process.env.JDB_db_path

		init: ->
			ego.init_handlers()

			ego.init_db_file()

		init_handlers: ->
			process.on 'uncaughtException', (err) ->
				process.send {
					type: 'error'
					message: err.message
					stack: err.stack
				}

			process.on 'message', (msg) ->
				switch msg.type
					when 'handler'
						ego.handle_command msg.handler, msg.id

		init_db_file: ->
			fs = require 'fs'

			if fs.existsSync ego.db_path
				str = fs.readFileSync ego.db_path, 'utf8'
				eval str
				ego.doc = doc

			fs.writeFileSync(
				ego.db_path
				"""
					var doc = #{JSON.stringify(ego.doc)},
						callback = function () {};
				"""
			)

		handle_command: (handler, id) ->
			fs = require 'fs'

			callback = (data) ->
				process.send {
					type: 'callback'
					id
					data
				}

			doc = ego.doc

			cmd = "(#{handler})(doc, callback);\n"
			eval cmd

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


new JDB.Jworker
