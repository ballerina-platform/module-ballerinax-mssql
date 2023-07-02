# Overview

The `batch-operation` project demonstrates how to use the MSSQL client to execute a stored procedure.

# Prerequisite

* Install the MSSQL server and create a database

* Add required configurations in the `config.toml` file

* Follow one of the following ways to add MSSQL database driver JAR in the `Ballerina.toml` file:
    * Download the JAR and update the path
        ```
        [[platform.java17.dependency]]
        path = "PATH"
        ```

    * Replace the above path with a maven dependency parameter
        ```
        [[platform.java17.dependency]]
        groupId = "com.microsoft.sqlserver"
        artifactId = "mssql-jdbc"
        version = "9.2.0.jre11"
        ```
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