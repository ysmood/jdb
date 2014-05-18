jdb = new (require '../')

hello = 'hello'
world = 'world'

# Execute command in js code or coffee function.
jdb.exec """
    function (jdb) {
        jdb.doc.hello = '#{hello}';
        jdb.doc.world = '#{world}';
        jdb.save();
    }
"""

# The save effect with the code above.
same_with_above = ->
    jdb.exec (jdb) ->
        jdb.doc.hello = 'hello'
        jdb.doc.world = 'world'
        jdb.save()

# Don't do something like this!
wrong = ->
    jdb.exec (jdb) ->
        # Error: the scope here cannot access the variable `hello`.
        jdb.doc.hello = hello
        jdb.save()

# Get the value.
jdb.exec(
    (jdb) ->
        jdb.send [jdb.doc.hello, jdb.doc.world]
    (err, data) ->
        console.log data # output >> [ "hello", "world" ]
)

# You can even load third party libs to handle with your data.
jdb.exec((jdb) ->
    try
        _ = require 'underscore'

        _.each jdb.doc, (v, k) ->
            jdb.doc[k] = v.split('')

        jdb.send _.difference(jdb.doc.hello, jdb.doc.world)
    catch e
        jdb.send '"npm install underscore" first!'

(err, diff) ->
    console.log diff # output >> [ 'h', 'e' ]
    process.exit()
)
