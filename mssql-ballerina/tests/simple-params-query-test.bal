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

string simpleParamsDb = "simple_params_query_db";

@test:Config {
    groups: ["query","query-simple-params"]
}
function querySingleIntParam() {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE row_id = ${rowId}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleIntParam() {
    int rowId = 1;
    int intType = 2147483647;
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE row_id = ${rowId} AND int_type =  ${intType}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntAndBigintParam() {
    int rowId = 1;
    int bigInt = 9223372036854775807;
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE row_id = ${rowId} AND bigint_type = ${bigInt}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryStringParam() {
    string varcharType = "str1";
    sql:ParameterizedQuery sqlQuery = `SELECT * from StringTypes WHERE varchar_type = ${varcharType}`;
    validateStringTypeTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntAndStringParam() {
    string charType = "str2";
    int rowId =1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from StringTypes WHERE char_type = ${charType} AND row_id = ${rowId}`;
    validateStringTypeTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryFloatAndRealParam() {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from ApproximateNumeric WHERE row_id = ${rowId}`;
    validateApproximateNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeCharStringParam() {
    sql:CharValue charVal = new ("str2");
    sql:ParameterizedQuery sqlQuery = `SELECT * from StringTypes WHERE char_type = ${charVal}`;
    validateStringTypeTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTinyIntParam() {
    sql:IntegerValue typeVal = new (255);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE tinyint_type = ${typeVal}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitStringParam() {
    sql:BitValue typeVal = new (true);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE bit_type = ${typeVal}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitInvalidIntParam() {
    sql:BitValue typeVal = new (12);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE bit_type = ${typeVal}`;
    record{}|error? returnVal = trap simpleQueryMssqlClient(sqlQuery);
    test:assertTrue(returnVal is error);
    error dbError = <error> returnVal;
    test:assertEquals(dbError.message(), "Only 1 or 0 can be passed for BitValue SQL Type, but found :12");
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericParam() {
    sql:NumericValue typeVal = new (12.12000);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE numeric_type = ${typeVal}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericDecimalParam() {
    decimal decimalVal = 12.12000;
    sql:NumericValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE numeric_type = ${typeVal}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDecimalParam() {
    sql:DecimalValue typeVal = new (123.41);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ExactNumeric WHERE decimal_type = ${typeVal}`;
    validateExactNumericTableResult(simpleQueryMssqlClient(sqlQuery));
}

function simpleQueryMssqlClient(@untainted string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? resultType = (), string database = simpleParamsDb)
returns @tainted record {}? {
    Client dbClient = checkpanic new (host, user, password, database, port);
    stream<record {}, error> streamData = dbClient->query(sqlQuery, resultType);
    record {|record {} value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    record {}? value = data?.value;
    checkpanic dbClient.close();
    return value;
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
        test:assertEquals(returnData["varchar_type"], "str1");
        test:assertEquals(returnData["text_type"], "assume a long text");
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
