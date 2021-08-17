// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.

// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;
import ballerina/test;

string connectDB = "CONNECT_DB";

@test:BeforeGroups {
    value: ["connection-init"]
}
function initConnectionTests() returns error? {
    _ = check executeQueryMssqlClient(`DROP DATABASE IF EXISTS CONNECT_DB`);
    _ = check executeQueryMssqlClient(`CREATE DATABASE CONNECT_DB`);
}

@test:Config {
    groups: ["connection", "connection-init"]
}
isolated function testConnectionWithNoFields() {
    Client|sql:Error dbClient = new ();
    test:assertTrue(dbClient is sql:Error, "Initialising connection with no fields fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithURLParams() returns error? {
    Client dbClient = check new (host = host, port = port, user = user, password = password, database = connectDB);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection with params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithoutHost() returns error? {
    Client dbClient = check new (port = port, user = user, password = password, database = connectDB);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection without host fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithoutPort() returns error? {
    Client dbClient = check new (host = host, user = user, password = password, database = connectDB);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection without port fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithoutDB() returns error? {
    Client dbClient = check new (user = user, password = password, port = port, host = host);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection without database fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithOptions() returns error? {
    Options options = {
        queryTimeout: 50,
        socketTimeout: 60,
        loginTimeout: 60
    };
    Client dbClient = check new (user = user, password = password, database = connectDB, port = port, options = options);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection with options fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionPool() returns error? {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25,
        maxConnectionLifeTime : 15,
        minIdleConnections : 15
    };
    Client dbClient = check new (user = user, password = password, database = connectDB, port = port,
                                 connectionPool = connectionPool);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection with option max connection pool fails.");
    test:assertEquals(connectionPool.maxOpenConnections, 25, "Configured max connection config is wrong.");
    test:assertEquals(connectionPool.maxConnectionLifeTime, <decimal>15, "Configured max connection life time second is wrong.");
    test:assertEquals(connectionPool.minIdleConnections, 15, "Configured min idle connection is wrong.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionParams1() returns error? {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25,
        maxConnectionLifeTime : 15,
        minIdleConnections : 15
    };
    Options options = {
        queryTimeout: 50,
        socketTimeout: 60,
        loginTimeout: 60
    };
    Client dbClient = check new (host = host, user = user, password = password, database = connectDB, port = port,
                                 options = options, connectionPool = connectionPool);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection with connection params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionParams2() returns error? {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25,
        maxConnectionLifeTime : 15,
        minIdleConnections : 15
    };
    Options options = {};
    Client dbClient = check new (host = host, user = user, password = password, options = options,
                                 connectionPool = connectionPool);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection with connection params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithConnectionParams3() returns error? {
    sql:ConnectionPool? connectionPool = ();
    Options? options = ();
    Client dbClient = check new (host = host, user = user, password = password, options = options,
                                 connectionPool = connectionPool);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection with connection params fails.");
}

@test:Config {
    groups: ["connection", "connection-init"]
}
function testWithClosedClient1() returns error? {
    Client dbClient = check new (user = user, password = password);
    sql:Error? closeResult = dbClient.close();
    test:assertExactEquals(closeResult, (), "Initialising connection with connection params fails.");
    sql:ExecutionResult|sql:Error result = dbClient->execute(`CREATE TABLE test (id int)`);
    if (result is sql:Error) {
        string expectedErrorMessage = "SQL Client is already closed, hence further operations are not allowed";
        test:assertTrue(result.message().startsWith(expectedErrorMessage), 
            "Error message does not match, actual :\n'" + result.message() + "'\nExpected : \n" + expectedErrorMessage);
    } else {
        test:assertFail("Error expected");
    }
}
