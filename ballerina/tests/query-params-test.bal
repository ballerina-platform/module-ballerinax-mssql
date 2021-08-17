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
import ballerina/time;

string simpleParamsDb = "simple_params_query_db";

@test:BeforeGroups {
    value: ["query-simple-params"]
}
function initQueryParamsTests() returns error? {
    _ = check executeQueryMssqlClient(`DROP DATABASE IF EXISTS SIMPLE_PARAMS_QUERY_DB`);
    _ = check executeQueryMssqlClient(`CREATE DATABASE SIMPLE_PARAMS_QUERY_DB`);

    sql:ParameterizedQuery query = `

        DROP TABLE IF EXISTS ExactNumeric;

        CREATE TABLE ExactNumeric(
            row_id INT PRIMARY KEY,
            bigint_type  bigint,
            numeric_type  numeric(10,5),
            bit_type  bit,
            smallint_type smallint,
            decimal_type decimal(5,2),
            smallmoney_type smallmoney,
            int_type INT,
            tinyint_type tinyint,
            money_type money
        );


        INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, smallint_type, decimal_type, smallmoney_type, int_type, tinyint_type, money_type)
        VALUES(1, 9223372036854775807, 12.12000, 1, 32767, 123.41, 214748.3647, 2147483647, 255, 922337203685477.2807);

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
            text_type TEXT,
            nchar_type NCHAR(4),
            nvarchar_type NVARCHAR(10)
        );

        INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type) VALUES (1,'This is a varchar','This is a char','This is a long text','str4','str5');

        DROP TABLE IF EXISTS GeometricTypes;

        CREATE TABLE GeometricTypes (
            row_id INT PRIMARY KEY,
            point_type geometry,
            pointCol AS point_type.STAsText(),
            lineString_type geometry,
            lineCol AS lineString_type.STAsText(),
        );

        INSERT INTO GeometricTypes (row_id, point_type) VALUES (1,'POINT (4 6)');
    `;
    _ = check executeQueryMssqlClient(query, simpleParamsDb);
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function querySingleIntParam() returns error? {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId}`;
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleIntParam() returns error? {
    int rowId = 1;
    int intValue1 = 2147483647;
    sql:IntegerValue intValue2 = new(2147483647);
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND int_type =  ${intValue1}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND int_type =  ${intValue2}`;
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryBigintParam() returns error? {
    int rowId = 1;
    int bigInt1 = 9223372036854775807;
    sql:BigIntValue bigInt2 = new(9223372036854775807);
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND bigint_type = ${bigInt1}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND bigint_type = ${bigInt2}`;
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function querySmallintParam() returns error? {
    int rowId = 1;
    int smallInt1 = 32767;
    sql:SmallIntValue smallInt2 = new(32767);
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND smallint_type = ${smallInt1}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND smallint_type = ${smallInt2}`;

    validateExactNumericTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTinyintParam() returns error? {
    int rowId = 1;
    int tinyInt = 255;
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND tinyint_type = ${tinyInt}`;
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryNumericParam() returns error? {
    int rowId = 1;
    decimal numericVal1 = 12.12000;
    sql:NumericValue numericVal2 = new(12.12000);
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND numeric_type = ${numericVal1}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND numeric_type = ${numericVal2}`;
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDecimalParam() returns error? {
    int rowId = 1;
    decimal decimalVal1 = 123.41;
    sql:DecimalValue decimalVal2 = new(123.41);
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND decimal_type = ${decimalVal1}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM ExactNumeric WHERE row_id = ${rowId} AND decimal_type = ${decimalVal2}`;
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryVarcharParam() returns error? {
    string varcharValue1 = "This is a varchar";
    sql:VarcharValue varcharValue2 = new("This is a varchar");
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM StringTypes WHERE varchar_type = ${varcharValue1}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM StringTypes WHERE varchar_type = ${varcharValue2}`;
    validateStringTypeTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateStringTypeTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryCharParam() returns error? {
    string charValue1 = "This is a char";
    sql:CharValue charValue2 = new("This is a char");
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM StringTypes WHERE char_type = ${charValue1}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM StringTypes WHERE char_type = ${charValue2}`;
    validateStringTypeTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateStringTypeTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntAndStringParam() returns error? {
    string charVal = "This is a char";
    int rowId =1;
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM StringTypes WHERE char_type = ${charVal} AND row_id = ${rowId}`;
    validateStringTypeTableResult(check queryMssqlClient(sqlQuery, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryFloatParam() returns error? {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM ApproximateNumeric WHERE row_id = ${rowId}`;
    validateApproximateNumericTableResult(check queryMssqlClient(sqlQuery, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryBitStringParam() returns error? {
    sql:BitValue typeVal = new(true);
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM ExactNumeric WHERE bit_type = ${typeVal}`;
    validateExactNumericTableResult(check queryMssqlClient(sqlQuery, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryBitInvalidIntParam() returns error? {
    sql:BitValue typeVal = new (12);
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM ExactNumeric WHERE bit_type = ${typeVal}`;
    record{}|error? returnVal = trap queryMssqlClient(sqlQuery, database = simpleParamsDb);
    test:assertTrue(returnVal is error);
    error dbError = <error> returnVal;
    test:assertEquals(dbError.message(), "Only 1 or 0 can be passed for BitValue SQL Type, but found :12");
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateValueParam() returns error? {
    int rowId = 1;
    time:Date dateValue = {year: 2017, month: 6, day: 26};
    sql:DateValue dateValue1 = new (dateValue);
    sql:DateValue dateValue2 = new ("2017-06-26");
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM DateandTime WHERE date_type = ${dateValue1} AND row_id = ${rowId}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM DateandTime WHERE date_type = ${dateValue2} AND row_id = ${rowId}`;
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateTimeOffsetValueParam() returns error? {
    int rowId = 1;
    time:Civil dateTimeOffsetValue = {year: 2020, month:1, day: 1, hour: 19, minute: 14, second:51, "utcOffset": {hours: 5, minutes: 30}};
    sql:DateTimeValue dateTimeOffsetValue1 = new(dateTimeOffsetValue);
    sql:DateTimeValue dateTimeOffsetValue2 = new("2020-01-01 19:14:51.0000000 +05:30");
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM DateandTime WHERE dateTimeOffset_type = ${dateTimeOffsetValue1} AND row_id = ${rowId}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM DateandTime WHERE dateTimeOffset_type = ${dateTimeOffsetValue2} AND row_id = ${rowId}`;
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateTime2ValueParam() returns error? {
    int rowId = 1;
    time:Civil dateTimeValue = {year: 1900, month:1, day: 1, hour: 0, minute: 25, second:0.0021425};
    sql:DateTimeValue dateTimeValue1 = new (dateTimeValue);
    sql:DateTimeValue dateTimeValue2 = new ("1900-01-01 00:25:00.0021425");
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM DateandTime WHERE dateTime2_type = ${dateTimeValue1} AND row_id = ${rowId}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM DateandTime WHERE dateTime2_type = ${dateTimeValue2} AND row_id = ${rowId}`;
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function querySmallDateTimeValueParam() returns error? {
    int rowId = 1;
    time:Civil smallDateTimeValue = {year: 2007, month: 5, day: 10, hour: 10, minute: 0, second:0.0};
    sql:DateTimeValue smallDateTimeValue1 = new (smallDateTimeValue);
    sql:DateTimeValue smallDateTimeValue2 = new ("2007-05-10 10:00:00.0");
    sql:ParameterizedQuery sqlQuery1 = `SELECT * FROM DateandTime WHERE smallDateTime_type = ${smallDateTimeValue1} AND row_id = ${rowId}`;
    sql:ParameterizedQuery sqlQuery2 = `SELECT * FROM DateandTime WHERE smallDateTime_type = ${smallDateTimeValue2} AND row_id = ${rowId}`;
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery1, database = simpleParamsDb));
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery2, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimeValueParam() returns error? {
    int rowId = 1;
    sql:TimeValue timeValue2 = new ("09:46:22");
    sql:ParameterizedQuery sqlQuery = `SELECT * FROM DateandTime WHERE time_type = ${timeValue2} AND row_id = ${rowId}`;
    validateDateTimeTableResult(check queryMssqlClient(sqlQuery, database = simpleParamsDb));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryRecord() returns sql:Error? {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE row_id = ${rowId}`;
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    record {} queryResult = check dbClient->queryRow(sqlQuery);
    check dbClient.close();
    validateExactNumericTableResult(queryResult);
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryRecordNegative() returns sql:Error? {
    int rowId = 999;
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE row_id = ${rowId}`;
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    record {}|sql:Error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is sql:Error {
        test:assertTrue(queryResult is sql:NoRowsError);
        test:assertTrue(queryResult.message().endsWith("Query did not retrieve any rows."), "Incorrect error message");
   } else {
       test:assertFail("Expected no rows error with empty query result.");
   }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryRecordNegative2() returns error? {
    int rowId = 1;
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE row_id = ${rowId}`;
    record{}|int|error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is error {
        test:assertEquals(queryResult.message(), "Return type cannot be a union.");
    } else {
        test:assertFail("Expected error when querying with union return type.");
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryRecordNegative3() returns error? {
    int rowId = 1;
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    sql:ParameterizedQuery sqlQuery = `SELECT row_id, invalid_column_name from ExactNumeric WHERE row_id = ${rowId}`;
    record{}|error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is error {
        test:assertTrue(queryResult.message().endsWith("Invalid column name 'invalid_column_name'.."),
                        "Incorrect error message");
    } else {
        test:assertFail("Expected error when querying with invalid column name.");
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryValue() returns error? {
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    string sqlQuery = "SELECT COUNT(*) FROM ExactNumeric";
    int count = check dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertEquals(count, 1);
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryValueNegative1() returns error? {
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE row_id = ${rowId}`;
    int|error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is error {
        test:assertTrue(queryResult is sql:TypeMismatchError, "Incorrect error type");
        test:assertEquals(queryResult.message(), "Expected type to be 'int' but found 'record{}'");
    } else {
        test:assertFail("Expected error when query result contains multiple columns.");
    }
}

@test:Config {
    groups: ["query", "query-simple-params"]
}
function queryValueNegative2() returns error? {
    Client dbClient = check new (host, user, password, simpleParamsDb, port);
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT varchar_type from StringTypes WHERE row_id = ${rowId}`;
    int|error queryResult = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    if queryResult is error {
        test:assertTrue(queryResult.message().endsWith("Retrieved SQL type field cannot be converted to ballerina type : int"),
                                                       "Incorrect error message");
    } else {
        test:assertFail("Expected error when query returns unexpected result type.");
    }
}

isolated function validateExactNumericTableResult(record{}? returnData) {
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

isolated function validateStringTypeTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["varchar_type"], "This is a varchar");
        test:assertEquals(returnData["text_type"], "This is a long text");
        test:assertTrue(returnData["nchar_type"] is string);  
    }
}

isolated function validateApproximateNumericTableResult(record{}? returnData) {
    float floatVal = 1.79E+308;
    float realVal = -1.179999945774631E-38;
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["real_type"], realVal);
        test:assertEquals(returnData["float_type"], floatVal);
    }
}

isolated function validateDateTimeTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["row_id"], 1);
        test:assertEquals(returnData["date_type"], "2017-06-26");
        test:assertEquals(returnData["dateTimeOffset_type"], "2020-01-01 19:14:51.0000000 +05:30");
        test:assertEquals(returnData["dateTime2_type"], "1900-01-01 00:25:00.0021425");
        test:assertEquals(returnData["smallDateTime_type"], "2007-05-10 10:00:00.0");
        test:assertEquals(returnData["dateTime_type"], "2017-06-26 09:54:21.327");  
        test:assertEquals(returnData["time_type"], "09:46:22");    
    } 
}
