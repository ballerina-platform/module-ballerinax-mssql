// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.runtime;
import ballerina/test;
import ballerinax/cdc;
import ballerinax/mssql.cdc.driver as _;

string cdcUsername = "sa";
string cdcPassword = "root@123";
string cdcDatabase = "store_db";
int cdcPort = 1431;
decimal sleepBetweenSteps = 10;

cdc:Service testService = service object {
    remote function onCreate(record {} after, string tableName = "") returns error? {
    }
};

function getDummyMsSqlListener() returns CdcListener {
    return new ({
        database: {
            username: "testUser",
            password: "testPassword",
            databaseNames: "test"
        }
    });
}

@test:Config {
    groups: ["cdc"]
}
function testStartingWithoutAService() returns error? {
    CdcListener mssqlListener = getDummyMsSqlListener();
    cdc:Error? result = mssqlListener.'start();
    test:assertEquals(result is () ? "" : result.message(), "Cannot start the listener without at least one attached service.");
}

@test:Config {
    groups: ["cdc"]
}
function testStopWithoutStart() returns error? {
    CdcListener mssqlListener = getDummyMsSqlListener();
    error? result = mssqlListener.gracefulStop();
    test:assertTrue(result is ());
}

@test:Config {
    groups: ["cdc"]
}
function testStartWithConflictingServices() returns error? {
    CdcListener mssqlListener = getDummyMsSqlListener();

    cdc:Service service1 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    cdc:Service service2 = service object {
        remote function onCreate(record {} after, string tableName) returns error? {
        }
    };

    check mssqlListener.attach(service1);
    cdc:Error? result = mssqlListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "The 'cdc:ServiceConfig' annotation is mandatory when attaching multiple services to the 'cdc:Listener'.");
    check mssqlListener.detach(service1);
}

@test:Config {
    groups: ["cdc"]
}
function testStartWithServicesWithSameAnnotation() returns error? {
    CdcListener mssqlListener = getDummyMsSqlListener();

    cdc:Service service1 = @cdc:ServiceConfig {
        tables: "table1"
    } service object {
        remote function onCreate(record {} after, string tableName = "table1") returns error? {
        }
    };

    cdc:Service service2 = @cdc:ServiceConfig {
        tables: "table1"
    } service object {
        remote function onCreate(record {} after, string tableName = "table1") returns error? {
        }
    };

    check mssqlListener.attach(service1);
    error? result = mssqlListener.attach(service2);
    test:assertEquals(result is () ? "" : result.message(),
            "Multiple services cannot be used to receive events from the same table 'table1'.");
    check mssqlListener.detach(service1);
}

@test:Config {
    groups: ["cdc"]
}
function testAttachAfterStart() returns error? {
    CdcListener mssqlListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort,
            databaseNames: cdcDatabase
        },
        options: {
            snapshotMode: cdc:NO_DATA
        }
    });
    check mssqlListener.attach(testService);
    check mssqlListener.'start();
    error? result = mssqlListener.attach(testService);
    test:assertEquals(result is () ? "" : result.message(),
            "Cannot attach a CDC service to the listener once it is running.");
    check mssqlListener.immediateStop();
}

@test:Config {
    groups: ["cdc"]
}
function testDetachAfterStart() returns error? {
    CdcListener mssqlListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort,
            databaseNames: cdcDatabase
        },
        options: {
            snapshotMode: cdc:NO_DATA
        }
    });

    check mssqlListener.attach(testService);
    check mssqlListener.'start();
    error? result = mssqlListener.detach(testService);
    test:assertEquals(result is () ? "" : result.message(),
            "Cannot detach a CDC service from the listener once it is running.");
    check mssqlListener.gracefulStop();
}

cdc:Service mssqlTestService =
@cdc:ServiceConfig {tables: "store_db.products"}
service object {
    remote function onCreate(record {} after, string tableName) returns error? {
        createEventCount = createEventCount + 1;
    }

    remote function onUpdate(record {} before, record {} after, string tableName) returns error? {
        updateEventCount = updateEventCount + 1;
    }

    remote function onDelete(record {} before, string tableName) returns error? {
        deleteEventCount = deleteEventCount + 1;
    }

    remote function onRead(record {} before, string tableName) returns error? {
        readEventCount = readEventCount + 1;
    }
};

cdc:Service mssqlDataBindingFailService =
@cdc:ServiceConfig {tables: "store_db.vendors"}
service object {

    remote function onCreate(WrongVendor after) returns error? {
        createEventCount = createEventCount + 1;
    }

    remote function onError(cdc:Error e) returns error? {
        onErrorCount = onErrorCount + 1;
    }
};

type WrongVendor record {|
    int test;
|};

final Client mssqlClient = check new (
    host = "localhost",
    port = cdcPort,
    user = cdcUsername,
    password = cdcPassword,
    database = cdcDatabase
);

int createEventCount = 0;
int updateEventCount = 0;
int deleteEventCount = 0;
int readEventCount = 0;
int onErrorCount = 0;

@test:Config {
    groups: ["cdc"]
}
function testCdcListenerEvents() returns error? {
    CdcListener testListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort,
            databaseNames: cdcDatabase
            // ,
            // includedTables: ["store_db.products", "store_db.vendors"]
        }
    });

    check testListener.attach(mssqlTestService);
    check testListener.attach(mssqlDataBindingFailService);
    check testListener.start();
    runtime:sleep(sleepBetweenSteps);

    test:assertEquals(readEventCount, 2, msg = "READ event count mismatch.");

    // Test CREATE event
    _ = check mssqlClient->execute(
        `INSERT INTO products (id, name, price, description, vendor_id) 
        VALUES (1103, 'Product A', 10.0, 'testProduct', 1)`);
    runtime:sleep(sleepBetweenSteps);
    test:assertEquals(createEventCount, 1, msg = "CREATE event count mismatch.");

    // Test UPDATE event
    _ = check mssqlClient->execute(
        `UPDATE products SET price = 15.0 WHERE id = 1103`);
    runtime:sleep(sleepBetweenSteps);
    test:assertEquals(updateEventCount, 1, msg = "UPDATE event count mismatch.");

    // Test DELETE event
    _ = check mssqlClient->execute(
        `DELETE FROM products WHERE id = 1103`);
    runtime:sleep(sleepBetweenSteps);
    test:assertEquals(deleteEventCount, 1, msg = "DELETE event count mismatch.");

    // Test CREATE event for vendors table
    _ = check mssqlClient->execute(
        `INSERT INTO vendors (id, name, contact_info) 
        VALUES (201, 'Vendor A', 'contact@vendora.com')`);
    runtime:sleep(sleepBetweenSteps);
    test:assertEquals(onErrorCount, 3, msg = "Error count mismatch.");
    // 1,2 for onRead method not present, 3 for payload binding failure

    check testListener.gracefulStop();
}
