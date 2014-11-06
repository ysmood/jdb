jdb = new (require '../')

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

# Init the db file before you start.
jdb.init()
.then ->

    # Set data.
    jdb.exec
        data: some_data
        command: (jdb, data) ->
            jdb.doc.ys = data
            jdb.save 'saved'
        callback: (err, data) ->
            console.log data # output >> saved

    # Or simple way to save data.
    jdb.exec some_data, (jdb, data) ->
        jdb.doc.arr = data.languages.map (el) -> el.name
        jdb.save()
    .then ->
        console.log 'saved'

    # Don't do something like this!
    wrong = ->
        jdb.exec command: (jdb) ->
            # Error: the scope here should not access the variable `some_data`.
            jdb.doc.ys = some_data
            jdb.save()

    # Get the value. Much simpler.
    console.log jdb.doc.ys.name # output >> [ "Yad", "Smood" ]
