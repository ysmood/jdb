var slice = [].slice;
var fs = require('fs');
var Promise = require('yaku');
var promisify = require('yaku/lib/promisify');

module.exports = function() {

    // Public
    var self = {
        init: function(options) {
            Object.defineProperty(self, 'doc', {
                get: function() {
                    return ego.doc;
                }
            });
            ego.init_options(options);
            return ego.init_db_file().then(function() {
                ego.db_file = fs.createWriteStream(ego.opts.dbPath, {
                    flags: 'a',
                    encoding: 'utf8'
                });
                return null;
            });
        },

        exec: function(data, command, callback) {
            var err, jdb, opts, ref;
            if (arguments.length === 0) {
                return;
            } else if (typeof data === 'function') {
                callback = command;
                command = data;
            } else if (arguments.length === 1) {
                ref = data, data = ref.data, command = ref.command, callback = ref.callback;
            }
            opts = {
                data: data,
                command: command,
                callback: callback
            };
            if (!opts.command) {
                return;
            }
            jdb = ego.generate_api(opts);
            try {
                opts.command(jdb, opts.data);
            } catch (_error) {
                err = _error;
                err.promise = jdb.rollback();
                if (opts.callback) {
                    err.promise.then(function() {
                        return opts.callback(err);
                    });
                } else {
                    if (ego.opts.promise) {
                        opts.deferred.reject(err);
                    }
                }
            }
            if (ego.opts.promise) {
                return opts.deferred.promise;
            }
        },

        compactDBFile: function() {
            ego.is_compressing = true;
            return promisify(fs.writeFile)(ego.opts.dbPath, ego.compacted_data()).then(function() {
                ego.is_compressing = false;
                ego.write_queue.forEach(function(fn) {
                    return fn();
                });
                return ego.write_queue = [];
            }).then();
        },

        compactDBFileSync: function() {
            return fs.writeFileSync(ego.opts.dbPath, ego.compacted_data());
        },

        close: function() {
            return promisify(ego.db_file.end, ego.db_file)();
        }
    };

    // Private
    var ego = {
        opts: {
            dbPath: 'jdb.db',
            compactDBFile: true,
            promise: true
        },
        doc: {},
        db_file: null,
        is_compressing: false,
        write_queue: [],

        init_options: function(options) {
            var k, ref, results, v;
            if (!options) {
                return;
            }
            ref = ego.opts;
            results = [];
            for (k in ref) {
                v = ref[k];
                if (options[k] !== void 0) {
                    results.push(ego.opts[k] = options[k]);
                } else {
                    results.push(void 0);
                }
            }
            return results;
        },

        init_db_file: function() {
            if (fs.existsSync(ego.opts.dbPath)) {
                return ego.load_data().then(function() {
                    if (ego.opts.compactDBFile) {
                        return self.compactDBFile();
                    }
                });
            } else {
                return self.compactDBFile();
            }
        },

        load_data: function() {
            var buf, is_first_line, jdb_ref, readline, rl;
            readline = require('readline');
            rl = readline.createInterface({
                input: fs.createReadStream(ego.opts.dbPath, {
                    encoding: 'utf8'
                }),
                output: process.stdout,
                terminal: false
            });
            buf = '';
            jdb_ref = null;
            is_first_line = true;
            return new Promise(function(resolve, reject) {
                var error, isRejected;
                isRejected = false;
                error = function(err) {
                    if (isRejected) {
                        return;
                    } else {
                        isRejected = true;
                    }
                    if (jdb_ref && typeof jdb_ref.doc === 'object') {
                        ego.doc = jdb_ref.doc;
                    }
                    return reject(err);
                };
                rl.on('line', function(line) {
                    var err, jdb;
                    if (line[0] === '(') {
                        try {
                            if (is_first_line) {
                                jdb_ref = eval(buf + '; jdb');
                                is_first_line = false;
                            } else {
                                jdb = jdb_ref;
                                eval(buf);
                            }
                        } catch (_error) {
                            err = _error;
                            error(err);
                        }
                        return buf = line;
                    } else {
                        return buf += '\n' + line;
                    }
                });
                return rl.on('close', function() {
                    var err, jdb;
                    try {
                        jdb = jdb_ref;
                        eval(buf);
                        if (jdb && typeof jdb.doc === 'object') {
                            ego.doc = jdb.doc;
                            return resolve();
                        } else {
                            return self.compactDBFile().catch(function(err) {
                                return error(err);
                            }).then(function() {
                                return resolve();
                            });
                        }
                    } catch (_error) {
                        err = _error;
                        return error(err);
                    }
                });
            });
        },

        generate_api: function(opts) {
            var is_rolled_back, is_sent, jdb;
            if (ego.opts.promise) {
                opts.deferred = {};
                opts.deferred.promise = new Promise(function(resolve, reject) {
                    opts.deferred.resolve = resolve;
                    return opts.deferred.reject = reject;
                });
            }
            is_sent = false;
            is_rolled_back = false;
            jdb = {
                send: function(data) {
                    if (is_sent) {
                        return;
                    } else {
                        is_sent = true;
                    }
                    if (typeof opts.callback === "function") {
                        opts.callback(null, data);
                    }
                    if (ego.opts.promise) {
                        return opts.deferred.resolve(data);
                    }
                },
                save: function(data) {
                    var cmd_data, indented_cmd;
                    if (is_rolled_back) {
                        return;
                    }
                    indented_cmd = opts.command.toString().replace(/^function([\s\S]+)\}$/, function(m, p) {
                        return 'function' + p.replace(/\n\(/g, '\n (') + '}';
                    });
                    cmd_data = "(" + indented_cmd + ")(jdb, " + (JSON.stringify(opts.data)) + ");\n";
                    if (ego.is_compressing) {
                        return ego.write_queue.push(function() {
                            return ego.db_file.write(cmd_data, function() {
                                return jdb.send(data);
                            });
                        });
                    } else {
                        return ego.db_file.write(cmd_data, function() {
                            return jdb.send(data);
                        });
                    }
                },
                rollback: function() {
                    is_rolled_back = true;
                    return ego.load_data();
                },
                doc: ego.doc
            };
            return jdb;
        },

        compacted_data: function() {
            return "var jdb = { doc: " +
                JSON.stringify(ego.doc) +
                ", send: function() {}, save: function() {}, rollback: function() {} };\n";
        }
    };

    return self;
};
