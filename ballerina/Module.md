## Overview

This module provides the functionality required to access and manipulate data stored in an MSSQL database.

### Prerequisite
Add the MSSQL driver as a dependency to the Ballerina project.

>**Note**: `ballerinax/mssql` supports MSSQL driver versions above 9.20.

You can achieve this by importing the `ballerinax/mssql.driver` module,
 ```ballerina
 import ballerinax/mssql.driver as _;
 ```

`ballerinax/mssql.driver` package bundles the latest MSSQL driver JAR.

>**Tip**: GraalVM native build is supported when `ballerinax/mssql` is used along with the `ballerinax/mssql.driver`

If you want to add a MSSQL driver of a specific version, you can add it as a dependency in Ballerina.toml.
Follow one of the following ways to add the JAR in the file:

* Download the JAR and update the path.
    ```
    [[platform.java17.dependency]]
    path = "PATH"
    ```

* Add JAR with the maven dependency params.
    ```
    [[platform.java17.dependency]]
    groupId = "com.microsoft.sqlserver"
    artifactId = "mssql-jdbc"
    version = "9.2.0.jre11"
    ```

### Client
To access a database, you must first create an
[`mssql:Client`](https://docs.central.ballerina.io/ballerinax/mssql/latest/clients/Client) object.
The examples for creating an MSSQL client can be found below.

> **Tip**: The client should be used throughout the application lifetime.

#### Create a client
These examples show the different methods of creating an `mssql:Client`.

The client can be created with an empty constructor, and thereby, will be initialized with the default properties.

```ballerina
mssql:Client|sql:Error dbClient = new();
```

The `mssql:Client` receives the host, username, and password. Since the properties are passed in the same order as they are defined
in the `mssql:Client`, you can pass them without named parameters.

```ballerina
mssql:Client|sql:Error dbClient = new(
   "localhost", "rootUser", "rootPass", "information_schema", 1443
);
```

The sample below shows an `mssql:Client`, which uses named parameters to pass the attributes since some parameters are skipped in the constructor.
Further, the [`mssql:Options`](https://docs.central.ballerina.io/ballerinax/mssql/latest/records/Options)
property is passed to configure the SSL and login timeout properties in the MSSQL client.

```ballerina
mssql:Options mssqlOptions = {
  secureSocket: {
    encrypt: true,
    cert: {
       path: "trustStorePath",
       password: "password"
    }
  },
  loginTimeout: 10
};

mssql:Client|sql:Error dbClient = new(
   user = "rootUser", password = "rootPass", options = mssqlOptions
);
```

Similarly, in the sample below, the `mssql:Client` uses named parameters, and it provides an unshared connection pool of the
[`sql:ConnectionPool`](https://docs.central.ballerina.io/ballerina/sql/latest/records/ConnectionPool)
type to be used within the client.
For more details about connection pooling, see the [`sql` module](https://docs.central.ballerina.io/ballerina/sql/latest).

```ballerina
mssql:Client|sql:Error dbClient = new(
   user = "rootUser", password = "rootPass", 
   connectionPool = {maxOpenConnections: 5}
);
```

#### SSL usage
To connect to the MSSQL database using an SSL connection, you must add the SSL configurations to the `mssql:Options` when creating the `mssql:Client`.
The value of `encrypt` must be set to `true`.
If `trustServerCertificate` is set to `true`, the client will not validate the server TLS/SSL certificate (used for testing in local environments).
The key and cert files must be provided in the `.p12` format.

```ballerina
string clientStorePath = "/path/to/keystore.p12";
string trustStorePath = "/path/to/truststore.p12";

mssql:Options mssqlOptions = {
  secureSocket: {
    encrypt: true,
    trustServerCertificate: false
    key: {
        path: clientStorePath,
        password: "password"
    },
    cert: {
        path: trustStorePath,
        password: "password"
    }
  }
};
```

#### Handle connection pools

All database modules share the same connection pooling concept and there are three possible scenarios for
connection pool handling. For its properties and possible values, see [`sql:ConnectionPool`](https://docs.central.ballerina.io/ballerina/sql/latest/records/ConnectionPool).

>**Note**: Connection pooling is used to optimize opening and closing connections to the database. However, the pool comes with an overhead. It is best to configure the connection pool properties as per the application need to get the best performance.

1. Global, shareable, default connection pool

   If you do not provide the `connectionPool` field when creating the database client, a globally-shareable pool will be
   created for your database unless a connection pool matching with the properties you provided already exists.

    ```ballerina
    mssql:Client|sql:Error dbClient = new ("localhost", "rootUser", "rootPass");
    ```

2. Client-owned, unsharable connection pool

   If you define the `connectionPool` field inline when creating the client with the `sql:ConnectionPool` type,
   an unsharable connection pool will be created.

    ```ballerina
    mssql:Client|sql:Error dbClient = new ("localhost", "rootUser", "rootPass", 
                                           connectionPool = { maxOpenConnections: 5 });
    ```

3. Local, shareable connection pool

   If you create a record of the `sql:ConnectionPool` type and reuse that in the configuration of multiple clients,
   for each set of clients that connects to the same database instance with the same set of properties, a shared
   connection pool will be created.

    ```ballerina
    sql:ConnectionPool connPool = {maxOpenConnections: 5};
    
    mssql:Client|sql:Error dbClient1 = new(
        "localhost", "rootUser", "rootPass", connectionPool = connPool
    );
    mssql:Client|sql:Error dbClient2 = new(
        "localhost", "rootUser", "rootPass", connectionPool = connPool
    );
    mssql:Client|sql:Error dbClient3 = new(
        "localhost", "rootUser", "rootPass", connectionPool = connPool
    );
    ```

For more details about each property, see the [`mssql:Client`](https://docs.central.ballerina.io/ballerinax/mssql/latest/clients/Client) constructor.

The [`mssql:Client`](https://docs.central.ballerina.io/ballerinax/mssql/latest/clients/Client) references
[`sql:Client`](https://docs.central.ballerina.io/ballerina/sql/latest/clients/Client) and all the operations
defined by the `sql:Client` will be supported by the `mssql:Client` as well.

#### Close the client

Once all the database operations are performed, you can close the client you have created by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

> **Note**: The client must be closed only at the end of the application lifetime (or closed for graceful stops in a service).

```ballerina
error? e = dbClient.close();
```
Or
```ballerina
check dbClient.close();
```

### Database operations

Once the client is created, database operations can be executed through that client. This module defines the interface
and common properties that are shared among multiple database clients. It also supports querying, inserting, deleting,
updating, and batch updating data.

#### Parameterized query

The `sql:ParameterizedQuery` is used to construct the SQL query to be executed by the client.
You can create a query with constant or dynamic input data as follows.

*Query with constant values*

```ballerina
sql:ParameterizedQuery query = `SELECT * FROM students 
                                WHERE id < 10 AND age > 12`;
```

*Query with dynamic values*

```ballerina
int[] ids = [10, 50];
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${ids[0]} AND age > ${age}`;
```

Moreover, the SQL module has `sql:queryConcat()` and `sql:arrayFlattenQuery()` util functions which make it easier
to create a dynamic/constant complex query.

The `sql:queryConcat()` is used to create a single parameterized query by concatenating a set of parameterized queries.
The sample below shows how to concatenate queries.

```ballerina
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students`;
sql:ParameterizedQuery query1 = ` WHERE id < ${id} AND age > ${age}`;
sql:ParameterizedQuery sqlQuery = sql:queryConcat(query, query1);
```

A query with the `IN` operator can be created using the `sql:ParameterizedQuery` as shown below. Here, you need to flatten the array and pass each element separated by a comma.

```ballerina
int[] ids = [1, 2, 3];
sql:ParameterizedQuery query = `SELECT count(*) as total FROM DataTable 
                                WHERE row_id IN (${ids[0]}, ${ids[1]}, ${ids[2]})`;
```

The `sql:arrayFlattenQuery()` util function is used to make the array flattening easier. It makes the inclusion of varying array elements into the query easier by flattening the array to return a parameterized query. You can construct the complex dynamic query with the `IN` operator by using both functions as shown below.

```ballerina
int[] ids = [1, 2];
sql:ParameterizedQuery sqlQuery = 
                         sql:queryConcat(`SELECT * FROM DataTable WHERE id IN (`, 
                                          sql:arrayFlattenQuery(ids), `)`);
```

#### Create tables

This sample creates a table with three columns. The first column is a primary key of type `int`
while the second column is of type `int` and the other is of type `varchar`.
The `CREATE` statement is executed via the `execute` remote method of the client.

```ballerina
// Create the ‘Students’ table with the ‘id’, ’age’, and ’name’ fields.
sql:ExecutionResult result = 
                check dbClient->execute(`CREATE TABLE student (
                                           id INT AUTO_INCREMENT,
                                           age INT, 
                                           name VARCHAR(255), 
                                           PRIMARY KEY (id)
                                         )`);
// A value of the sql:ExecutionResult type is returned for 'result'. 
```

#### Insert data

These samples show the data insertion by executing an `INSERT` statement using the `execute` remote method
of the client.

In this sample, the query parameter values are passed directly into the query statement of the `execute`
remote method.

```ballerina
sql:ExecutionResult result = check dbClient->execute(`INSERT INTO student(age, name)
                                                        VALUES (23, 'john')`);
```

In this sample, the parameter values, which are assigned to local variables are used to parameterize the SQL query in
the `execute` remote method. This type of parameterized SQL query can be used with any primitive Ballerina type
such as `string`, `int`, `float`, or `boolean` and in that case, the corresponding SQL type of the parameter is derived
from the type of the Ballerina variable that is passed.

```ballerina
string name = "Anne";
int age = 8;

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                  VALUES (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
```

In this sample, the parameter values are passed as an `sql:TypedValue` to the `execute` remote method. Use the
corresponding subtype of the `sql:TypedValue` such as `sql:VarcharValue`, `sql:CharValue`, `sql:IntegerValue`, etc., when you need to
provide more details such as the exact SQL type of the parameter.

```ballerina
sql:VarcharValue name = new ("James");
sql:IntegerValue age = new (10);

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                  VALUES (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Insert data with auto-generated keys

This sample demonstrates inserting data while returning the auto-generated keys. It achieves this by using the
`execute` remote method to execute the `INSERT` statement.

```ballerina
int age = 31;
string name = "Kate";

sql:ParameterizedQuery query = `INSERT INTO student(age, name)
                                  VALUES (${age}, ${name})`;
sql:ExecutionResult result = check dbClient->execute(query);

// Number of rows affected by the execution of the query.
int? count = result.affectedRowCount;

// The integer or string generated by the database in response to a query execution.
string|int? generatedKey = result.lastInsertId;
```

#### Query data

These samples show how to demonstrate the different usages of the `query` operation to query the
database table and obtain the results as a stream.

>**Note**: When processing the stream, make sure to consume all fetched data or close the stream.

This sample demonstrates querying data from a table in a database.
First, a type is created to represent the returned result set. This record can be defined as an open or a closed record
according to the requirement. If an open record is defined, the returned stream type will include both defined fields
in the record and additional database columns fetched by the SQL query, which are not defined in the record.

>**Note**: the mapping of the database column to the returned record's property is case-insensitive if it is defined in  the record(i.e., the `ID` column in the result can be mapped to the `id` property in the record). Additional column names are added to the returned record as in the SQL query. If the record is defined as a closed record, only the  defined fields in the record are returned or gives an error when additional columns are present in the SQL query. 

Next, the `SELECT` query is executed via the `query` remote method of the client. Once the query is executed, each data record 
can be retrieved by iterating through the result set. The `stream` returned by the `SELECT` operation holds a pointer to the
actual data in the database, and it loads data from the table only when it is accessed. This stream can be iterated only
once.

```ballerina
// Define an open record type to represent the results.
type Student record {
    int id;
    int age;
    string name;
};

// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` samples, parameters can be passed as
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<Student, sql:Error?> resultStream = dbClient->query(query);

// Iterating the returned table.
check from Student student in resultStream
   do {
       // Can perform operations using the record 'student' of type `Student`.
   };
```

Defining the return type is optional, and you can query the database without providing the result type. Hence,
the above sample can be modified as follows with an open record type as the return type. The property name in the open record
type will be the same as how the column is defined in the database.

```ballerina
// Select the data from the database table. The query parameters are passed 
// directly. Similar to the `execute` samples, parameters can be passed as 
// sub types of `sql:TypedValue` as well.
int id = 10;
int age = 12;
sql:ParameterizedQuery query = `SELECT * FROM students
                                WHERE id < ${id} AND age > ${age}`;
stream<record{}, sql:Error?> resultStream = dbClient->query(query);

// Iterating the returned table.
check from record{} student in resultStream
   do {
      // Can perform operations using the record 'student'.
      io:println("Student name: ", student.value["name"]);
   };
```

There are situations in which you may not want to iterate through the database, and in that case, you may decide
to use the `queryRow()` operation. If the provided return type is a record, this method returns only the first row
retrieved by the query as a record.

```ballerina
int id = 10;
sql:ParameterizedQuery query = `SELECT * FROM students WHERE id = ${id}`;
Student retrievedStudent = check dbClient->queryRow(query);
```

The `queryRow()` operation can also be used to retrieve a single value from the database (e.g., when querying using
`COUNT()` and other SQL aggregation functions). If the provided return type is not a record (i.e., a primitive data type)
, this operation will return the value of the first column of the first row retrieved by the query.

```ballerina
int age = 12;
sql:ParameterizedQuery query = `SELECT COUNT(*) FROM students WHERE age < ${age}`;
int youngStudents = check dbClient->queryRow(query);
```

#### Update data

This sample demonstrates modifying data by executing an `UPDATE` statement via the `execute` remote method of
the client.

```ballerina
int age = 23;
sql:ParameterizedQuery query = `UPDATE students SET name = 'John' WHERE age = ${age}`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Delete data

This sample demonstrates deleting data by executing a `DELETE` statement via the `execute` remote method of
the client.

```ballerina
string name = "John";
sql:ParameterizedQuery query = `DELETE from students WHERE name = ${name}`;
sql:ExecutionResult result = check dbClient->execute(query);
```

#### Batch update data

This sample demonstrates how to insert multiple records with a single `INSERT` statement that is executed via the
`batchExecute` remote method of the client. This is done by creating a `table` with multiple records and
parameterized SQL query as same as the above `execute` operations.

```ballerina
// Create the table with the records that need to be inserted.
var data = [
  { name: "John", age: 25 },
  { name: "Peter", age: 24 },
  { name: "jane", age: 22 }
];

// Do the batch update by passing the batches.
sql:ParameterizedQuery[] batch = from var row in data
                                 select `INSERT INTO students ('name', 'age')
                                           VALUES (${row.name}, ${row.age})`;
sql:ExecutionResult[] result = check dbClient->batchExecute(batch);
```

#### Execute SQL stored procedures

This sample demonstrates how to execute a stored procedure with a single `INSERT` statement that is executed via the
`call` remote method of the client.

```ballerina
int uid = 10;
sql:IntegerOutParameter insertId = new;

sql:ProcedureCallResult result = 
                         check dbClient->call(`call InsertPerson(${uid}, ${insertId})`);
stream<record{}, sql:Error?>? resultStr = result.queryResult;
if resultStr is stream<record{}, sql:Error?> {
   check from record{} result in resultStr
      do {
         // Can perform operations using the record 'result'.
      };
}
check result.close();
```

>**Note**: Once the results are processed, the `close` method on the `sql:ProcedureCallResult` must be called.

>**Note**: The default thread pool size used in Ballerina is: `the number of processors available * 2`. You can configure the thread pool size by using the `BALLERINA_MAX_POOL_SIZE` environment variable.
