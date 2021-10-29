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

import ballerina/sql;
import ballerina/test;

string executeDb = "EXECUTE_DB";

@test:BeforeGroups {
    value: ["execute-basic"]
}
function initExecuteBasicTests() returns error? {
    _ = check executeQueryMssqlClient(`DROP DATABASE IF EXISTS EXECUTE_DB`);
    _ = check executeQueryMssqlClient(`CREATE DATABASE EXECUTE_DB`);

    sql:ParameterizedQuery query = `
        DROP TABLE IF EXISTS ExactNumericTypes;

        CREATE TABLE ExactNumericTypes (
            id INT NOT NULL IDENTITY PRIMARY KEY,
            smallint_type SMALLINT,
            int_type INT,
            tinyint_type TINYINT,
            bigint_type BIGINT,
            decimal_type DECIMAL,
            numeric_type NUMERIC,
        );

        DROP TABLE IF EXISTS StringTypes;

        CREATE TABLE StringTypes (
            id INT PRIMARY KEY,
            varchar_type VARCHAR(255),
            char_type CHAR(4),
            text_type TEXT,
            nchar_type NCHAR(4),
            nvarchar_type NVARCHAR(10)
        );

        INSERT INTO StringTypes (id, varchar_type) VALUES (1, 'test data');

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

    `;
    _ = check executeQueryMssqlClient(query, executeDb);
}


@test:Config {
    groups: ["execute", "execute-basic"]
}
function testCreateTable() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `CREATE TABLE Student(StudentID int, LastName varchar(255))`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testCreateTable]
}
function testInsertTable() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `INSERT INTO ExactNumericTypes (int_type) VALUES (20)`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    string|int? insertId = result.lastInsertId;
    if insertId is string {
        int id = check int:fromString(insertId);
        test:assertExactEquals(id, 1);
    } else {
        test:assertFail("Insert ID is not string");
    }
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTable]
}
function testInsertTableWithoutGeneratedKeys() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `INSERT INTO StringTypes (id, varchar_type) VALUES (5, 'test data')`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    test:assertEquals(result.lastInsertId, (), "Last Insert ID is not nil.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithoutGeneratedKeys]
}
function testInsertTableWithGeneratedKeys() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `INSERT INTO ExactNumericTypes (int_type) VALUES (21)`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    string|int? insertId = result.lastInsertId;
    if insertId is string {
        int id = check int:fromString(insertId);
            test:assertTrue(id > 1, "Last Insert ID is nil.");
    } else {
        test:assertFail("Insert ID is not string");
    }
}

type ExactNumericType record {|
    int id;
    int? int_type;
    int? bigint_type;
    int? smallint_type;
    int? tinyint_type;
    decimal? decimal_type;
    decimal? numeric_type;
|};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithGeneratedKeys]
}
function testInsertAndSelectTableWithGeneratedKeys() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `INSERT INTO ExactNumericTypes (int_type) VALUES (31)`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertId = result.lastInsertId;
    if insertId is string {
        int id = check int:fromString(insertId);
        Client dbClient = check getMssqlClient(executeDb);
        ExactNumericType queryResult = check dbClient->queryRow(`SELECT * from ExactNumericTypes where id = ${id}`);

        ExactNumericType expectedRecord = {
            id: id,
            int_type: 31,
            bigint_type: (),
            smallint_type: (),
            tinyint_type: (),
            decimal_type: (),
            numeric_type: ()
        };
        test:assertEquals(queryResult, expectedRecord);
    } else {
        test:assertFail("Insert ID is not string");
    }
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertAndSelectTableWithGeneratedKeys]
}
function testInsertWithAllNilAndSelectTableWithGeneratedKeys() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `INSERT INTO ExactNumericTypes (smallint_type, int_type, bigint_type, decimal_type, numeric_type)
         VALUES (null, null, null, null, null)`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertedId = result.lastInsertId;
    if insertedId is string {
        int id = check int:fromString(insertedId);
        Client dbClient = check getMssqlClient(executeDb);
        ExactNumericType queryResult = check dbClient->queryRow(`SELECT * from ExactNumericTypes where id = ${id}`);

        ExactNumericType expectedRecord = {
            id: id,
            int_type: (),
            bigint_type: (),
            smallint_type: (),
            tinyint_type: (),
            decimal_type: (),
            numeric_type: ()
        };
        test:assertEquals(queryResult, expectedRecord);
    } else {
        test:assertFail("Insert Id is not string");
    }
}

type StringData record {|
    int id;
    string varchar_type;
    string char_type;
    string text_type;
    string nchar_type;
    string nvarchar_type;
|};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertAndSelectTableWithGeneratedKeys]
}
function testInsertWithStringAndSelectTable() returns error? {
    string intIDVal = "25";
    sql:ParameterizedQuery insertQuery = `
        INSERT INTO StringTypes (id, varchar_type, char_type, text_type, nchar_type, nvarchar_type)
        VALUES (${intIDVal}, 'str1', 'str2', 'str3', 'str4', 'str5')
    `;
    sql:ExecutionResult result = check executeQueryMssqlClient(insertQuery, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    Client dbClient = check getMssqlClient(executeDb);
    ExactNumericType queryResult = check dbClient->queryRow(`SELECT * from StringTypes where id = ${intIDVal}`);

    StringData expectedInsertRow = {
        id: 25,
        varchar_type: "str1",
        char_type: "str2",
        text_type: "str3",
        nchar_type: "str4",
        nvarchar_type: "str5"
    };
    test:assertEquals(queryResult, expectedInsertRow, "Incorrect InsetId returned.");
}

type ResultCount record {|
    int countVal;
|};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithStringAndSelectTable]
}
function testUpdateNumericData() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `UPDATE ExactNumericTypes SET int_type = 11 WHERE int_type = 20`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    Client dbClient = check getMssqlClient(executeDb);
    int countVal = check dbClient->queryRow(`SELECT COUNT(*) FROM ExactNumericTypes WHERE int_type = 11`);
    test:assertEquals(countVal, 1, "Update command was not successful.");
    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testUpdateNumericData]
}
function testUpdateStringData() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `UPDATE StringTypes SET varchar_type = 'updatedstring' WHERE varchar_type = 'str1'`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    Client dbClient = check getMssqlClient(executeDb);
    int countVal = check dbClient->queryRow(`SELECT COUNT(*) FROM StringTypes WHERE varchar_type = 'updatedstring'`);
    test:assertEquals(countVal, 1, "String table Update command was not successful.");
    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testUpdateStringData]
}
function testDeleteNumericData() returns error? {
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `INSERT INTO ExactNumericTypes (int_type) VALUES (1451)`, executeDb);
    result = check executeQueryMssqlClient(`DELETE FROM ExactNumericTypes WHERE int_type = 1451`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    Client dbClient = check getMssqlClient(executeDb);
    int countVal = check dbClient->queryRow(`SELECT COUNT(*) FROM ExactNumericTypes WHERE int_type = 1451`);
    test:assertEquals(countVal, 0, "Numeric table Delete command was not successful.");
    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testDeleteNumericData]
}
function testDeleteStringData() returns error? {
    string intId = "28";
    sql:ExecutionResult result = check executeQueryMssqlClient(
        `INSERT INTO StringTypes (id, varchar_type) VALUES (${intId}, 'deletestr')`, executeDb);
    result = check executeQueryMssqlClient(`DELETE FROM StringTypes WHERE varchar_type = 'deletestr'`, executeDb);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    Client dbClient = check getMssqlClient(executeDb);
    int countVal = check dbClient->queryRow(`SELECT COUNT(*) FROM StringTypes WHERE varchar_type = 'deletestr'`);
    test:assertEquals(countVal, 0, "String table Delete command was not successful.");
    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"]
}
function testPointTypeError() returns error? {
    int id = 11;
    PointValue pointValue = new ("Invalid Value");
    sql:ParameterizedQuery sqlQuery = `INSERT INTO GeometricTypes (row_id, point_type) VALUES (${id}, ${pointValue});`;
    sql:ExecutionResult|error result = executeQueryMssqlClient(sqlQuery, executeDb);
    test:assertTrue(result is error);
    if result is sql:Error {
        string expectedErrorMessage = "Error while executing SQL query: INSERT INTO GeometricTypes (row_id, point_type) "+
            "VALUES ( ? ,  ? );. Illegal character in Well-Known text";
        test:assertTrue(result.message().startsWith(expectedErrorMessage),
           "Error message does not match, actual :\n'" + result.message() + "'\nExpected : \n" + expectedErrorMessage);
    } else {
        test:assertFail("Error expected");
    }
}

@test:Config {
    groups: ["execute", "execute-basic"]
}
function testGeometryCollectionTypeError() returns error? {
    int id = 11;
    GeometryCollectionValue GeometryValue = new ("Invalid Value");
    sql:ParameterizedQuery sqlQuery = `INSERT INTO GeometricTypes (row_id, geometry_type) VALUES (${id}, ${GeometryValue});`;
    sql:ExecutionResult|error result = executeQueryMssqlClient(sqlQuery, executeDb);
    test:assertTrue(result is error);
    if result is sql:Error {
        string expectedErrorMessage = "Error while executing SQL query: INSERT INTO GeometricTypes (row_id, geometry_type) "+
            "VALUES ( ? ,  ? );. Illegal character in Well-Known text";
        test:assertTrue(result.message().startsWith(expectedErrorMessage), 
           "Error message does not match, actual :\n'" + result.message() + "'\nExpected : \n" + expectedErrorMessage);
    } else {
        test:assertFail("Error expected");
    }
}

@test:Config {
    groups: ["execute", "execute-basic"]
}
function testMoneyTypeError() returns error? {
    int id = 11;
    MoneyValue moneyValue = new ("Invalid Value");
    sql:ParameterizedQuery sqlQuery = `INSERT INTO MoneyTypes (row_id, money_type) VALUES (${id}, ${moneyValue});`;
    sql:ExecutionResult|error result = executeQueryMssqlClient(sqlQuery, executeDb);
    test:assertTrue(result is error);
    if result is sql:Error {
        string expectedErrorMessage = "Error while executing SQL query: INSERT INTO MoneyTypes (row_id, money_type) " +
            "VALUES ( ? ,  ? );. Cannot convert a char value to money.";
        test:assertTrue(result.message().startsWith(expectedErrorMessage), 
           "Error message does not match, actual :\n'" + result.message() + "'\nExpected : \n" + expectedErrorMessage);
    } else {
        test:assertFail("Error expected");
    }
}
