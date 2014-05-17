###
	The it's not easy too implement private non-static member via coffee-script.
	So I use the pure js way.
###
JDB.Jdb = ->
	self = @
	ego = {
		callback_list: {}
		callback_list_count: 0
		daemon: null

		constructor: ->
			ego.init_jworker()

		init_jworker: ->
			child_process = require 'child_process'
			process.env.JDB_launch = 'jworker'

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


	self.exec = (handler, callback) ->
		id = Date.now() + ego.callback_list_count++

		ego.callback_list[id] = callback if callback

		ego.daemon.send {
			type: 'handler'
			id: id
			handler: handler.toString()
		}

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.constructor()

	return self
