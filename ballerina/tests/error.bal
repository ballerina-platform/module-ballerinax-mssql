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

import ballerina/lang.'string as strings;
import ballerina/test;
import ballerina/sql;

string errorDB = "ERROR_DB";

@test:BeforeGroups {
    value: ["error"]
}
function initErrorTests() returns error? {
    _ = check executeQueryMssqlClient(`DROP DATABASE IF EXISTS ERROR_DB`);
    _ = check executeQueryMssqlClient(`CREATE DATABASE ERROR_DB`);

    sql:ParameterizedQuery query = `

        DROP TABLE IF EXISTS DataTable;

        CREATE TABLE DataTable(
            row_id       INT,
            string_type  VARCHAR(50),
            PRIMARY KEY (row_id)
        );

        INSERT INTO DataTable (row_id, string_type) VALUES(1, '{""q}');
        `;

    _ = check executeQueryMssqlClient(query, errorDB);
}

@test:Config {
    groups: ["error"]
}
function TestAuthenticationError() {
    Client|error err = new (host, "user", password, errorDB, port);
    test:assertTrue(err is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>err;
    test:assertTrue(strings:includes(sqlerror.message(), "Login failed for user 'user'"));
}

@test:Config {
    groups: ["error"]
}
function TestLinkFailure() {
    Client|error err = new ("host", user, password, errorDB, port);
    test:assertTrue(err is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>err;
    test:assertTrue(strings:includes(sqlerror.message(), "The TCP/IP connection to the host host, port 1433 has " +
            "failed. Error: \"host. Verify the connection properties"));
}

@test:Config {
    groups: ["error"]
}
function TestInvalidDB() {
    Client|error err = new (host, user, password, "errorD", port);
    test:assertTrue(err is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>err;
    test:assertTrue(strings:includes(sqlerror.message(), "Cannot open database \"errorD\" requested by the login"));
}

@test:Config {
    groups: ["error"]
}
function TestConnectionClose() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    check dbClient.close();
    string|error stringVal = dbClient->queryRow(sqlQuery);
    test:assertTrue(stringVal is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>stringVal;
    test:assertEquals(sqlerror.message(), "SQL Client is already closed, hence further operations are not allowed");
}

@test:Config {
    groups: ["error"]
}
function TestInvalidTableName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from Data WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    error sqlerror = <error>stringVal;
    test:assertEquals(sqlerror.message(), "Error while executing SQL query: SELECT string_type from Data " +
                "WHERE row_id = 1. Invalid object name 'Data'..");
}

@test:Config {
    groups: ["error"]
}
function TestInvalidFieldName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>stringVal;
    test:assertEquals(sqlerror.message(), "Error while executing SQL query: SELECT string_type from DataTable " +
                "WHERE id = 1. Invalid column name 'id'..");
}

@test:Config {
    groups: ["error"]
}
function TestInvalidColumnType() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    sql:ExecutionResult|error result = dbClient->execute(
                                                    `CREATE TABLE TestCreateTable(studentID Point,LastName string)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError>result;
    test:assertEquals(sqlerror.message(), "Error while executing SQL query: CREATE TABLE TestCreateTable" +
                "(studentID Point,LastName string). Column, parameter, or variable #1: Cannot find data type Point..");
}

@test:Config {
    groups: ["error"]
}
function TestNullValue() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    _ = check dbClient->execute(`CREATE TABLE TestCreateTable(studentID int not null, LastName VARCHAR(50))`);
    sql:ParameterizedQuery insertQuery = `Insert into TestCreateTable (studentID, LastName) values (null,'asha')`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), " Cannot insert the value NULL into column 'studentID'"));
}

@test:Config {
    groups: ["error"]
}
function TestNoDataRead() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 5`;
    Client dbClient = check new (host, user, password, errorDB, port);
    record {}|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:NoRowsError);
    sql:NoRowsError sqlerror = <sql:NoRowsError>queryResult;
    test:assertEquals(sqlerror.message(), "Query did not retrieve any rows.");
}

@test:Config {
    groups: ["error"]
}
function TestUnsupportedTypeValue() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    json|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlerror = <sql:ConversionError>stringVal;
    test:assertEquals(sqlerror.message(), "Retrieved column 1 result '{\"\"q}' could not be converted to 'JSON', " +
            "expected ':' at line: 1 column: 4.");
}

@test:Config {
    groups: ["error"]
}
function TestConversionError() returns error? {
    sql:DateValue value = new ("hi");
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = ${value}`;
    Client dbClient = check new (host, user, password, errorDB, port);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError>stringVal;
    test:assertEquals(sqlError.message(), "Unsupported value: hi for Date Value");
}

@test:Config {
    groups: ["error"]
}
function TestConversionError1() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    json|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError>queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "Retrieved column 1 result '{\"\"q}' could not be converted"));
}

type data record {|
    int row_id;
    int string_type;
|};

@test:Config {
    groups: ["error"]
}
function TestTypeMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    data|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:TypeMismatchError);
    sql:TypeMismatchError sqlError = <sql:TypeMismatchError>queryResult;
    test:assertEquals(sqlError.message(), "The field 'string_type' of type int cannot be mapped to the " +
                "column 'string_type' of SQL type 'varchar'");
}

type stringValue record {|
    int row_id1;
    string string_type1;
|};

@test:Config {
    groups: ["error"]
}
function TestFieldMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (host, user, password, errorDB, port);
    stringValue|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:FieldMismatchError);
    sql:FieldMismatchError sqlError = <sql:FieldMismatchError>queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "No mapping field found for SQL table column 'string_type' " +
        "in the record type 'stringValue'"));
}

@test:Config {
    groups: ["error"]
}
function TestIntegrityConstraintViolation() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    _ = check dbClient->execute(`CREATE TABLE employees( employee_id int not null,
                                                        employee_name varchar (75) not null,supervisor_name varchar(75),
                                                        CONSTRAINT employee_pk PRIMARY KEY (employee_id))`);
    _ = check dbClient->execute(`CREATE TABLE departments( department_id int not null,employee_id int not
                                       null,CONSTRAINT fk_employee FOREIGN KEY (employee_id)
                                       REFERENCES employees (employee_id))`);
    sql:ExecutionResult|error result1 = dbClient->execute(
                                    `INSERT INTO departments(department_id, employee_id) VALUES (250, 600)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError>result1;
    test:assertTrue(strings:includes(sqlerror.message(), "The INSERT statement conflicted with the FOREIGN " + 
    "KEY constraint"));
}

@test:Config {
    groups: ["error"]
}
function testCreateProceduresWithMissingParams() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    _ = check dbClient->execute(`DROP TABLE IF EXISTS call_procedure`);
    _ = check dbClient->execute(`CREATE TABLE call_procedure(id INT , data INT)`);
    sql:ParameterizedQuery sqlQuery = `
                CREATE PROCEDURE InsertData
                    @pId int,
                    @pData int
                AS
                    SET NOCOUNT ON
                    INSERT INTO DataTable (row_id, string_type)
                    VALUES(@pId, @pData)
            `;
    _ = check dbClient->execute(sqlQuery);
    sql:ProcedureCallResult|error result = dbClient->call(`exec InsertData 1;`);
    check dbClient.close();
    sql:DatabaseError sqlError = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlError.message(), " Procedure or function 'InsertData' expects " +
                "parameter '@pData'"));
}

@test:Config {
    groups: ["error"],
    dependsOn: [testCreateProceduresWithMissingParams]
}
function testCreateProceduresWithParameterTypeMismatch() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    sql:ProcedureCallResult|error result = dbClient->call(`exec InsertData 1, 'value';`);
    check dbClient.close();
    sql:DatabaseError sqlError = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlError.message(), "Error converting data type varchar to int"));

}

@test:Config {
    groups: ["error"]
}
function TestDuplicateKey() returns error? {
    Client dbClient = check new (host, user, password, errorDB, port);
    _ = check dbClient->execute(`CREATE TABLE Details(id INT, age INT, PRIMARY KEY (id))`);
    sql:ParameterizedQuery insertQuery = `Insert into Details (id, age) values (1,10)`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), "Violation of PRIMARY KEY constraint"));
}
