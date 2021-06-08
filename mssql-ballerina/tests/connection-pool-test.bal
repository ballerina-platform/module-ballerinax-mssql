// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.runtime as runtime;
import ballerina/sql;
import ballerina/lang.'string as strings;
import ballerina/test;

string poolDB_1 = "POOL_DB_1";
string poolDB_2 = "POOL_DB_2";

public type Result record {
    int val;
};

Options options = {
    socketTimeout: 1
};

@test:Config {
    groups: ["pool"]
}
function testLocalSharedConnectionPoolConfigSingleDestination() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 5};
    Client dbClient1 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    Client dbClient2 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    Client dbClient3 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    Client dbClient4 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    Client dbClient5 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    
    (stream<record{}, error>)[] resultArray = [];
    resultArray[0] = dbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[1] = dbClient2->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[2] = dbClient3->query("select count(*) as val from Customers where registrationID = 2", Result);
    resultArray[3] = dbClient4->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[4] = dbClient5->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[5] = dbClient5->query("select count(*) as val from Customers where registrationID = 2", Result);

    (int|error)[] returnArray = [];
    int i = 0;
    // Connections will be released here as we fully consume the data in the following conversion function calls
    foreach var x in resultArray {
        returnArray[i] = getReturnValue(x);
        i += 1;
    }

    check dbClient1.close();
    check dbClient2.close();
    check dbClient3.close();
    check dbClient4.close();
    check dbClient5.close();

    // All 5 clients are supposed to use the same pool created with the configurations given by the
    // custom pool options. Since each select operation holds up one connection each, the last select
    // operation should return an error
    i = 0;
    while(i < 5) {
        test:assertEquals(returnArray[i], 1);
        i = i + 1;
    }
    validateConnectionTimeoutError(returnArray[5]);
}

@test:Config {
    groups: ["pool"]
}
function testLocalSharedConnectionPoolConfigMultipleDestinations() returns error? {
    sql:ConnectionPool pool1 = {maxOpenConnections: 3};
    sql:ConnectionPool pool2 = {maxOpenConnections: 4};
    Client dbClient1 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool1);
    Client dbClient2 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool1);
    Client dbClient3 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool1);
    Client dbClient4 = check new (host, user, password, poolDB_2, poolPort, options=options, connectionPool=pool2);
    Client dbClient5 = check new (host, user, password, poolDB_2, poolPort, options=options, connectionPool=pool2);
    Client dbClient6 = check new (host, user, password, poolDB_2, poolPort, options=options, connectionPool=pool2);
    Client dbClient7 = check new (host, user, password, poolDB_2, poolPort, options=options, connectionPool=pool2);

    stream<record {} , error>[] resultArray = [];
    resultArray[0] = dbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[1] = dbClient2->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[2] = dbClient3->query("select count(*) as val from Customers where registrationID = 2", Result);
    resultArray[3] = dbClient3->query("select count(*) as val from Customers where registrationID = 1", Result);

    resultArray[4] = dbClient4->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[5] = dbClient5->query("select count(*) as val from Customers where registrationID = 2", Result);
    resultArray[6] = dbClient6->query("select count(*) as val from Customers where registrationID = 2", Result);
    resultArray[7] = dbClient6->query("select count(*) as val from Customers where registrationID = 1", Result);
    resultArray[8] = dbClient6->query("select count(*) as val from Customers where registrationID = 1", Result);
    
    (int|error)[] returnArray = [];
    int i = 0;
    // Connections will be released here as we fully consume the data in the following conversion function calls
    foreach var x in resultArray {
        returnArray[i] = getReturnValue(x);
        i += 1;
    }

    check dbClient1.close();
    check dbClient2.close();
    check dbClient3.close();
    check dbClient4.close();
    check dbClient5.close();
    check dbClient6.close();
    check dbClient7.close();

    // Since max pool size is 3, the last select function call going through each pool should fail.
    i = 0;
    while(i < 3) {
        test:assertEquals(returnArray[i], 1);
        test:assertEquals(returnArray[i + 4], 1);
        i = i + 1;
    }
    test:assertEquals(returnArray[7], 1);
    validateConnectionTimeoutError(returnArray[3]);
    validateConnectionTimeoutError(returnArray[8]);
}

@test:Config {
    groups: ["pool"]
}
function testLocalSharedConnectionPoolCreateClientAfterShutdown() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 2};
    Client dbClient1 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    Client dbClient2 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);

    var dt1 = dbClient1->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
    var dt2 = dbClient2->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
    int|error result1 = getReturnValue(dt1);
    int|error result2 = getReturnValue(dt2);

    // Since both clients are stopped the pool is supposed to shutdown.
    check dbClient1.close();
    check dbClient2.close();

    // This call should return an error as pool is shutdown
    var dt3 = dbClient1->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
    int|error result3 = getReturnValue(dt3);

    // Now a new pool should be created
    Client dbClient3 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);

    // This call should be successful
    var dt4 = dbClient3->query("SELECT count(*) as val from Customers where registrationID = 1", Result);
    int|error result4 = getReturnValue(dt4);

    check dbClient3.close();

    test:assertEquals(result1, 1);
    test:assertEquals(result2, 1);
    validateApplicationError(result3);
    test:assertEquals(result4, 1);
}

@test:Config {
    groups: ["pool"]
}
function testLocalSharedConnectionPoolStopInitInterleave() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 2};

    worker w1 returns error? {
        check testLocalSharedConnectionPoolStopInitInterleaveHelper1(pool, poolDB_1);
    }
    worker w2 returns int|error {
        return testLocalSharedConnectionPoolStopInitInterleaveHelper2(pool, poolDB_1);
    }

    check wait w1;
    int|error result = wait w2;
    test:assertEquals(result, 1);
}

function testLocalSharedConnectionPoolStopInitInterleaveHelper1(sql:ConnectionPool pool, string database)
returns error? {
    Client dbClient = check new (host, user, password, database, poolPort, options=options, connectionPool=pool);
    runtime:sleep(1);
    check dbClient.close();
}

function testLocalSharedConnectionPoolStopInitInterleaveHelper2(sql:ConnectionPool pool, string database)
returns @tainted int|error {
    runtime:sleep(1);
    Client dbClient = check new (host, user, password, database, poolPort, options=options, connectionPool=pool);
    var dt = dbClient->query("SELECT COUNT(*) as val from Customers where registrationID = 1", Result);
    int|error count = getReturnValue(dt);
    check dbClient.close();
    return count;
}

@test:Config {
    groups: ["pool"]
}
function testShutDownUnsharedLocalConnectionPool() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 2};
    Client dbClient = check new (host, user, password, poolDB_1, options=options, connectionPool=pool);

    var result = dbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
    int|error retVal1 = getReturnValue(result);
    // Pool should be shutdown as the only client using it is stopped.
    check dbClient.close();
    // This should result in an error return.
    var resultAfterPoolShutDown = dbClient->query("select count(*) as val from Customers where registrationID = 1",
        Result);
    int|error retVal2 = getReturnValue(resultAfterPoolShutDown);

    test:assertEquals(retVal1, 1);
    validateApplicationError(retVal2);
}

@test:Config {
    groups: ["pool"]
}
function testShutDownSharedConnectionPool() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 1};
    Client dbClient1 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    Client dbClient2 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);

    var result1 = dbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
    int|error retVal1 = getReturnValue(result1);

    var result2 = dbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
    int|error retVal2 = getReturnValue(result2);

    // Only one client is closed so pool should not shutdown.
    check dbClient1.close();

    // This should be successful as pool is still up.
    var result3 = dbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
    int|error retVal3 = getReturnValue(result3);

    // This should fail because, even though the pool is up, this client was stopped
    var result4 = dbClient1->query("select count(*) as val from Customers where registrationID = 2", Result);
    int|error retVal4 = getReturnValue(result4);

    // Now pool should be shutdown as the only remaining client is stopped.
    check dbClient2.close();

    // This should fail because this client is stopped.
    var result5 = dbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
    int|error retVal5 = getReturnValue(result4);

    test:assertEquals(retVal1, 1);
    test:assertEquals(retVal2, 1);
    test:assertEquals(retVal3, 1);
    validateApplicationError(retVal4);
    validateApplicationError(retVal5);
}

@test:Config {
    groups: ["pool"]
}
function testShutDownPoolCorrespondingToASharedPoolConfig() returns error? {
    sql:ConnectionPool pool = {maxOpenConnections: 1};
    Client dbClient1 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);
    Client dbClient2 = check new (host, user, password, poolDB_1, poolPort, options=options, connectionPool=pool);

    var result1 = dbClient1->query("select count(*) as val from Customers where registrationID = 1", Result);
    int|error retVal1 = getReturnValue(result1);

    var result2 = dbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
    int|error retVal2 = getReturnValue(result2);

    // This should result in stopping the pool used by this client as it was the only client using that pool.
    check dbClient1.close();

    // This should be successful as the pool belonging to this client is up.
    var result3 = dbClient2->query("select count(*) as val from Customers where registrationID = 2", Result);
    int|error retVal3 = getReturnValue(result3);

    // This should fail because this client was stopped.
    var result4 = dbClient1->query("select count(*) as val from Customers where registrationID = 2", Result);
    int|error retVal4 = getReturnValue(result4);

    check dbClient2.close();

    test:assertEquals(retVal1, 1);
    test:assertEquals(retVal2, 1);
    test:assertEquals(retVal3, 1);
    validateApplicationError(retVal4);
}

@test:Config {
    groups: ["pool"]
}
function testStopClientUsingGlobalPool() returns error? {
    // This client doesn't have pool config specified therefore, global pool will be used.
    Client dbClient = check new (host, user, password, poolDB_1, options=options);

    var result1 = dbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
    int|error retVal1 = getReturnValue(result1);

    // This will merely stop this client and will not have any effect on the pool because it is the global pool.
    check dbClient.close();

    // This should fail because this client was stopped, even though the pool is up.
    var result2 = dbClient->query("select count(*) as val from Customers where registrationID = 1", Result);
    int|error retVal2 = getReturnValue(result2);

    test:assertEquals(retVal1, 1);
    validateApplicationError(retVal2);
}

isolated function getReturnValue(stream<record{}, error> queryResult) returns int|error {
    int count = -1;
    record {|record {} value;|}? data = check queryResult.next();
    if (data is record {|record {} value;|}) {
        record {} value = data.value;
        if (value is Result) {
            count = value.val;
        }
    }
    check queryResult.close();
    return count;
}

isolated function validateApplicationError(int|error dbError) {
    test:assertTrue(dbError is error);
    sql:ApplicationError sqlError = <sql:ApplicationError> dbError;
    test:assertTrue(strings:includes(sqlError.message(), "Client is already closed"), sqlError.message());
}

isolated function validateConnectionTimeoutError(int|error dbError) {
    test:assertTrue(dbError is error);
    sql:DatabaseError sqlError = <sql:DatabaseError> dbError;
    test:assertTrue(strings:includes(sqlError.message(), "request timed out after"), sqlError.message());
}
