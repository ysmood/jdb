
class JDB.Jdb then constructor: (options) ->

	fs = require 'fs'
	Q = require 'q'

	# Public
	self = {

		exec: (opts) ->
			if not opts.command
				return

			jdb = ego.generate_api opts

			try
				opts.command jdb, opts.data
			catch err
				jdb.rollback()

				if opts.callback
					opts.callback err
				else
					opts.deferred.reject err if ego.opts.promise

			return opts.deferred.promise if ego.opts.promise

		compact_db_file: (callback) ->
			deferred = Q.defer() if ego.opts.promise

			fs.writeFile(
				ego.opts.db_path
				ego.compacted_data()
			, (err) ->
				if ego.opts.promise
					if err
						deferred.reject err
					else
						deferred.resolve()
				callback? err
			)

			return deferred.promise if ego.opts.promise

		compact_db_file_sync: ->
			fs.writeFileSync(
				ego.opts.db_path
				ego.compacted_data()
			)

	}

	# Private
	ego = {

		opts: {
			db_path: 'jdb.db'
			compact_db_file: true
			promise: false
			error: null
		}

		doc: {}

		db_file: null

		init: ->
			ego.init_options()
			ego.init_db_file()

			ego.db_file = fs.createWriteStream ego.opts.db_path, {
				flags: 'a'
				encoding: 'utf8'
			}

		init_options: ->
			return if not options

			for k, v of ego.opts
				ego.opts[k] = options[k] if options[k] != undefined

		init_db_file: ->
			if fs.existsSync ego.opts.db_path
				ego.load_data()

				if ego.opts.compact_db_file
					self.compact_db_file_sync()
			else
				self.compact_db_file_sync()

		load_data: ->
			str = fs.readFileSync ego.opts.db_path, 'utf8'
			jdb = ego.generate_api {}
			try
				eval str
				ego.doc = jdb.doc if typeof jdb.doc == 'object'
			catch err
				error = err

			if ego.opts.error
				ego.opts.error error
			else if error
				throw error

		generate_api: (opts) ->
			if ego.opts.promise
				opts.deferred = Q.defer()

			is_sent = false
			is_rolled_back = false

			jdb = {
				send: (data) ->
					if is_sent
						return
					else
						is_sent = true

					opts.callback? null, data
					opts.deferred.resolve data if ego.opts.promise

				save: (data) ->
					return if is_rolled_back

					ego.db_file.write(
						"(#{opts.command})(jdb, #{JSON.stringify(opts.data)});\n"
						-> jdb.send data
					)

				rollback: ->
					ego.load_data()
					is_rolled_back = true

				doc: ego.doc
			}

			return jdb

		compacted_data: ->
			"jdb.doc = #{JSON.stringify(ego.doc)};\n"

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self
