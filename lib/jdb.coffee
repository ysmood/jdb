
class JDB.Jdb then constructor: ->

	fs = require 'fs'
	Q = require 'q'

	# Public
	self = {

		init: (options) ->
			ego.init_options options
			ego.init_db_file().then ->
				ego.db_file = fs.createWriteStream ego.opts.db_path, {
					flags: 'a'
					encoding: 'utf8'
				}
				null

		exec: (data, command, callback) ->
			if arguments.length == 0
				return
			else if typeof data == 'function'
				callback = command
				command = data
			else if arguments.length == 1
				{ data, command, callback } = data

			opts = { data, command, callback }

			return if not opts.command

			jdb = ego.generate_api opts

			try
				opts.command jdb, opts.data
			catch err
				err.promise = jdb.rollback()

				if opts.callback
					err.promise.done ->
						opts.callback err
				else
					opts.deferred.reject err if ego.opts.promise

			return opts.deferred.promise if ego.opts.promise

		compact_db_file: ->
			ego.is_compressing = true

			Q.nfcall(
				fs.writeFile
				ego.opts.db_path
				ego.compacted_data()
			).then ->
				ego.is_compressing = false
				ego.write_queue.forEach (fn) -> fn()
				ego.write_queue = []
			.then()

		compact_db_file_sync: ->
			fs.writeFileSync(
				ego.opts.db_path
				ego.compacted_data()
			)

		close: ->
			deferred = Q.defer()
			ego.db_file.end (err) ->
				if err
					deferred.reject err
				else
					deferred.resolve()
			deferred.promise
	}

	# Private
	ego = {

		opts: {
			db_path: 'jdb.db'
			compact_db_file: true
			promise: true
		}

		doc: {}

		db_file: null

		is_compressing: false
		write_queue: []

		init_options: (options) ->
			return if not options

			for k, v of ego.opts
				ego.opts[k] = options[k] if options[k] != undefined

		init_db_file: ->
			if fs.existsSync ego.opts.db_path
				ego.load_data().then ->
					if ego.opts.compact_db_file
						self.compact_db_file()
			else
				self.compact_db_file()

		load_data: ->
			readline = require 'readline'
			deferred = Q.defer()

			rl = readline.createInterface {
				input: fs.createReadStream ego.opts.db_path, {
					encoding: 'utf8'
				}
				output: process.stdout
				terminal: false
			}
			buf = ''
			jdb_ref = null
			is_first_line = true

			rl.on 'line', (line) ->
				if line[0] == '('
					try
						if is_first_line
							jdb_ref = eval buf + '; jdb'
							is_first_line = false
						else
							jdb = jdb_ref
							eval buf
					catch err
						deferred.reject err
					buf = line
				else
					buf += '\n' + line

			rl.on 'close', ->
				try
					jdb = jdb_ref
					eval buf
					if jdb and typeof jdb.doc == 'object'
						ego.doc = jdb.doc
						deferred.resolve()
					else
						self.compact_db_file()
						.catch (err) ->
							deferred.reject err
						.done ->
							deferred.resolve()
				catch err
					deferred.reject err

			deferred.promise

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

					# Indent function content for huge db file loading.
					indented_cmd = opts.command.toString()
						.replace /^function([\s\S]+)\}$/, (m, p) ->
							'function' + p.replace(/\n\(/g, '\n (') + '}'

					cmd_data = "(#{indented_cmd})(jdb, #{JSON.stringify(opts.data)});\n"

					if ego.is_compressing
						ego.write_queue.push ->
							ego.db_file.write(
								cmd_data
								-> jdb.send data
							)
					else
						ego.db_file.write(
							cmd_data
							-> jdb.send data
						)

				rollback: ->
					is_rolled_back = true
					ego.load_data()

				doc: ego.doc
			}

			return jdb

		compacted_data: ->
			"var jdb = {
				doc: #{JSON.stringify(ego.doc)},
				send: function() {},
				save: function() {},
				rollback: function() {}
			};\n"

	}

	for k, v of self
		@[k] = v
	self = @

	for k, v of ego
		if typeof v == 'function'
			v.bind self

	self
