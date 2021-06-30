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

    # Initialize the Mssql client.
    #
    # + host - Hostname of the MSSQL server to be connected
    # + user - If the MSSQL server is secured, the username to be used to connect to the SQL server
    # + password - The password associated with the username of the database
    # + database - The name of the database to be connected
    # + port - Port of the MSSQL server to be connected
    # + instance - Instance name of the MSSQL server to be connected as MSSQL can have installations of multiple versions 
    #              under a single server.
    # + options - The database-specific JDBC client properties
    # + connectionPool - The `sql:ConnectionPool` object to be used within the MSSQL client.
    #                   If there is no `connectionPool` provided, the global connection pool will be used and it will
    #                   be shared by other clients which have the same properties.
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

    # Queries the database with the query provided by the user and returns the result as a stream.
    #
    # + sqlQuery - The query which needs to be executed as  a `string` or `ParameterizedQuery` when the SQL query has
    #              params to be passed in
    # + rowType - The `typedesc` of the record that should be returned as a result. If this is not provided, the default
    #             column names of the query result set will be used for the record attributes.
    # + return - Stream of records in the type of `rowType`
    remote isolated function query(string|sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream <rowType, sql:Error> = @java:Method {
        'class: "org.ballerinalang.mssql.nativeimpl.QueryProcessorUtils",
        name: "nativeQuery"
    } external;

    # Executes the DDL or DML SQL queries provided by the user, and returns a summary of the execution.
    #
    # + sqlQuery - The DDL or DML query such as INSERT, DELETE, UPDATE, etc. as a `string` or `ParameterizedQuery`
    #              when the query has params to be passed in
    # + return - Summary of the SQL update query as an `ExecutionResult` or returns an `Error`
    #           if any error occurred when executing the query
    remote isolated function execute(string|sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult|sql:Error {
        return nativeExecute(self, sqlQuery);
    }

    # Executes a batch of parameterized DDL or DML SQL query provided by the user
    # and returns the summary of the execution.
    #
    # + sqlQueries - The DDL or DML query such as INSERT, DELETE, UPDATE, etc. as a `ParameterizedQuery` with an array
    #                of values passed in
    # + return - Summary of the executed SQL queries as an `ExecutionResult[]` which includes details such as
    #            `affectedRowCount` and `lastInsertId`. If one of the commands in the batch fails, this function
    #            will return a `BatchExecuteError`. However, the JDBC driver may or may not continue to process the
    #            remaining commands in the batch after a failure. The summary of the executed queries in case of an error
    #            can be accessed as `(<sql:BatchExecuteError> result).detail()?.executionResults`.
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if (sqlQueries.length() == 0) {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Executes a SQL stored procedure and returns the result as a stream and an execution summary.
    #
    # + sqlQuery - The query to execute the SQL stored procedure
    # + rowTypes - The array of `typedesc` of the records that should be returned as a result. If this is not provided,
    #               the default column names of the query result set will be used for the record attributes.
    # + return - Summary of the execution is returned in a `ProcedureCallResult` or an `sql:Error`
    remote isolated function call(string|sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error {
        return nativeCall(self, sqlQuery, rowTypes);
    }

    # Close the SQL client.
    #
    # + return - Possible error during closing the client
    public isolated function close() returns sql:Error? {
        return close(self);
    }

}

# Client Configuration record for connection initialization
#
# + host - Hostname of the mssql server to be connected
# + instance - Instance name of the server to be connected as mssql can have installations of multiple versions 
#              under a single server
# + port - Port number of the mssql server to be connected
# + database - Name of the database
# + user - Username for the database connection
# + password - Password for the database connection
# + options - MSSQL database specific options
# + connectionPool - The `sql:ConnectionPool` object to be used within 
#         the jdbc client. If there is no connectionPool provided, 
#         the global connection pool will be used
type ClientConfiguration record {|
    string host;
    string? instance;
    int port;
    string? user;
    string? password;
    string? database;
    Options? options;
    sql:ConnectionPool?  connectionPool;
|};

# MSSQL database options.
#
# + secureSocket - SSL Configuration to be used
# + socketTimeout - The number of milliseconds to wait before a timeout occurs
#                   on a socket read or accept. The default value is 0, which means 
#                   infinite timeout
# + queryTimeout - The number of seconds to wait before a timeout has occurred on a 
#                  query. The default value is -1, which means infinite timeout.
#                  Setting this to 0 also implies to wait indefinitely
# + loginTimeout - The number of seconds the driver should wait before timing out a 
#                  failed connection. A zero value indicates that the timeout is the
#                  default system timeout, which is specified as 15 seconds by default.
#                  A non-zero value is the number of seconds the driver should wait
#                  before timing out a failed connection
public type Options record {|
    SecureSocket secureSocket?;
    decimal socketTimeout?;
    decimal queryTimeout?;
    decimal loginTimeout?;
|};

# SSL configuration to be used when connecting to the MSSQL server
#
# + encrypt - Encryption for all the data sent between the client and the server if the server has a certificate
#             installed
# + trustServerCertificate - If "true", the SQL Server SSL certificate is automatically trusted when the communication
#                            layer is encrypted using TLS
# + cert - Keystore configuration of the trust certificates
# + key - Keystore configuration of the client certificates
public type SecureSocket record {|
    boolean encrypt?
    boolean trustServerCertificate?;
    crypto:TrustStore cert?;
    crypto:KeyStore key?;
|};

isolated function createClient(Client mssqlclient, ClientConfiguration clientConfig, sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method{
    'class: "org.ballerinalang.mssql.nativeimpl.ClientProcessorUtils"
} external;

isolated function nativeExecute(Client sqlClient, string|sql:ParameterizedQuery sqlQuery)
returns sql:ExecutionResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.mssql.nativeimpl.ExecuteProcessorUtils"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "org.ballerinalang.mssql.nativeimpl.ExecuteProcessorUtils"
} external;

isolated function nativeCall(Client sqlClient, string|sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes)
returns sql:ProcedureCallResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.mssql.nativeimpl.CallProcessorUtils"
} external;

isolated function close(Client mssqlClient) returns sql:Error? = @java:Method {
    'class: "org.ballerinalang.mssql.nativeimpl.ClientProcessorUtils"
} external;
