# Overview

The `query-operation` project demonstrates how to use the MSSQL client to perform a query.

# Prerequisite

* Install the MSSQL server and create a database

* Add required configurations in the `Config.toml` file

# Run the example

To run the example, move into the `query-operation` project and execute the command below.

```
$bal run
```
It will build the `query-operation` Ballerina project and then run it.

# Output of the example

This gives the following output when running this project.

```ballerina
Full Customer details: {"customerId":1,"firstName":"Peter","lastName":"Stuart","registrationId":1,"creditLimit":5000.75,"country":"USA"}
Full Customer details: {"customerId":2,"firstName":"Dan","lastName":"Brown","registrationId":2,"creditLimit":10000.0,"country":"UK"}
Total rows in customer table : 2
Full Customer details: {"customerId":1,"firstName":"Peter","lastName":"Stuart","registrationId":1,"creditLimit":5000.75,"country":"USA"}
Full Customer details: {"customerId":2,"firstName":"Dan","lastName":"Brown","registrationId":2,"creditLimit":10000.0,"country":"UK"}

```