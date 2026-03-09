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

@test:BeforeGroups {
    value: ["batch-execute"]
}
function initBatchExecuteTests() returns error? {
    _ = check executeQueryMssqlClient(`DROP DATABASE IF EXISTS BATCH_EXECUTE_DB`);
    _ = check executeQueryMssqlClient(`CREATE DATABASE BATCH_EXECUTE_DB`);

    sql:ParameterizedQuery query = `

        DROP TABLE IF EXISTS ExactNumeric;

        CREATE TABLE ExactNumeric(
            row_id INT PRIMARY KEY,
            bigint_type bigint,
            numeric_type numeric(10, 5),
            bit_type bit,
            smallint_type smallint,
            decimal_type decimal(5, 2),
            smallmoney_type smallmoney,
            int_type int,
            tinyint_type tinyint,
            money_type money
        );

        INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, smallint_type, decimal_type, smallmoney_type, int_type, tinyint_type, money_type)
        VALUES(1, 9223372036854775807, 12.12000, 1, 32767, 123.00, 214748.3647, 2147483647, 255, 922337203685477.2807);

        DROP TABLE IF EXISTS StringTypes;

        CREATE TABLE StringTypes (
            row_id INT PRIMARY KEY,
            varchar_type VARCHAR(255),
            char_type CHAR(5),
            text_type TEXT,
            nchar_type NCHAR(4),
            nvarchar_type NVARCHAR(10)
        );

        DROP TABLE IF EXISTS GeometricTypes;

        CREATE TABLE GeometricTypes (
            row_id INT PRIMARY KEY,
            point_type geometry,
            lineString_type geometry,
            geometry_type geometry,
            circularstring_type geometry,
            compoundcurve_type geometry,
            polygon_type geometry,
            curvepolygon_type geometry,
            multipolygon_type geometry,
            multilinestring_type geometry,
            multipoint_type geometry
        );

        DROP TABLE IF EXISTS MoneyTypes;

        CREATE TABLE MoneyTypes (
            row_id INT PRIMARY KEY,
            money_type money,
            smallmoney_type smallmoney
        );

        DROP TABLE IF EXISTS NullableNumericTypes;

        CREATE TABLE NullableNumericTypes (
            row_id     INT PRIMARY KEY,
            decimal_val DECIMAL(28, 10),
            numeric_val NUMERIC(28, 10),
            varchar_val VARCHAR(100)
        );
    `;
    _ =  check executeQueryMssqlClient(query, batchExecuteDB);
}

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
    validateBatchExecutionResult(check batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB), [1, 1, 1]);
}

@test:Config {
    groups: ["batch-execute"]
}
function batchInsertIntoExactNumericTable2() returns error? {
    int rowId = 15;
    int intValue = 5;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO ExactNumeric (row_id, int_type) VALUES (${rowId}, ${intValue})`;
    sql:ParameterizedQuery[] sqlQueries = [sqlQuery];
    validateBatchExecutionResult(check batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB), [1]);
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

    sql:ExecutionResult[]|error result = trap batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB);
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
    validateBatchExecutionResult(check batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB), [1, 1, 1]);
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
    validateBatchExecutionResult(check batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB), [1, 1, 1]);
}

@test:Config {
    groups: ["batch-execute"]
}
function testBatchExecuteWithEmptyQueryList() returns error? {
    Client dbClient = check new (host, user, password, batchExecuteDB, port);
    sql:ExecutionResult[]|sql:Error result = dbClient->batchExecute([]);
    if (result is sql:Error) {
        string expectedErrorMessage = " Parameter 'sqlQueries' cannot be empty array";
        test:assertTrue(result.message().startsWith(expectedErrorMessage),
            "Error message does not match. \nActual: " + result.message() + "\nExpected: " + expectedErrorMessage);
    } else {
        test:assertFail("Error expected");
    }
}

isolated function validateBatchExecutionResult(sql:ExecutionResult[] results, int[] rowCount) {
    test:assertEquals(results.length(), rowCount.length());
    int i = 0;
    while i < results.length() {
        test:assertEquals(results[i].affectedRowCount, rowCount[i]);
        i = i + 1;
    }
}

// Tests for batch execute with nullable parameters (fix: Types.NULL → Types.VARCHAR)
// and decimal scale variance (fix: setObject with normalised scale).

// Verify that rows with null decimal/numeric/varchar fields batch-insert without error.
// Before the fix, passing bare Ballerina () mapped to Types.NULL which the MSSQL JDBC
// driver could not encode in preparedTypeDefinitions, forcing sp_prepexec per row.
@test:Config {
    groups: ["batch-execute"]
}
function batchInsertWithNullDecimalFields() returns error? {
    var data = [
        {rowId: 100, decimalVal: <decimal?>12.34, numericVal: <decimal?>56.78, varcharVal: <string?>"hello"},
        {rowId: 101, decimalVal: <decimal?>(), numericVal: <decimal?>(), varcharVal: <string?>()},
        {rowId: 102, decimalVal: <decimal?>99.99, numericVal: <decimal?>(), varcharVal: <string?>"world"},
        {rowId: 103, decimalVal: <decimal?>(), numericVal: <decimal?>11.22, varcharVal: <string?>()}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        let sql:DecimalValue dv = new (row.decimalVal),
            sql:NumericValue nv = new (row.numericVal),
            sql:VarcharValue vv = new (row.varcharVal)
        select `INSERT INTO NullableNumericTypes (row_id, decimal_val, numeric_val, varchar_val)
                VALUES (${row.rowId}, ${dv}, ${nv}, ${vv})`;
    validateBatchExecutionResult(check batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB), [1, 1, 1, 1]);

    // Verify null rows were stored correctly
    record {}? row101 = check queryMssqlClient(
        `SELECT decimal_val, numeric_val, varchar_val FROM NullableNumericTypes WHERE row_id = 101`,
        database = batchExecuteDB);
    test:assertNotEquals(row101, ());
    test:assertEquals((<record {}>row101)["decimal_val"], ());
    test:assertEquals((<record {}>row101)["numeric_val"], ());
    test:assertEquals((<record {}>row101)["varchar_val"], ());
}

// Verify that batch-inserting sql:NumericValue/DecimalValue with different natural scales
// across rows succeeds and stores the correct values.
// Before the fix, BigDecimal.scale() varied per row (e.g., scale=2 for "10.50", scale=4
// for "1234.5678"), generating a different preparedTypeDefinitions cache key per row and
// forcing sp_prepexec instead of sp_execute.
@test:Config {
    groups: ["batch-execute"]
}
function batchInsertWithVaryingDecimalScales() returns error? {
    decimal v1 = 1.5;       // natural scale = 1
    decimal v2 = 12.34;     // natural scale = 2
    decimal v3 = 123.456;   // natural scale = 3
    decimal v4 = 1234.5678; // natural scale = 4
    var data = [
        {rowId: 110, val: v1},
        {rowId: 111, val: v2},
        {rowId: 112, val: v3},
        {rowId: 113, val: v4}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        let sql:NumericValue nv = new (row.val)
        select `INSERT INTO NullableNumericTypes (row_id, numeric_val) VALUES (${row.rowId}, ${nv})`;
    validateBatchExecutionResult(check batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB), [1, 1, 1, 1]);

    // Verify values are stored with correct precision
    record {}? row110 = check queryMssqlClient(
        `SELECT numeric_val FROM NullableNumericTypes WHERE row_id = 110`, database = batchExecuteDB);
    test:assertEquals((<record {}>row110)["numeric_val"], <decimal>1.5);

    record {}? row113 = check queryMssqlClient(
        `SELECT numeric_val FROM NullableNumericTypes WHERE row_id = 113`, database = batchExecuteDB);
    test:assertEquals((<record {}>row113)["numeric_val"], <decimal>1234.5678);
}

// Verify that a batch mixing null rows and rows with varying decimal scales all insert
// correctly — exercises both fixes together.
@test:Config {
    groups: ["batch-execute"]
}
function batchInsertWithNullAndVaryingScalesMixed() returns error? {
    var data = [
        {rowId: 120, val: <decimal?>10.5},
        {rowId: 121, val: <decimal?>()},
        {rowId: 122, val: <decimal?>999.9999},
        {rowId: 123, val: <decimal?>()},
        {rowId: 124, val: <decimal?>0.001}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        let sql:DecimalValue dv = new (row.val)
        select `INSERT INTO NullableNumericTypes (row_id, decimal_val) VALUES (${row.rowId}, ${dv})`;
    validateBatchExecutionResult(check batchExecuteQueryMssqlClient(sqlQueries, batchExecuteDB), [1, 1, 1, 1, 1]);

    record {}? row121 = check queryMssqlClient(
        `SELECT decimal_val FROM NullableNumericTypes WHERE row_id = 121`, database = batchExecuteDB);
    test:assertEquals((<record {}>row121)["decimal_val"], ());

    record {}? row122 = check queryMssqlClient(
        `SELECT decimal_val FROM NullableNumericTypes WHERE row_id = 122`, database = batchExecuteDB);
    test:assertEquals((<record {}>row122)["decimal_val"], <decimal>999.9999);
}
