
class JDB.Jworker then constructor: (options) ->
	# Public
	self = {

	}

	# Private
	ego = {
		doc: {}

		init: ->
			ego.init_handlers()

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

		handle_command: (handler, id) ->
			callback = (data) ->
				process.send {
					type: 'callback'
					id
					data
				}

			eval "(#{handler})(ego.doc, callback)"
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
