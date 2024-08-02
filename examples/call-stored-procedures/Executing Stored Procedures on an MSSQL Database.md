# Overview

The `call-stored-procedures` project demonstrates how to use the MSSQL client to execute a stored procedure.

# Prerequisite

* Install the MSSQL server and create a database

* Add required configurations in the `Config.toml` file

# Run the example

To run the example, move into the `call-stored-procedures` project and execute the command below.

```shell
bal run
```
It will build the `call-stored-procedures` Ballerina project and then run it.

# Output of the example

This gives the following output when running this project.

```shell
Call stored procedure `InsertCustomer`.
Inserted data: {"customerId":3,"firstName":"Bill","lastName":"John","registrationId":3,"creditLimit":5000.0,"country":"United Kingdom"}
```