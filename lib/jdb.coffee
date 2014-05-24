
class JDB.Jdb then constructor: (options) ->

	fs = require 'fs'
	Q = require 'q'

	# Public
	self = {

		exec: (opts) ->
			deferred = Q.defer()

			if not opts.command
				return

			is_sent = false

			is_rolled_back = false

			jdb = {
				send: (data) ->
					if is_sent
						return
					else
						is_sent = true

					opts.callback? null, data
					deferred.resolve data

				save: (data) ->
					return if is_rolled_back

					fs.appendFile(
						ego.opts.db_path
						"(#{opts.command})(jdb, #{JSON.stringify(opts.data)});\n"
						(err) ->
							if err
								jdb.rollback()
								if opts.callback
									opts.callback err
								else
									deferred.reject err
								is_sent = true
							else if not is_sent
								jdb.send data
					)

				rollback: ->
					ego.load_data()
					is_rolled_back = true
			}

			Object.defineProperty jdb, 'doc', {
				get: -> ego.doc
				set: -> console.error ">> Error: 'jdb.doc' is readonly."
			}

			try
				opts.command jdb, opts.data
			catch err
				jdb.rollback()

				if opts.callback
					opts.callback err
				else
					deferred.reject err

			return deferred.promise

		compact_db_file: (callback) ->
			try
				fs.writeFileSync(
					ego.opts.db_path
					"""
						var jdb = {
							doc: #{JSON.stringify(ego.doc)},
							send: function () {},
							save: function () {},
							rollback: function () {}
						};\n
					"""
				)
			catch err
				error = err

			if callback
				callback error
			else if error
				throw error

	}

	# Private
	ego = {

		opts: {
			db_path: 'jdb.db'
			compact_db_file: true
			error: null
		}

		doc: {}

		init: ->
			ego.init_options()
			ego.init_db_file()

		init_options: ->
			return if not options

			for k, v of ego.opts
				ego.opts[k] = options[k] if options[k] != undefined

		init_db_file: ->
			if fs.existsSync ego.opts.db_path
				ego.load_data()

				if ego.opts.compact_db_file
					self.compact_db_file()
			else
				self.compact_db_file()

		load_data: ->
			str = fs.readFileSync ego.opts.db_path, 'utf8'
			try
				eval str
				ego.doc = jdb.doc if typeof jdb.doc == 'object'
			catch err
				error = err

			if ego.opts.error
				ego.opts.error error
			else if error
				throw error

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self
