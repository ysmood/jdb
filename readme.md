# Overview

This project aims to create a flexible database that won't try to create any weird syntax or rules.
Just few APIs will make everything work smoothly.
It is an append-only in-memory database.
It uses json to decrease javascript commands.

# Features

* Super fast ([see the benchmark](#benchmarks)).

* Light weight.

* Promise support.

* Use full functioned javascript to operate your data, no steep learning curve.

* Make debugging inside the data possible.

* Runs in an independent process, thread safe.


# Quick start

### Installation

Install `jdb` first.

    npm install jdb

### Examples

```coffeescript

jdb = new (require 'jdb') { promise: true }


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
#
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

```


# API

## class Jdb

* ### constructor (options)

      * **options**

         * **db_path**

           Where to save the database file. Default value is `jdb.db`.

         * **compact_db_file**

           Boolean. Whether to compact db file before start up or not.

         * **promise**

           Boolean. Whether to enable promise or not.

         * **error**

           The error handler when initializing database.

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


* ### compact_db_file (callback)

  Reduce the size of the database file. It will calc all the commands and save the final `doc` object to the file and delete all the other commands.


# Benchmarks <a name='benchmarks'></a>

To run the benchmark:

    `cake benchmark`

### JDB on Intel Core i7 2.3GHz SSD

* insert x 15,719 ops/sec ±3.03% (76 runs sampled)
* query x 123,143 ops/sec ±1.52% (81 runs sampled)

### MongoDB on Intel Core i7 2.3GHz SSD

**JDB is much faster than MongoDB**

* insert x 3,744 ops/sec ±2.63% (76 runs sampled)
* query x 2,416 ops/sec ±3.89% (70 runs sampled)

### Redis on Intel Core i7 2.3GHz SSD

**JDB's query performance is 12 times faster than Redis**

* insert x 10,619 ops/sec ±2.33% (77 runs sampled)
* query x 10,722 ops/sec ±2.27% (80 runs sampled)

### JDB on Digitalocean VPS 1 CPU

**Even on a much slower machine JDB is still much faster than MongoDB**

* insert x 7,286 ops/sec ±2.77% (77 runs sampled)
* query x 43,240 ops/sec ±3.07% (78 runs sampled)

Though for MongoDB and Redis, most of their CPU time is ate by their DB adapters, but I think
for some small projects, such as personal blog, or a non-cluster application, the adapter issue
should also be taken into consideration.

# Road Map

* More fault tolerance support. Such as file system error handling.

* Remote interface.

* Maybe simple cluster support.

# License

### BSD

May 2014, Yad Smood
