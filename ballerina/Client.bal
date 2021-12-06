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

# Represents a MSSQL database client.
public isolated client class Client {
    *sql:Client;

    # Initialize the MSSQL client.
    #
    # + host - Hostname of the MSSQL server
    # + user - If the MSSQL server is secured, the username
    # + password - The password associated with the username
    # + database - The name of the database
    # + port - Port of the MSSQL server
    # + instance - Instance name of the MSSQL server
    # + options - MSSQL database conenction options
    # + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
    #                    `connectionPool` provided, the global connection pool (shared by all clients) will be used
    # + return - An `sql:Error` if the client creation fails
    public isolated function init(string host = "localhost", string? user = (), string? password = (), string? database = (),
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

    # Executes the query, which may return multiple results.
    #
    # + sqlQuery - The SQL query
    # + rowType - The `typedesc` of the record to which the result needs to be returned
    # + return - Stream of records in the `rowType` type
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.QueryProcessorUtils",
        name: "nativeQuery"
    } external;

    # Executes the query, which is expected to return at most one row of the result.
    # If the query does not return any results, `sql:NoRowsError` is returned
    #
    # + sqlQuery - The SQL query
    # + returnType - The `typedesc` of the record to which the result needs to be returned.
    #                It can be a basic type if the query contains only one column
    # + return - Result in the `returnType` type or an `sql:Error`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.QueryProcessorUtils",
        name: "nativeQueryRow"
    } external;

    # Executes the SQL query. Only the metadata of the execution is returned (not the results from the query).
    #
    # + sqlQuery - The SQL query
    # + return - Metadata of the query execution as an `sql:ExecutionResult` or an `sql:Error`
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.ExecuteProcessorUtils",
        name: "nativeExecute"
    } external;

    # Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is
    # returned (not results from the query). If one of the commands in the batch fails (except syntax error),
    # the `sql:BatchExecuteError` will be deferred until the rest of the commands are completed.
    #
    # + sqlQueries - The SQL query with multiple sets of parameters
    # + return - Metadata of the query execution as an `sql:ExecutionResult[]` or an `sql:Error`
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes a SQL query, which calls a stored procedure. This can return results or not.
    #
    # + sqlQuery - The SQL query
    # + rowTypes - The array `typedesc` of the records to which the results needs to be returned
    # + return - Summary of the execution and results are returned in an `sql:ProcedureCallResult`, or an `sql:Error`
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.CallProcessorUtils",
        name: "nativeCall"
    } external;

    # Closes the SQL client and shuts down the connection pool.
    #
    # + return - Possible error when closing the client
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.ClientProcessorUtils",
        name: "close"
    } external;
}

# Client Configuration record for connection initialization
#
# + host - Hostname of the mssql server
# + instance - Instance name of the server
# + port - Port number of the mssql server
# + database - Name of the database
# + user - Username for the database connection
# + password - Password for the database connection
# + options - MSSQL database specific options
# + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
#                    `connectionPool` provided, the global connection pool (shared by all clients) will be used
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

# Provides a set of configuration related to MSSQL database.
#
# + secureSocket - SSL Configuration to be used
# + socketTimeout - Socket timeout (in seconds) during the read/write operations with the MSSQL server
#                   (0 means no socket timeout)
# + queryTimeout - Timeout (in seconds) to be used when executing a query.
#                  (-1/0 means no query timeout)
# + loginTimeout - Timeout (in seconds) when connecting to the MSSQL server and authentication.
#                  (0 means 15s of login timeout which is the default behaviour of the driver)
public type Options record {|
    SecureSocket secureSocket?;
    decimal socketTimeout?;
    decimal queryTimeout?;
    decimal loginTimeout?;
|};

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

isolated function createClient(Client mssqlclient, ClientConfiguration clientConfig, sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method{
    'class: "io.ballerina.stdlib.mssql.nativeimpl.ClientProcessorUtils"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.mssql.nativeimpl.ExecuteProcessorUtils"
} external;
