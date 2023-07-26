# Overview

The `batch-operation` project demonstrates how to use the MSSQL client to perform batch operations.

# Prerequisite

* Install the MSSQL server and create a database

* Add required configurations in the `Config.toml` file

# Run the example

To run the example, move into the `batch-operation` project and execute the command below.

```
$bal run
```
It will build the `batch-operation` Ballerina project and then run it.

# Output of the example

This gives the following output when running this project.

```ballerina
Data in Customers table:
{"customerId":3,"firstName":"Peter","lastName":"Stuart","registrationID":1,"creditLimit":5000.75,"country":"USA"}
{"customerId":4,"firstName":"Stephanie","lastName":"Mike","registrationID":2,"creditLimit":8000.0,"country":"USA"}
{"customerId":5,"firstName":"Bill","lastName":"John","registrationID":3,"creditLimit":3000.25,"country":"USA"}
```