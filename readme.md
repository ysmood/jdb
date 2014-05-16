# JDB

This project aims to create a flexable database that won't make you pain.
It won't try to create any werid syntax or rules. Just few APIs will make everything
work smoothly. It is a append only database.
It use json to decrease javascript code handlers.


## Model

The DB create a independent child process waiting for javascript code to handle the internal json
object, and append the json object and javascript code to permanent storage.
