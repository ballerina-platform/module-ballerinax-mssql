# Overview

The `complex-queries-operation` project demonstrates how to use the MSSQL client to execute a stored procedure.

# Prerequisite

* Install the MSSQL server and create a database

* Add required configurations in the `config.toml` file

* Follow one of the following ways to add MSSQL database driver JAR in the `Ballerina.toml` file:
    * Download the JAR and update the path
        ```
            [[platform.java11.dependency]]
            path = "PATH"
        ```

    * Replace the above path with a maven dependency param
        ```
            [platform.java11.dependency]]
            url = "https://mvnrepository.com/artifact/com.microsoft.sqlserver/mssql-jdbc"
            groupId = "com.microsoft.sqlserver"
            artifactId = "mssql-jdbc"
            version = "9.2.0.jre11"
        ```
# Run the example

To run the example, move into the `complex-queries-operation` project and execute the below command.

```
$bal run
```
It will build the `complex-queries-operation` Ballerina project and then run it.

# Output of the example

This gives the following output when running this project.

```ballerina
Query Result :
{"customerId":2,"firstName":"Dan","lastName":"Brown","registrationId":2,"creditLimit":10000.0,"country":"UK"}
```