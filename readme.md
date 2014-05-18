# Overview

This project aims to create a flexible database that won't try to create any weird syntax or rules.
Just few APIs will make everything work smoothly. It is an append-only database.
It use json to decrease javascript code handlers.


# Model

The DB will create a independent child process waiting for javascript code to handle the internal json
object, and append the json object and javascript code to permanent storage.

# Quick start

Install `jdb` first.

    npm install jdb

```coffeescript

jdb = new (require 'jdb')

# Execute command in js or coffee.
jdb.exec (jdb) ->
    jdb.doc.hello = 'world'
    jdb.save()

# Get the value.
jdb.exec(
    (jdb) ->
        jdb.send doc.hello
    (data) ->
        console.log data # output >> "world"
)

```

# API

## class Jdb

* ### Constructor (options)

      * **options**

         * **db_path**

           Where to save the database file. Default value is `jdb.db`.

* ### exec (handler, [callback])

  * **handler (jdb)**

      A function or corresponding source code.
      The code in this function is in another process.
      You can't share variable within it.

      #### jdb

      An object from which you access the functions of the database. Here's the list of its members.

      * **doc**

         The main storage `Object`.

      * **save([data])**

         When your data manipulation is done, call this method to permanent your change. It will auto call the send for you.

         * **data**

             The same as the `data` of `jdb.send`.

      * **send ([data])**

         Send data to the `callback`.

         * **data**

             Type is `Object`

      * **rollback()**

         Call it when you want to rollback the change that you made.

      * **cmd**

         The current command you are executing. It is immutable.

  * **callback (err, data)**

     This function will be invoked when the `send` function is called asynchronous.

      * **err**

         Type is `Object`.

      * **data**

         Type is `Object`.



* ### compact_db_file: (callback)

  Reduce the size of the database file. It will calc all the handlers and save the final `doc` object to the file and delete all the other handlers.

  **This method will be called automatically every time you launch the database**.

* ### uncaught_exception: (msg)
  Override it if you want to handler error yourself. The default behavior is just log the `msg` object out.

* ### db_file_error: (msg)
  Override it if you want to handler error yourself. The default behavior is just log the `msg` object out.
