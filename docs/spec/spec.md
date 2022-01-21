# Specification: Ballerina MSSQL Library

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2022/01/14   
_Updated_: 2022/01/14  
_Issue_: [#2292](https://github.com/ballerina-platform/ballerina-standard-library/issues/2292)

# Introduction

This is the specification for MSSQL standard library, which provides the functionality that is required to access and 
manipulate data stored in a MSSQL database in the [Ballerina programming language](https://ballerina.io/), 
which is an open-source programming language for the cloud that makes it easier to use, combine, and create network 
services.

# Contents

1. [Overview](#1-overview)
2. [Client](#2-client)  
   2.1. [Connection Pool Handling](#21-connection-pool-handling)  
   2.2. [Closing the Client](#22-closing-the-client)
3. [Queries and Values](#3-queries-and-values)
4. [Database Operations](#4-database-operations)

# 1. Overview

This specification elaborates on usage of MSSQL `Client` object to interface with an MSSQL database.

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes a SQL query, which calls a stored procedure. This can either return results or nil.

All the above operations make use of `sql:ParameterizedQuery` object, backtick surrounded string template to pass
SQL statements to the database. `sql:ParameterizedQuery` supports passing of Ballerina basic types or Typed SQL Values
such as `sql:CharValue`, `sql:BigIntValue`, etc. to indicate parameter types in SQL statements.

# 2. Client

Each client represents a pool of connections to the database. The pool of connections is maintained throughout the
lifetime of the client.

**Initialisation of the Client:**
```ballerina
# Initialize the MSSQL client.
#
# + host - Hostname of the MSSQL server
# + user - If the MSSQL server is secured, the username
# + password - The password associated with the username
# + database - The name of the database
# + port - Port of the MSSQL server
# + instance - Instance name of the MSSQL server
# + options - MSSQL database connection options
# + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
#                    `connectionPool` provided, the global connection pool (shared by all 
#                    clients) will be used
# + return - An `sql:Error` if the client creation fails
public isolated function init(string host = "localhost", string? user = (), 
        string? password = (), string? database = (), int port = 1433, string instance = "", 
        Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error?;
```

**Configurations available for initializing the MSSQL client:**
* Connection properties:
  ```ballerina
  # Provides a set of configuration related to MSSQL database.
  #
  # + secureSocket - SSL Configuration to be used
  # + socketTimeout - Socket timeout (in seconds) during the read/write operations 
  #                   with the MSSQL server (0 means no socket timeout)
  # + queryTimeout - Timeout (in seconds) to be used when executing a query.
  #                  (-1/0 means no query timeout)
  # + loginTimeout - Timeout (in seconds) when connecting to the MSSQL server and 
  #                  authentication (Default is 15s).
  public type Options record {|
      SecureSocket secureSocket?;
      decimal socketTimeout?;
      decimal queryTimeout?;
      decimal loginTimeout?;
  |};
  ``` 
* SSL Connection:
  ```
  # SSL configuration to be used when connecting to the MSSQL server
  #
  # + encrypt - Encrypt all data sent between the client and the server if the server has a certificate
  #             installed
  # + trustServerCertificate - The SQL Server SSL certificate is automatically trusted when the communication
  #                            layer is encrypted using TLS
  # + cert - Keystore configuration of the trust certificates
  # + key - Keystore configuration of the client certificates
  public type SecureSocket record {|
      boolean encrypt?;
      boolean trustServerCertificate?;
      crypto:TrustStore cert?;
      crypto:KeyStore key?;
  |};
  ```

## 2.1. Connection Pool Handling

Connection Pool Handling is generic and implemented through `sql` module. For more information, see the
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#21-connection-pool-handling)

## 2.2. Closing the Client

Once all the database operations are performed, the client can be closed by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

   ```ballerina
    # Closes the MSSQL client and shuts down the connection pool.
    #
    # + return - Possible error when closing the client
    public isolated function close() returns Error?;
   ```

# 3. Queries and Values

All the generic `sql` Queries and Values are supported. For more information, see the
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-queries-and-values)

In addition to `sql` Values, `mssql` package supports the following additional Typed Values for MSSQL Geometric and Money Types,
1. CompoundCurveElement
   * LineStringValue
   * CircularStringValue
2. CircularArcRing
   * LineStringValue
   * CircularStringValue
   * CompoundCurveValue
3. GeometryCollectionElement
   * PointValue
   * LineStringValue
   * CircularStringValue
   * CompoundCurveValue
   * PolygonValue
   * CurvePolygonValue
   * MultiPointValue
   * MultiLineStringValue
   * MultiPolygonValue
4. MoneyValue
5. SmallMoneyValue

# 4. Database Operations

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes a SQL query, which calls a stored procedure. This can either return results or nil.

For more information on Database Operations see the [SQL Specification](https://github.com/niveathika/module-ballerina-sql/blob/master/docs/spec/spec.md#4-database-operations)
