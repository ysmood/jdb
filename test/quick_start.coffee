jdb = new (require '../') { promise: true }


# The data to play with.
some_data = {
    "name": {
        "first": "Yad"
        "last": "Smood"
    }
    "fav_color": "blue"
    "languages": [
        {
            "name": "Chinese"
            "level": 10
        }
        {
            "name": "English"
            "level": 8
            "preferred": true
        }
        {
            "name": "Japenese"
            "level": 6
        }
    ]
    "height": 180
    "weight": 68
}


# Set data.
jdb.exec
    data: some_data
    command: (jdb, data) ->
        jdb.doc.ys = data
        jdb.save 'saved'
    callback: (err, data) ->
        console.log data # output >> saved


# Don't do something like this!
wrong = ->
    jdb.exec command: (jdb) ->
        # Error: the scope here should not access the variable `some_data`.
        jdb.doc.ys = some_data
        jdb.save()


# Get the value.
# You can also use arguments other than the `{ data, command, callback }`
jdb.exec (jdb) ->
    jdb.send jdb.doc.ys.name
, (err, data) ->
    console.log data # output >> [ "Yad", "Smood" ]


# You can even load third party libs to handle with your data.
# Here we use the JSONSelect and Mongodb like sift to query data.
jdb.exec
    command: (jdb) ->
        try
            { match: jselect } = require 'JSONSelect'
            sift = require 'sift'
        catch e
            console.error '"npm install JSONSelect sift" first!'
            return

        jdb.send {
            JSONSelect: jselect(
                    'number', jdb.doc
                )
            mongodb_like: sift(
                    { level: { $gt: 8 } }, jdb.doc.ys.languages
                )
        }
# Here we use promise to get the callback data.
.done (result) ->
    console.log result.JSONSelect   # output >> [ 10, 8, 6, 180, 68 ]
    console.log result.mongodb_like # output >> [ { name: 'Chinese', level: 10 } ]
