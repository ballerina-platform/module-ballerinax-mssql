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
    groups: ["query"]
}
function testSelectFromExactNumericDataTable() returns error? {
    int rowId = 1;
    
    sql:ParameterizedQuery sqlQuery = `select * from ExactNumeric where row_id = ${rowId}`;

    _ = validateComplexExactNumericTableResult(check complexQueryMssqlClient(sqlQuery, ExactNumericRecord, database = complexQueryDb));
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
    groups: ["query"],
    dependsOn: [testSelectFromExactNumericDataTable]
}
function testSelectFromExactNumericDataTable2() returns error? {
    int rowId = 2;
    
    sql:ParameterizedQuery sqlQuery = `select * from ExactNumeric where row_id = ${rowId}`;

    _ = validateExactNumericTableResult2(check complexQueryMssqlClient(sqlQuery, ExactNumericRecord2, database = complexQueryDb));
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
    groups: ["query"],
    dependsOn: [testSelectFromExactNumericDataTable2]
}
function testSelectFromStringDataTable() returns error? {
    int rowId = 1;
    
    sql:ParameterizedQuery sqlQuery = `select * from StringTypes where row_id = ${rowId}`;

    _ = validateComplexStringTableResult(check complexQueryMssqlClient(sqlQuery, CharacterRecord, database = complexQueryDb));
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
    groups: ["query"],
    dependsOn: [testSelectFromStringDataTable]
}
function testSelectFromStringDataTable2() returns error? {
    int rowId = 3;
    
    sql:ParameterizedQuery sqlQuery = `select * from StringTypes where row_id = ${rowId}`;

    _ = validateComplexStringTableResult2(check complexQueryMssqlClient(sqlQuery, CharacterRecord, database = complexQueryDb));
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

function complexQueryMssqlClient(@untainted string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? resultType = (), string database = complexQueryDb)
returns @tainted record {}? | error {
    Client dbClient = check new (host, user, password, database, port);
    stream<record {}, error> streamData = dbClient->query(sqlQuery, resultType);
    record {|record {} value;|}? data = check streamData.next();
    check streamData.close();
    record {}? value = data?.value;
    check dbClient.close();
    return value;
}
