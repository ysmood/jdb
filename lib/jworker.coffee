class JDB.Jworker

	init_variables = ->
		@doc = {}

	init_handlers = ->
		process.on 'uncaughtException', (err) ->
			process.send {
				type: 'error'
				message: err.message
				stack: err.stack
			}

		process.on 'message', (msg) ->
			switch msg.type
				when 'handler'
					handle_command msg.handler, msg.id

	handle_command = (handler, id) ->
		callback = (data) ->
			process.send {
				type: 'callback'
				id
				data
			}

		eval "(#{handler})(this.doc, callback)"

	constructor: ->
		handle_command = handle_command.bind(@)
		init_variables = init_variables.bind(@)
		init_handlers = init_handlers.bind(@)

		init_handlers()
		init_variables()


new JDB.Jworker
