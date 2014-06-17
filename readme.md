# Overview

This project is inspired by [nedb](https://github.com/louischatriot/nedb).
It aims to create a flexible database without any weird syntax or rules.
Just few APIs will make everything work smoothly.
JDB is an append-only, in-memory, non-block IO database.

It uses json to decrease database file size, which means after all javascript commands are executed,
they will become a single json object.

For further infomation goto [How it works?](#how_it_works)

[![Build Status](https://travis-ci.org/ysmood/jdb.svg)](https://travis-ci.org/ysmood/jdb) [![Build status](https://ci.appveyor.com/api/projects/status/ivsm326en792xsnj)](https://ci.appveyor.com/project/ysmood/jdb)

# Features

* Super fast ([see the benchmark](#benchmarks)).

* Light weight.

* Promise support.

* Use full functioned javascript to operate your data, no steep learning curve.

* Make debugging inside the data possible.

* Support both standalone mode (server) and in-application mode (lib).


# Quick start

### Installation

Install `jdb` first.

    npm install jdb

### Examples

Here's the embedded mode example.

```coffeescript

jdb = new (require 'jdb') { promise: true }


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
jdb.exec
    command: (jdb) ->
        jdb.send jdb.doc.ys.name
    callback: (err, data) ->
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

```

# Http server quick start

To allow JDB to serve multiple clients, you can start it as a http server (standalone mode).

Install `jdb` globally.

    npm install -g jdb

See help info.

    jdb -h

Start server at port 8081.

    jdb -p 8081

JDB action `exec` only accepts raw `json` http request (do not url-encode the body!). For example:

    POST /exec HTTP/1.1
    Host: 127.0.0.1:8081
    Content-Length: 88

    { "data": 10, "command": "function(jdb, data) { jdb.doc.a = 1; jdb.save(jdb.doc.a); }" }

It will return json:

    {"a":1}

JDB action `compact_db_file` example:

    GET /compact_db_file HTTP/1.1
    Host: 127.0.0.1:8081

It will return:

    OK


# How it works? <a name="#how_it_works"></a>

It simply executes all your js code and manipulate a `doc` object, while append each
js code to a file. Everytime when you start up the JDB, it executes all the code in the file,
and the last time's `doc` object will come back again.


# API

## class Jdb

* ### constructor (options)

      * **options**

         * **db_path**

           Where to save the database file. Default value is `jdb.db`.

         * **compact_db_file**

           Boolean. Whether to compact db file before start up or not. Default true.

         * **promise**

           Boolean. Whether to enable promise or not. Default false.

         * **error**

           The error handler when initializing database.

* ### exec (options)

  `options` is an object, here are its member list.

  * **data**

      `data` should be serializable object. It will be send with `command`, see the `command (jdb)` part.

  * **command (jdb)**

      A function or corresponding source code.
      The code in this function is in another scope (database file scope).
      Do not share outer variable within it, see the wrong example in quick start part.

      #### jdb

      An object from which you access the functions of the database. Here's the list of its members.

      * **data**

         The `data` object that is sent from the `exec (options)`.

      * **doc**

         The main storage `Object`.

      * **save([data])**

         When your data manipulation is done, call this method to permanent your change. It will automatically call the send for you.

         * **data**

             The same as the `data` of `jdb.send`.

      * **send ([data])**

         Send data to the `callback`.

         * **data**

             Type is `Object`. It should be serializable.

      * **rollback()**

         Call it when you want to rollback the change that you made.

  * **callback (err, data)**

     This function will be invoked after the `save` or `send` is called.

      * **err**

         Type is `Object`.

      * **data**

         Type is `Object`.


* ### compact_db_file (callback)

  Reduce the size of the database file. It will calculate all the commands and save the final `doc` object to the file and delete all the other commands.

* ### compact_db_file_sync ()

  The sync version of `compact_db_file (callback)`.


# Unit test

To use `cake`, install [coffee-script](coffeescript.org) globally: `npm install -g coffee-script`.

Unit test will test all the basic functions of JDB. Before your pull request, run it first.

    cake test


# Benchmarks <a name='benchmarks'></a>

To run the benchmark:

    cake benchmark

### JDB on Intel Core i7 2.3GHz SSD

* insert x 15,562 ops/sec ±4.37% (62 runs sampled)
* query x 665,237 ops/sec ±0.83% (95 runs sampled)

### MongoDB on Intel Core i7 2.3GHz SSD

**JDB is much faster than MongoDB**

* insert x 3,744 ops/sec ±2.63% (76 runs sampled)
* query x 2,416 ops/sec ±3.89% (70 runs sampled)

### Redis on Intel Core i7 2.3GHz SSD

**JDB's query performance is faster than Redis**

* insert x 10,619 ops/sec ±2.33% (77 runs sampled)
* query x 10,722 ops/sec ±2.27% (80 runs sampled)

### JDB on Digitalocean VPS 1 CPU

**Even on a much slower machine JDB is still much faster than MongoDB**

* insert x 9,460 ops/sec ±3.34% (78 runs sampled)
* query x 343,502 ops/sec ±2.57% (93 runs sampled)

### JDB http server on Intel Core i7 2.3GHz SSD

* exec x 65,912 ops/sec ±2.84% (72 runs sampled)

Though for MongoDB and Redis, most of their CPU time is ate by their DB adapters, but I think
for some small projects, such as personal blog, or a non-cluster application, the adapter issue
should also be taken into consideration.

# Road Map

* More fault tolerance support. Such as file system error handling.

* Maybe simple cluster support.

# License

### BSD

May 2014, Yad Smood
