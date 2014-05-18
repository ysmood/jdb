jdb = new (require '../')

# Execute command in js or coffee.
jdb.exec (jdb) ->
    jdb.doc.hello = 'hello'
    jdb.doc.world = 'world'
    jdb.save()

# The save effect with the code above.
same_with_above = ->
    jdb.exec """
    function (any_name) {
        any_name.doc.hello = 'hello';
        any_name.doc.world = 'world';
        any_name.save();
    }
    """

# Don't do something like this!
wrong = ->
  val = 10
  jdb.exec (jdb) ->
      jdb.doc.a = val    # `jdb.doc.a` here won't have the scope as the `val`.
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
