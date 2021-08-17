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

string complexQueryDb = "complex_query_db";

@test:BeforeGroups {
    value: ["query-complex"]
}
function initQueryComplexTests() returns error? {
    _ = check executeQueryMssqlClient(`DROP DATABASE IF EXISTS COMPLEX_QUERY_DB`);
    _ = check executeQueryMssqlClient(`CREATE DATABASE COMPLEX_QUERY_DB`);

    sql:ParameterizedQuery query = `

        DROP TABLE IF EXISTS ExactNumeric;

        CREATE TABLE ExactNumeric(
            row_id INT PRIMARY KEY,
            bigint_type  bigint,
            numeric_type  numeric(10,5),
            smallint_type smallint,
            decimal_type decimal(5,2),
            int_type INT,
            tinyint_type tinyint,
        );

        INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, smallint_type, decimal_type, int_type, tinyint_type)
        VALUES(1, 9223372036854775807, 12.12000, 32767, 123.41, 2147483647, 255);

        INSERT INTO ExactNumeric (row_id)
        VALUES(2);

        DROP TABLE IF EXISTS ApproximateNumeric;

        CREATE TABLE ApproximateNumeric(
            row_id INT PRIMARY KEY,
            float_type float,
            real_type real
        );

        INSERT INTO ApproximateNumeric (row_id, float_type, real_type) VALUES (1, 1.79E+308, -1.18E-38);

        DROP TABLE IF EXISTS DateandTime;

        CREATE TABLE DateandTime(
            row_id INT PRIMARY KEY,
            date_type  date,
            dateTimeOffset_type  datetimeoffset,
            dateTime2_type datetime2,
            smallDateTime_type smalldatetime,
            dateTime_type datetime,
            time_type time
        );

        INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type , dateTime_type, time_type)
        VALUES (1, '2017-06-26', '2020-01-01 19:14:51 +05:30', '1900-01-01 00:25:00.0021425', '2007-05-10 10:00:20', '2017-06-26 09:54:21.325', '09:46:22');

        DROP TABLE IF EXISTS StringTypes;

        CREATE TABLE StringTypes (
            row_id INT PRIMARY KEY,
            varchar_type VARCHAR(255),
            char_type CHAR(14),
            text_type TEXT
        );

        INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type) VALUES (1,'This is a varchar','This is a char','This is a long text');

        INSERT INTO StringTypes (row_id) VALUES (3);

        DROP TABLE IF EXISTS MoneyTypes;

        CREATE TABLE MoneyTypes (
            row_id INT PRIMARY KEY,
            money_type money,
            smallmoney_type smallmoney
        );
    `;
    _ = check executeQueryMssqlClient(query, complexQueryDb);
}

public type ExactNumericRecord record {
    int row_id;
    int smallint_type;
    int int_type;
    int tinyint_type;
    int bigint_type;
    decimal decimal_type;
    decimal numeric_type;
};

public type ExactNumericRecord2 record {
    int row_id;
    int? smallint_type;
    int? int_type;
    int? tinyint_type;
    int? bigint_type;
    decimal? decimal_type;
    decimal? numeric_type;
};

@test:Config {
    groups: ["query", "query-complex"]
}
function testSelectFromExactNumericDataTable() returns error? {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId}`;
    _ = validateComplexExactNumericTableResult(check queryMssqlClient(sqlQuery, ExactNumericRecord, complexQueryDb));
}

isolated function validateComplexExactNumericTableResult(record{}? returnData) {
    decimal decimalVal = 123.41;
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["bigint_type"], 9223372036854775807);
        test:assertTrue(returnData["numeric_type"] is decimal);
        test:assertEquals(returnData["int_type"], 2147483647);
        test:assertEquals(returnData["smallint_type"], 32767);
        test:assertEquals(returnData["decimal_type"], decimalVal);   
    } 
}

@test:Config {
    groups: ["query", "query-complex"],
    dependsOn: [testSelectFromExactNumericDataTable]
}
function testSelectFromExactNumericDataTable2() returns error? {
    int rowId = 2;
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId}`;
    _ = validateExactNumericTableResult2(check queryMssqlClient(sqlQuery, ExactNumericRecord2, complexQueryDb));
}

isolated function validateExactNumericTableResult2(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 2);
        test:assertEquals(returnData["bigint_type"], ());
        test:assertEquals(returnData["numeric_type"], ());
        test:assertEquals(returnData["int_type"], ());
        test:assertEquals(returnData["smallint_type"], ());
        test:assertEquals(returnData["decimal_type"], ());   
    } 
}

public type CharacterRecord record {
    int row_id;
    string? char_type;
    string? varchar_type;
    string? text_type;
};

@test:Config {
    groups: ["query", "query-complex"],
    dependsOn: [testSelectFromExactNumericDataTable2]
}
function testSelectFromStringDataTable() returns error? {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM StringTypes WHERE row_id = ${rowId}`;
        _ = validateComplexStringTableResult(check queryMssqlClient(sqlQuery, CharacterRecord, complexQueryDb));
}

isolated function validateComplexStringTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["char_type"], "This is a char");
        test:assertEquals(returnData["varchar_type"], "This is a varchar");
        test:assertEquals(returnData["text_type"], "This is a long text");   
    } 
}

@test:Config {
    groups: ["query", "query-complex"],
    dependsOn: [testSelectFromStringDataTable]
}
function testSelectFromStringDataTable2() returns error? {
    int rowId = 3;
        sql:ParameterizedQuery sqlQuery = `SELECT * FROM StringTypes WHERE row_id = ${rowId}`;
    _ = validateComplexStringTableResult2(check queryMssqlClient(sqlQuery, CharacterRecord, complexQueryDb));
}

isolated function validateComplexStringTableResult2(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 3);
        test:assertEquals(returnData["char_type"], ());
        test:assertEquals(returnData["varchar_type"], ());
        test:assertEquals(returnData["text_type"], ());
    } 
}
