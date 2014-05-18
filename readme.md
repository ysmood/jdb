# Overview

This project aims to create a flexible database that won't try to create any weird syntax or rules.
Just few APIs will make everything work smoothly. It is an append-only database.
It use json to decrease javascript code commands.


# Model

The DB will create a independent child process waiting for javascript code to handle the internal json
object, and append the json object and javascript code to permanent storage.

# Quick start

### Installation

Install `jdb` first.

    npm install jdb

### Examples

```coffeescript

jdb = new (require 'jdb')

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
jdb.exec
    command: (jdb) ->
        try
            _ = require 'underscore'

            _.each jdb.doc, (v, k) ->
                jdb.doc[k] = v.split('')

            jdb.send _.difference(jdb.doc.hello, jdb.doc.world)
        catch e
            jdb.send '"npm install underscore" first!'

    callback: (err, diff) ->
        console.log diff # output >> [ 'h', 'e' ]
        process.exit()


```

# API

## class Jdb

* ### Constructor (options)

      * **options**

         * **db_path**

           Where to save the database file. Default value is `jdb.db`.

         * **compact_db_file**

           Boolean. Whether to compact db file before start up or not.

* ### exec (options)

  `options` is an object, here are its member list.

  * **data**

      `data` should be serializable object. It will be send with `command`, see the `command (jdb)` part.

  * **command (jdb)**

      A function or corresponding source code.
      The code in this function is in another process.
      You can't share variable within it.

      #### jdb

      An object from which you access the functions of the database. Here's the list of its members.

      * **data**

         The `data` object that sent from the `exec (options)`.

      * **doc**

         The main storage `Object`.

      * **save([data])**

         When your data manipulation is done, call this method to permanent your change. It will auto call the send for you.

         * **data**

             The same as the `data` of `jdb.send`.

      * **send ([data])**

         Send data to the `callback`.

         * **data**

             Type is `Object`. Only the serializable part of the object will be sent.

      * **rollback()**

         Call it when you want to rollback the change that you made.

  * **callback (err, data)**

     This function will be invoked when the `send` function is called asynchronous.

      * **err**

         Type is `Object`.

      * **data**

         Type is `Object`.



* ### compact_db_file: (callback)

  Reduce the size of the database file. It will calc all the commands and save the final `doc` object to the file and delete all the other commands.

* ### uncaught_exception: (msg)
  Override it if you want to command error yourself. The default behavior is just log the `msg` object out.

* ### db_file_error: (msg)
  Override it if you want to command error yourself. The default behavior is just log the `msg` object out.
