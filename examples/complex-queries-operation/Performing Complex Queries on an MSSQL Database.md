# Overview

The `complex-queries-operation` project demonstrates how to use the MSSQL client to perform complex queries.

# Prerequisite

* Install the MSSQL server and create a database

* Add required configurations in the `Config.toml` file

# Run the example

To run the example, move into the `complex-queries-operation` project and execute the command below.

```shell
bal run
```
It will build the `complex-queries-operation` Ballerina project and then run it.

# Output of the example

This gives the following output when running this project.

```shell
Query Result :
{"customerId":2,"firstName":"Dan","lastName":"Brown","registrationId":2,"creditLimit":10000.0,"country":"UK"}
```