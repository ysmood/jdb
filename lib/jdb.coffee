
class JDB.Jdb then constructor: (options) ->

	fs = require 'fs'
	Q = require 'q'

	# Public
	self = {

		exec: (data, command, callback) ->
			switch arguments.length
				when 0
					return
				when 1
					opts = data
				else
					if typeof data == 'function'
						callback = command
						command = data

					opts = { data, command, callback }

			return if not opts.command

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

		close: (callback) ->
			ego.db_file.end callback

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
			ego.db_file.write ego.compacted_data()

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
			"use strict"

			str = fs.readFileSync ego.opts.db_path, 'utf8'
			try
				eval str
				if typeof jdb != 'undefined' and
				typeof jdb.doc == 'object'
					ego.doc = jdb.doc
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
			"var jdb = {
				doc: #{JSON.stringify(ego.doc)},
				send: function() {},
				save: function() {},
				rollback: function() {}
			};"

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	ego.init()

	return self
