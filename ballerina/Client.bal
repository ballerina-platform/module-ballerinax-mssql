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

# Represents an MSSQL database client.
public isolated client class Client {
    *sql:Client;

    # Initializes the MSSQL Client. The client must be kept open throughout the application lifetime.
    #
    # + host - Hostname of the MSSQL server
    # + user - If the MSSQL server is secured, the username
    # + password - The password of the MSSQL server for the provided username
    # + database - The name of the database
    # + port - Port number of the MSSQL server
    # + instance - Instance name of the MSSQL server
    # + options - MSSQL database connection options
    # + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
    #                    `connectionPool` provided, the global connection pool (shared by all clients) will be used
    # + return - An `sql:Error` if the client creation fails
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

    # Executes the query, which may return multiple results.
    # When processing the stream, make sure to consume all fetched data or close the stream.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name=${albumName}` ``
    # + rowType - The `typedesc` of the record to which the result needs to be returned
    # + return - Stream of records in the `rowType` type
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.QueryProcessorUtils",
        name: "nativeQuery"
    } external;

    # Executes the query, which is expected to return at most one row of the result.
    # If the query does not return any results, an `sql:NoRowsError` is returned.
    #
    # + sqlQuery - The SQL query such as `` `SELECT * from Album WHERE name=${albumName}` ``
    # + returnType - The `typedesc` of the record to which the result needs to be returned.
    #                It can be a basic type if the query result contains only one column
    # + return - Result in the `returnType` type or an `sql:Error`
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.QueryProcessorUtils",
        name: "nativeQueryRow"
    } external;

    # Executes the SQL query. Only the metadata of the execution is returned (not the results from the query).
    #
    # + sqlQuery - The SQL query such as `` `DELETE FROM Album WHERE artist=${artistName}` ``
    # + return - Metadata of the query execution as an `sql:ExecutionResult` or an `sql:Error`
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.ExecuteProcessorUtils",
        name: "nativeExecute"
    } external;

    # Executes an SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is
    # returned (not results from the query). If one of the commands in the batch fails (except syntax error),
    # the `sql:BatchExecuteError` will be deferred until the remaining commands are completed.
    #
    # + sqlQueries - The SQL query with multiple sets of parameters
    # + return - Metadata of the query execution as an `sql:ExecutionResult[]` or an `sql:Error`
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes an SQL query, which calls a stored procedure. This may or may not
    # return results. Once the results are processed, the `close` method on `sql:ProcedureCallResult` must be called.
    #
    # + sqlQuery - The SQL query such as `` `CALL sp_GetAlbums();` ``
    # + rowTypes - `typedesc` array of the records to which the results need to be returned
    # + return - Summary of the execution and results are returned in an `sql:ProcedureCallResult`, or an `sql:Error`
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.CallProcessorUtils",
        name: "nativeCall"
    } external;

    # Closes the MSSQL client and shuts down the connection pool. The client must be closed only at the end of the
    # application lifetime (or closed for graceful stops in a service).
    #
    # + return - `()` or an `sql:Error`
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.mssql.nativeimpl.ClientProcessorUtils",
        name: "close"
    } external;
}

# Provides an additional set of configurations for the MSSQL client to be passed internally within the module.
#
# + host - Hostname of the MSSQL server
# + instance - Instance name of the MSSQL server
# + port - Port number of the MSSQL server
# + database - Name of the database
# + user - If the MSSQL server is secured, the username
# + password - The password of the MSSQL server for the provided username
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

# Provides a set of additional configurations related to the MSSQL database connection.
#
# + secureSocket - SSL configurations to be used
# + socketTimeout - Socket timeout (in seconds) to be used during the read/write operations with the MSSQL server
#                   (0 means no socket timeout)
# + queryTimeout - Timeout (in seconds) to be used when executing a query.
#                  (-1/0 means no query timeout)
# + loginTimeout - Timeout (in seconds) to be used when connecting to the MSSQL server and authentication (default is 15s).
# + useXADatasource - Flag to enable or disable XADatasource
public type Options record {|
    SecureSocket secureSocket?;
    decimal socketTimeout?;
    decimal queryTimeout?;
    decimal loginTimeout?;
    boolean useXADatasource = false;
|};

# SSL configurations to be used when connecting to the MSSQL server
#
# + encrypt - Encrypt all data sent between the client and the server if the server has a certificate
#             installed
# + trustServerCertificate - The MSSQL server SSL certificate is automatically trusted when the communication
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
