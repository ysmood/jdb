jdb = new (require '../')


# The data to play with.
hello = 'hello'
world = 'world'


# Execute command in js code or coffee function.
jdb.exec
    data: {
        hello
        world
    }
    command: (jdb, data) ->
        jdb.doc.hello = data.hello
        jdb.doc.world = data.world
        jdb.save()


# Don't do something like this!
wrong = ->
    jdb.exec command: (jdb) ->
        # Error: the scope here cannot access the variable `hello`.
        jdb.doc.hello = hello
        jdb.save()


# Get the value.
jdb.exec
    command: (jdb) ->
        jdb.send [jdb.doc.hello, jdb.doc.world]
    callback: (err, data) ->
        console.log data # output >> [ "hello", "world" ]


# You can even load third party libs to handle with your data.
# Here we use the underscore.js to diff some data.
jdb.exec
    command: (jdb) ->
        try
            _ = require 'underscore'
        catch e
            jdb.send '"npm install underscore" first!'

        _.each jdb.doc, (v, k) ->
            jdb.doc[k] = v.split('')

        jdb.send _.difference(jdb.doc.hello, jdb.doc.world)

# Here we use promise to get the callback data.
.done (diff) ->
    console.log diff # output >> [ 'h', 'e' ]