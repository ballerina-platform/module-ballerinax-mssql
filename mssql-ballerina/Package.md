## Package overview

This Package provides the functionality required to access and manipulate data stored in a MSSQL database.  

**Prerequisite:** Add the MSSQL driver JAR as a native library dependency in your Ballerina project. 
Once you build the project by executing the `ballerina build`
command, you should be able to run the resultant by executing the `ballerina run` command.

An example of the `Ballerina.toml` is given below.
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

### Client
To access a database, you must first create a 
`mssql:Client` object. 

#### Creating a client
This example shows different ways of creating the `mssql:Client`. 

The client can be created with an empty constructor and hence, the client will be initialized with the default properties. 
The first example with the `dbClient1` demonstrates this.

The `dbClient2` receives the host, username, and password. The properties are passed in the same order as they are defined. 

The `dbClient3` uses the named params to pass the attributes since it is skipping some params in the constructor. 


Similarly, the `dbClient4` uses the named params and it provides an unshared connection pool in the type of 
[sql:ConnectionPool](https://ballerina.io/learn/api-docs/ballerina/#/sql/records/ConnectionPool) 
to be used within the client. 
For more details about connection pooling, see the [SQL Package](https://ballerina.io/learn/api-docs/ballerina/#/sql).

```ballerina
mssql:Client|sql:Error dbClient1 = new ();
mssql:Client|sql:Error dbClient2 = new ("localhost", "sqlserver", "sqlserver", 
                              "sqlserver", 1433);
mssql:Options mssqlOptions = {
  queryTimeout: 10
};
mssql:Client|sql:Error dbClient3 = new (user = "sqlserver", password = "sqlserver",
                              options = mssqlOptions);
                              
mssql:Client|sql:Error dbClient4 = new (user = "sqlserver", password = "sqlserver",
                              connectionPool = {maxOpenConnections: 5});
```
The operations below can be handled by the `mssql:Client`.

1. Connection pooling
```
  sql:ConnectionPool connectionPool = {
          maxOpenConnections: 25,
          maxConnectionLifeTime : 15,
          minIdleConnections : 15
      };
  mssql:Client|sql:Error dbClient1 = new (host = "localhost", username = "sqlserver", password = "sqlserver",      
        database = "connectDB", port = 1433, connectionPool = connectionPool);
  sql:Error? e = dbClient1.close();

  mssql:Client|sql:Error dbClient2 = new (host = "localhost", username = "sqlserver", password = "sqlserver",
        database = "connectDB", port = 1433, connectionPool = connectionPool);
  sql:Error? e = dbClient2.close();
```
2. Querying data
```
  string varcharValue = "This is a varchar1";
  sql:ParameterizedQuery sqlQuery1 = `SELECT * from StringTypes WHERE varchar_type = ${varcharValue}`;
  mssql:Client|sql:Error dbClient = new ("localhost", "sqlserver", "sqlserver", "queryDb", 1433);
  stream<record {}, error> streamData = dbClient->query(sqlQuery);
  sql:Error? e = dbClient.close();
```
3. Inserting data
```
  mssql:Client|sql:Error dbClient = new ("localhost", "sqlserver", "sqlserver", "executeDb", 1433);
  sql:ExecutionResult|sql:Error result = dbClient->execute("Insert into Student (student_id) values (20)");
  sql:Error? e = dbClient.close();
```
4. Updating data
```
  mssql:Client|sql:Error dbClient = new ("localhost", "sqlserver", "sqlserver", "executeDb", 1433);
  sql:ExecutionResult|sql:Error result = dbClient->execute("Update StringTypes set varchar_type = 'updatedstring' 
        where varchar_type = 'str1'");
  sql:Error? e = dbClient.close();
```
5. Deleting data
```
  mssql:Client|sql:Error dbClient = new ("localhost", "sqlserver", "sqlserver", "executeDb", 1433);
  sql:ExecutionResult|sql:Error result = ddbClient->execute("Delete from ExactNumericTypes where int_type = 1451");
  sql:Error? e = dbClient.close();
```
6. Updating data in batches
```
  var data = [
    {row_id: 12, bigIntValue: 9223372036854775807, decimalValue: 123.34},
    {row_id: 13, bigIntValue: 9223372036854775807, decimalValue: 123.34},
    {row_id: 14, bigIntValue: 9223372036854775807, decimalValue: 123.34}
  ];
  sql:ParameterizedQuery[] sqlQueries =
      from var row in data
      select `INSERT INTO NumericTypes (row_id) VALUES (${row.row_id})`;
  mssql:Client|sql:Error dbClient = new ("localhost", "sqlserver", "sqlserver", "batchExecuteDb", 1433);
  sql:ExecutionResult[]|sql:Error result = dbClient->batchExecute(sqlQueries);
  sql:Error? e = dbClient.close();

```
7. Executing stored procedures
```
  string name = "John";
  string department = "Computer Science And Engineering";
  decimal score = 53.75;
  
  result = mssqlClient->execute(
    "Create procedure insertStudent "+
    "(@studentName varchar, @studentDepartment varchar, @studentScore decimal)"+
    " as "+
    "Insert into Student([name], [department], [score])"+
    " Values(@studentName,@studentDepartment,@studentScore);"
  );
  
  if(result is sql:Error){
    io:println("Error Occurred while creating the insertStudent procedure");
  }
  
  sql:ParameterizedCallQuery sqlQuery = `exec insertStudent ${name}, ${department}, ${score}`;
  mssql:Client|sql:Error dbClient = new ("localhost", "sqlserver", "sqlserver", "procedureDb", 1433);
  sql:ProcedureCallResult|sql:Error result = dbClient->call(sqlQuery);
  sql:Error? e = dbClient.close();
```
8. Closing the client
```
  mssql:Client|sql:Error dbClient = new ("localhost", "sqlserver", "sqlserver", "executeDb", 1433);
  sql:Error? e = dbClient.close();
```
