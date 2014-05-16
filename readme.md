# JDB

This project aims to create a flexable database that won't try to create any werid syntax or rules.
Just few APIs will make everything work smoothly. It is an append-only database.
It use json to decrease javascript code handlers.


## Model

The DB will creates a independent child process waiting for javascript code to handle with the internal json
object, and append the json object and javascript code to permanent storage.
