# Overview

This project aims to create a flexable database that won't try to create any werid syntax or rules.
Just few APIs will make everything work smoothly. It is an append-only database.
It use json to decrease javascript code handlers.


# Model

The DB will create a independent child process waiting for javascript code to handle the internal json
object, and append the json object and javascript code to permanent storage.

# Quick start

```coffeescript

jdb = new (require 'jdb')

# Execute command in js or coffee.
jdb.exec (doc) ->
	doc.hello = 'world'

# Get the value.
jdb.exec(
	(doc, send) ->
		send doc.hello
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

  * **handler (doc, send)**
    A function or corresponding source code.
    The code in this function is in another process.
    You can't share variable within it.

      * **doc**
        The main storage `Object`.

      * **send (data)****
        Send data to the `callback`.

         * **data**
           Type is `Object`

  * **callback (err, data)**
    This function will be invoked when the `send` function is called asynchronous.

      * **err**
        Type is `Object`.

      * **data**
        Type is `Object`.



* ### compact_db_file: (callback)

  Reduce the size of the database file. It will calc all the handlers and save the final `doc` object to the file and delete all the other handlers.

* ### uncaught_exception: (msg)
  Override it if you want to handler error yourself. The default behaviour is just log the `msg` object out.

* ### db_file_error: (msg)
  Override it if you want to handler error yourself. The default behaviour is just log the `msg` object out.
