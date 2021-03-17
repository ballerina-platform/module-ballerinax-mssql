// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

string executeParamsDb = "EXECUTE_PARAMS_DB";

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoExactNumericTable1() {
    int rowId = 6;
    int big_int = 9223372036854775807;
    decimal numeric = 12.12000;
    int bit = 1;
    float small_int = 32767;
    float decimalc = 123.00;
    float small_money = 214748.3647;
    decimal intc = 2147483647;
    int tiny_int = 255;
    float money = 922337203685477.2807;

    sql:ParameterizedQuery sqlQuery = `INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, 
             smallint_type, decimal_type, smallmoney_type, int_type,tinyint_type, money_type) VALUES (${rowId},${
    big_int}, ${numeric},
             ${bit}, ${small_int}, ${decimalc}, ${small_money},${intc},${tiny_int},${money})`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoExactNumericTable1]
}
function insertIntoExactNumericTable2() {
    int rowId = 5;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO ExactNumeric (row_id) VALUES(${rowId})`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoExactNumericTable3() {
    sql:IntegerValue rowId = new (7);
    sql:IntegerValue big_int = new (9223372036854775807);
    sql:DecimalValue numeric = new (12.12000);
    sql:IntegerValue bit = new (1);
    sql:FloatValue small_int = new (32767);
    sql:DecimalValue decimalc = new (123.00);
    sql:FloatValue small_money = new (214748.3647);
    sql:IntegerValue intc = new (2147483647);
    sql:IntegerValue tiny_int = new (255);
    sql:FloatValue money = new (922337203685477.2807);

    sql:ParameterizedQuery sqlQuery = `INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, 
             smallint_type, decimal_type, smallmoney_type, int_type,tinyint_type, money_type) VALUES (${rowId},${
    big_int}, ${numeric},
             ${bit}, ${small_int}, ${decimalc}, ${small_money},${intc},${tiny_int},${money})`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoExactNumericTable3]
}
function deleteExactNumeric1() {
    int rowId = 1;
    int big_int = 9223372036854775807;
    decimal numeric = 12.12000;
    int bit = 1;
    float small_int = 32767;
    float decimalc = 123.00;
    float small_money = 214748.3647;

    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM ExactNumeric where row_id=${rowId} AND bigint_type=${big_int} AND numeric_type=${numeric}
              AND bit_type=${bit} AND smallint_type=${small_int} AND decimal_type=${decimalc} AND smallmoney_type=${small_money}`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoExactNumericTable3]
}
function insertIntoStringTypeTable1() {
    int rowId = 2;
    string varchar_type = "This is a varchar";
    string char_type = "test";
    string text_type = "This is a text";
    string nchar_type = "test" ;
    string nvarchar_type = "nvarchar";

    sql:ParameterizedQuery sqlQuery = `
            Insert into StringTypes (raw_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type) 
            values (${rowId},${varchar_type},${char_type},${text_type},${nchar_type},${nvarchar_type})`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoStringTypeTable1]
}
function insertIntoStringTypeTable2() {
    sql:IntegerValue rowId = new (3);
    sql:VarcharValue varchar_type = new ("This is a varchar");
    sql:CharValue char_type = new ("test");
    sql:TextValue text_type = new ("This is a text");
    sql:CharValue nchar_type = new ("test");
    sql:VarcharValue nvarchar_type = new ("nvarchar");

    sql:ParameterizedQuery sqlQuery = `
            Insert into StringTypes (raw_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type) 
            values (${rowId},${varchar_type},${char_type},${text_type},${nchar_type},${nvarchar_type})`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoStringTypeTable2]
}
function insertIntoDateTimeTable1() {
    int rowId = 2;
    string date = "2017-06-26";
    string date_time_offset = "2020-01-01 19:14:51";
    string date_time2 = "1900-01-01 00:25:00.0021425";
    string small_date_time = "2007-05-10 10:00:20";
    string date_time = "2017-06-26 09:54:21.325";
    string time = "09:46:22";

    sql:ParameterizedQuery sqlQuery = `INSERT INTO DateandTime (row_id,Date_col,DateTimeOffset_col,DateTime2_col,SmallDateTime_col,DateTime_col,Time_col) VALUES
             (${rowId},${
    date},${date_time_offset},${date_time2},${small_date_time},${date_time},${time}
            )`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable1]
}
function insertIntoDateTimeTable2() {
    sql:IntegerValue rowId = new (3);
    sql:DateValue date = new ("2017-06-26");
    sql:TimestampValue date_time_offset = new ("2020-01-01 19:14:51");
    sql:TimestampValue date_time2 = new ("1900-01-01 00:25:00.0021425");
    sql:TimestampValue small_date_time = new ("2007-05-10 10:00:20");
    sql:TimestampValue date_time = new ("2017-06-26 09:54:21.325");
    sql:TimeValue time = new ("09:46:22");

    sql:ParameterizedQuery sqlQuery = `INSERT INTO DateandTime (row_id,Date_col,DateTimeOffset_col,DateTime2_col,SmallDateTime_col,DateTime_col,Time_col) VALUES
             (${rowId},${
    date},${date_time_offset},${date_time2},${small_date_time},${date_time},${time}
            )`;
    validateResult(executeQueryMssqlClient(sqlQuery), 1);
}

function executeQueryMssqlClient(sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult {
    Client dbClient = checkpanic new (host, user, password, executeParamsDb, port);
    sql:ExecutionResult result = checkpanic dbClient->execute(sqlQuery);
    checkpanic dbClient.close();
    return result;
}

isolated function validateResult(sql:ExecutionResult result, int rowCount, int? lastId = ()) {
    test:assertExactEquals(result.affectedRowCount, rowCount, "Affected row count is different.");

    if (lastId is ()) {
        test:assertEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    } else {
        var insertId = result.lastInsertId;
        if (insertId is string) {
            int|error id = int:fromString(insertId);
            if (id is int) {
                test:assertTrue(id > 1, "Last Insert Id is nil.");
            } else {
                test:assertFail("Insert Id should be an integer.");
            }
        }
    }

}
