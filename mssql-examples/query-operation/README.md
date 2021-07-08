# Overview

The `query-operation` project demonstrates how to use the MSSQL client to execute a stored procedure.

# Prerequisite

* Install the MSSQL server and create a database

* Add required configurations in the `config.toml` file

* Follow one of the following ways to add MSSQL database driver JAR in the `Ballerina.toml` file:
    * Download the JAR and update the path
        ```
        [[platform.java11.dependency]]
        path = "PATH"
        ```

    * Replace the above path with a maven dependency parameter
        ```
        [[platform.java11.dependency]]
        groupId = "com.microsoft.sqlserver"
        artifactId = "mssql-jdbc"
        version = "9.2.0.jre11"
        ```
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