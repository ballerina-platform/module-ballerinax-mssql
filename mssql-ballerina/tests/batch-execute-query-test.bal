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

import ballerina/sql;
import ballerina/test;

string batchExecuteDB = "batch_execute_db";

@test:Config {
    groups: ["batch-execute"]
}
function batchInsertIntoExactNumericTable1() returns error? {
    var data = [
        {row_id: 10, bigintValue: 9223372036854775807, numericValue: 123.34},
        {row_id: 11, bigintValue: 9223372036854775807, numericValue: 123.34},
        {row_id: 12, bigintValue: 9223372036854775807, numericValue: 123.34}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type) VALUES (${row.row_id}, ${row.bigintValue}, ${row.numericValue})`;
    validateBatchExecutionResult(check batchExecuteQueryMsSQLClient(sqlQueries), [1, 1, 1]);
}

@test:Config {
    groups: ["batch-execute"]
}
function batchInsertIntoExactNumericTable2() returns error? {
    int rowId = 15;
    int intValue = 5;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO ExactNumeric (row_id, int_type) VALUES (${rowId}, ${intValue})`;
    sql:ParameterizedQuery[] sqlQueries = [sqlQuery];
    validateBatchExecutionResult(check batchExecuteQueryMsSQLClient(sqlQueries), [1]);
}

@test:Config {
    groups: ["batch-execute"]
}
function batchInsertIntoExactNumericTableFailure() {
    var data = [
        {row_id: 20, bigintValue: 9223372036854775807, numericValue: 123.34},
        {row_id: 21, bigintValue: 9223372036854775807, numericValue: 123.34},
        {row_id: 22, bigintValue: 9223372036854775807, numericValue: 123.34},
        {row_id: 22, bigintValue: 9223372036854775807, numericValue: 123.34}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type) VALUES (${row.row_id}, ${row.bigintValue}, ${row.numericValue})`;

    sql:ExecutionResult[]|error result = trap batchExecuteQueryMsSQLClient(sqlQueries);
    test:assertTrue(result is error);
    if (result is sql:BatchExecuteError) {
        sql:BatchExecuteErrorDetail errorDetails = result.detail();
        test:assertEquals(errorDetails.executionResults.length(), 4);
        test:assertEquals(errorDetails.executionResults[0].affectedRowCount, 1);
        test:assertEquals(errorDetails.executionResults[1].affectedRowCount, 1);
        test:assertEquals(errorDetails.executionResults[2].affectedRowCount, 1);
        test:assertEquals(errorDetails.executionResults[3].affectedRowCount, -3);
    } else {
        test:assertFail("Database Error expected.");
    }
}

@test:Config {
    groups: ["batch-execute"]
}
function batchInsertIntoStringTypesTable() returns error? {
    var data = [
        {row_id: 14, charValue: "char2", varcharValue: "This is varchar2"},
        {row_id: 15, charValue: "char3", varcharValue: "This is varchar3"},
        {row_id: 16, charValue: "char4", varcharValue: "This is varchar4"}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `INSERT INTO StringTypes (row_id, char_type, varchar_type) VALUES (${row.row_id}, ${row.charValue}, ${row.varcharValue})`;
    validateBatchExecutionResult(check batchExecuteQueryMsSQLClient(sqlQueries), [1, 1, 1]);
}

@test:Config {
    groups: ["batch-execute"]
}
function batchUpdateStringTypesTable() returns error? {
    var data = [
        {row_id: 14, varcharValue: "Updated varchar2"},
        {row_id: 15, varcharValue: "Updated varchar3"},
        {row_id: 16, varcharValue: "Updated varchar4"}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `UPDATE StringTypes SET varchar_type = ${row.varcharValue}
               WHERE row_id = ${row.row_id}`;
       validateBatchExecutionResult(check batchExecuteQueryMsSQLClient(sqlQueries), [1, 1, 1]);
}

@test:Config {
    groups: ["batch-execute"]
}
function testBatchExecuteWithEmptyQueryList() returns error? {
    Client dbClient = check new (host, user, password, batchExecuteDB, port);
    sql:ExecutionResult[] | sql:Error result = dbClient->batchExecute([]);
    if (result is sql:Error) {
        string expectedErrorMessage = " Parameter 'sqlQueries' cannot be empty array";
        test:assertTrue(result.message().startsWith(expectedErrorMessage),
            "Error message does not match. \nActual: " + result.message() + "\nExpected: " + expectedErrorMessage);
    } else {
        test:assertFail("Error expected");
    }
}

function batchExecuteQueryMsSQLClient(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[] | error {
    Client dbClient = check new (host, user, password, batchExecuteDB, port);
    sql:ExecutionResult[] result = check dbClient->batchExecute(sqlQueries);
    check dbClient.close();
    return result;
}

isolated function validateBatchExecutionResult(sql:ExecutionResult[] results, int[] rowCount) {
    test:assertEquals(results.length(), rowCount.length());

    int i = 0;
    while (i < results.length()) {
        test:assertEquals(results[i].affectedRowCount, rowCount[i]);
        i = i + 1;
    }
}

