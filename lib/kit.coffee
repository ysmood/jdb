Promise = require 'bluebird'
_ = require 'lodash'
fs = require 'fs'

module.exports = {

	spawn: (cmd, args = [], options = {}) ->
		if process.platform == 'win32'
			cmd_ext = cmd + '.cmd'
			if fs.existsSync cmd_ext
				cmd = cmd_ext
			else
				which = require 'which'
				cmd = which.sync(cmd)
			fs_path = require 'path'
			cmd = fs_path.normalize cmd

		ps = null

		promise = new Promise (resolve, reject) ->

			opts = _.defaults options, { stdio: 'inherit' }

			{ spawn } = require 'child_process'
			try
				ps = spawn cmd, args, opts
			catch err
				deferred.reject err

			ps.on 'error', (err) ->
				deferred.reject err

			ps.on 'close', (code, signal) ->
				resolve { code, signal }

		promise.process = ps

		promise

}