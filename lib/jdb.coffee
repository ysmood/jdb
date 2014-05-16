class JDB.Jdb
	constructor: ->
		@callback_list = {}
		@callback_list_count = 0

		@init_daemon()

	send_handler: (handler, callback) ->
		id = Date.now() + @callback_list_count++

		@callback_list[id] = callback if callback

		@daemon.send {
			type: 'handler'
			id: id
			handler: handler.toString()
		}

	init_daemon: ->
		child_process = require 'child_process'
		process.env.JDB_launch = 'jworker'

		@daemon = child_process.fork __dirname + '/../app.js'

		@daemon.on 'message', (msg) =>
			switch msg.type
				when 'error'
					console.log msg.message
					console.log msg.stack

				when 'callback'
					@callback_list[msg.id] msg.data
					delete @callback_list[msg.id]

