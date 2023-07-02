# Overview

The `call-stored-procedures` project demonstrates how to use the MSSQL client to execute a stored procedure.

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
        version = "10.2.0.jre17"
        ```
# Run the example

To run the example, move into the `call-stored-procedures` project and execute the command below.

```
$bal run
```
It will build the `call-stored-procedures` Ballerina project and then run it.

# Output of the example

This gives the following output when running this project.

```ballerina
Call stored procedure `InsertCustomer`.
Inserted data: {"customerId":3,"firstName":"Bill","lastName":"John","registrationId":3,"creditLimit":5000.0,"country":"United Kingdom"}
```