// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
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

@test:Config {
    groups: ["liveness"]
}
function testLivenessBeforeListenerStart() returns error? {
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
    boolean liveness = check cdc:isLive(mssqlListener);
    test:assertFalse(liveness, "Liveness check passes even before listener starts");
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessWithStartedListener() returns error? {
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
    boolean liveness = check cdc:isLive(mssqlListener);
    test:assertTrue(liveness, "Liveness fails for a started listener");
    check mssqlListener.gracefulStop();
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessAfterListenerStop() returns error? {
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
    check mssqlListener.gracefulStop();
    boolean liveness = check cdc:isLive(mssqlListener);
    test:assertFalse(liveness, "Liveness check passes after the listener has stopped");
}

@test:Config {
    groups: ["liveness"]
}
function testLivenessWithoutReceivingEvents() returns error? {
    CdcListener mssqlListener = new ({
        database: {
            username: cdcUsername,
            password: cdcPassword,
            port: cdcPort,
            databaseNames: cdcDatabase
        },
        options: {
            snapshotMode: cdc:NO_DATA
        },
        livenessInterval: 5.0
    });
    check mssqlListener.attach(testService);
    check mssqlListener.'start();
    runtime:sleep(10);
    boolean liveness = check cdc:isLive(mssqlListener);
    test:assertFalse(liveness, "Liveness check passes even after not receiving events within the liveness interval");
    check mssqlListener.gracefulStop();
}
