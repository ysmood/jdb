# Overview

This project is inspired by [nedb](https://github.com/louischatriot/nedb).
It aims to create a flexible database without any weird syntax or rules.
Just few APIs will make everything work smoothly.
JDB is an append-only, in-memory, non-block IO database.

It uses json to decrease database file size, which means after all javascript commands are executed,
they will become a single json object.

For further infomation goto [How it works?](#user-content-how-it-works)

[![Build Status](https://travis-ci.org/ysmood/jdb.svg)](https://travis-ci.org/ysmood/jdb) [![Build status](https://ci.appveyor.com/api/projects/status/ivsm326en792xsnj)](https://ci.appveyor.com/project/ysmood/jdb)

# Features

* Super fast ([see the benchmark](#user-content-benchmarks)).

* Light weight. Core code is only about 200 lines.

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

jdb = require 'jdb'

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

```

# Http server quick start

To allow JDB to serve multiple clients, you can start it as a http server (standalone mode).

Install `jdb` globally.

    npm install -g jdb

See help info.

    jdb -h

Interactive mode, you have two global api.
You can manipulate the data via `doc`, and run `save()` to permanent your change.

    jdb -i

Start server at port 8081.

    jdb -p 8081

JDB action `exec` only accepts raw `json` http request (do not url-encode the body!). For example:

    POST /exec HTTP/1.1
    Host: 127.0.0.1:8081
    Content-Length: 88

    { "data": 10, "command": "function(jdb, data) { jdb.doc.a = 1; jdb.save(jdb.doc); }" }

It will return json:

    {"a":1}

JDB action `compact_db_file` example:

    GET /compact_db_file HTTP/1.1
    Host: 127.0.0.1:8081

It will return:

    OK


# How it works?

It simply executes all your js code to manipulate a `doc` object, and append each
js code to a file. Each time when you start up the JDB, it executes all the code in the file,
and the last time's `doc` object will come back again in the memory.

****************************************************************************

# API

The main api of class Jdb.

## `constructor ([options])`

* **options**

   * **db_path** _{Boolean}_

     Where to save the database file. Default value is `jdb.db`.

   * **compact_db_file** _{Boolean}_

     Whether to compact db file before start up or not. Default true.

   * **promise** _{Boolean}_

     Whether to enable promise or not. Default true.

   * **error** _{Function}_

     The error handler when initializing database.

## `doc`

The main storage object. Readonly. Do not write its property directly.

## `exec ([data], command, [callback])`
## `exec (options)`

A api and the only api to interact with the data in database.

* **data** _{Object}_

    `data` should be serializable object. It will be send with `command`, see the `command (jdb)` part.

* **command (jdb)** _{Function}_

    A function or corresponding source code.
    The code in this function is in another scope (database file scope).
    Do not share outer variable within it, see the wrong example in quick start part.

    * **jdb** _{Object}_

      An object from which you access the functions of the database. Here's the list of its members.

      * **jdb.data** _{Object}_

         The `data` object that is sent from the `exec (options)`.

      * **jdb.doc** _{Object}_

         The main storage object.

      * **jdb.save ([data])** _{Function}_

         When your data manipulation is done, call this method to permanent your change. It will automatically call the send for you.

         * **data** _{Object}_

             The same as the `data` of `jdb.send`.

      * **jdb.send ([data])** _{Function}_

         Send data to the `callback`.

         * **data** _{Object}_

             Type is `Object`. It should be serializable.

      * **jdb.rollback()** _{Function}_

         Call it when you want to rollback the change that you made.

* **callback (err, data)** _{Function}_

   This function will be invoked after the `save` or `send` is called.

    * **err** _{Object}_

       It can only catch sync errors, you should handle async errors by yourself.

    * **data** _{Function}_

       The data you send from `jdb.send(data)` or `jdb.save(data)`.


## `compact_db_file ([callback])`

Reduce the size of the database file. It will calculate all the commands and save the final `doc` object to the file and delete all the other commands.

## `compact_db_file_sync ()`

The sync version of `compact_db_file (callback)`.

****************************************************************************

# Unit test

To use `cake`, install [coffee-script](coffeescript.org) globally: `npm install -g coffee-script`.

Unit test will test all the basic functions of JDB. Before your pull request, run it first.

    cake test


# Benchmarks

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
