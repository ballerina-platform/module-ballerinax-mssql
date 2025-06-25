// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;
import ballerina/sql;
import ballerina/crypto;

# MSSQL (Microsoft SQL) client that enables interaction with MSSQL servers and supports standard SQL operations.
public isolated client class Client {
    *sql:Client;

    # Connects to a MSSQL database with the specified configuration.
    #
    # + host - MSSQL server hostname
    # + user - Database username (if secured)
    # + password - Database password (if secured)
    # + database - Database name to connect to (optional)
    # + port - MSSQL server port
    # + instance - MSSQL server instance name (optional)
    # + options - Advanced connection options (optional)
    # + connectionPool - Connection pool for connection reuse. If not provided, the global connection pool (shared by all clients) will be used
    # + return - `sql:Error` if the client creation fails
    public isolated function init(string host = "localhost", string? user = "sa", string? password = (), string? database = (),
        int port = 1433, string instance = "", Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error? {
        ClientConfiguration clientConfig = {
            host: host,
            instance: instance,
            port: port,
            user: user,
            password: password,
            database: database,
            options: options,
            connectionPool: connectionPool
        };
        return createClient(self, clientConfig, sql:getGlobalConnectionPool());
    }

    # Executes a SQL query and returns multiple results as a stream.
    #
    # + sqlQuery - SQL query with optional parameters (e.g., `SELECT * FROM users WHERE id=${userId}`)
    # + rowType - Record type to map query results to
    # + return - Stream of records containing the query results. Please ensure that the stream is fully consumed, or close the stream.
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.QueryProcessorUtils",
        name: "nativeQuery"
    } external;

    # Executes a SQL query that is expected to return a single row or value as the result.
    # If the query returns no results, `sql:NoRowsError` is returned.
    #
    # + sqlQuery - The SQL query (e.g., `` `SELECT * FROM Album WHERE name=${albumName}` ``)
    # + returnType - The `typedesc` of the record to which the result should be mapped.
    #                It can be a basic type if the query result contains only one column
    # + return - Result in the `returnType` type or an `sql:Error`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.QueryProcessorUtils",
        name: "nativeQueryRow"
    } external;

    # Executes a SQL query and returns execution metadata (not the actual query results).
    #
    # + sqlQuery - SQL query with parameters (e.g., `` `DELETE FROM Album WHERE artist=${artistName}` ``)
    # + return - Execution metadata as an `sql:ExecutionResult`, or an `sql:Error` if execution fails
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.ExecuteProcessorUtils",
        name: "nativeExecute"
    } external;

    # Executes multiple SQL commands in a single batch operation, and returns execution metadata (not the actual query results).
    # If one command fails (except due to a syntax error), execution continues for the remaining commands and
    # the `sql:BatchExecuteError` will be returned at the end with details of all errors.
    #
    # + sqlQueries - Array of SQL queries with parameters
    # + return - Array of execution results or an `sql:Error` if the operation fails
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Calls a stored procedure with the given SQL query.
    # Once the results are processed, invoke the `close` method on the `sql:ProcedureCallResult`.
    #
    # + sqlQuery - SQL query to call the procedure (e.g., `` `CALL sp_GetAlbums()` ``)
    # + rowTypes - `typedesc` array of the records to which the results should be mapped
    # + return - Summary of the execution and results as `sql:ProcedureCallResult`, or an `sql:Error` if the call fails
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.CallProcessorUtils",
        name: "nativeCall"
    } external;

    # Closes the MSSQL client and shuts down the connection pool.
    # The client should be closed only at the end of the application lifetime, or when performing graceful stops in a service.
    #
    # + return - `sql:Error` if closing the client fails
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.ClientProcessorUtils",
        name: "close"
    } external;
}

# MSSQL client connection configuration.
#
# + host - MSSQL server hostname
# + instance - MSSQL server instance name
# + port - MSSQL server port
# + user - Database username
# + password - Database password
# + database - Database name
# + options - Advanced connection options
# + connectionPool - Connection pool configuration
type ClientConfiguration record {|
    string host;
    string? instance;
    int port;
    string? user;
    string? password;
    string? database;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

# Advanced MSSQL connection options.
#
# + secureSocket - SSL/TLS security settings
# + socketTimeout - Socket read/write timeout in seconds (0 means no timeout)
# + queryTimeout - Query execution timeout in seconds (-1/0 means no timeout)
# + loginTimeout - Connection and authentication timeout in seconds (default is 15 seconds)
# + useXADatasource - Enable XA transactions
public type Options record {|
    SecureSocket secureSocket?;
    decimal socketTimeout?;
    decimal queryTimeout?;
    decimal loginTimeout?;
    boolean useXADatasource = false;
|};

# SSL configurations to be used when connecting to the MSSQL server.
#
# + encrypt - Enable encryption for all data sent between client and server if server has a certificate installed
# + trustServerCertificate - Automatically trust the MSSQL server SSL certificate when communication layer is encrypted using TLS
# + cert - Keystore configuration of the trust certificates
# + key - Keystore configuration of the client certificates
public type SecureSocket record {|
    boolean encrypt?;
    boolean trustServerCertificate?;
    crypto:TrustStore cert?;
    crypto:KeyStore key?;
|};

isolated function createClient(Client mssqlclient, ClientConfiguration clientConfig, sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method{
    'class: "io.ballerina.stdlib.mssql.nativeimpl.ClientProcessorUtils"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.mssql.nativeimpl.ExecuteProcessorUtils"
} external;
