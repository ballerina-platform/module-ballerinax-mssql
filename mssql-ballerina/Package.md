## Package overview

This Package provides the functionality required to access and manipulate data stored in a MsSQL database.  

**Prerequisite:** Add the MsSQL driver JAR as a native library dependency in your Ballerina project. 
Once you build the project by executing the `ballerina build`
command, you should be able to run the resultant by executing the `ballerina run` command.

E.g., The `Ballerina.toml` content.
Change the path to the JDBC driver appropriately.

```toml
[package]
org = "sample"
name = "mssql"
version= "0.1.0"

[[platform.java11.dependency]]
path = "/path/to/mssql-jdbc-9.2.0.jre11.jar"
artifactId = "mssql-jdbc"
groupId = "mssql"
version = "9.2.0.jre11"
```

//TO BE DONE