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

string proceduresDb = "complex_query_db";

public type StringProcedureRecord record {
    int row_id;
    string char_type;
    string varchar_type;
    string text_type;
};

@test:Config {
    groups: ["procedures"]
}
function testStringProcedureCall() returns error? {
    int rowId = 35;
    sql:CharValue charValue = new("This is a char");
    sql:VarcharValue varcharValue = new("This is a varchar3");
    string textValue = "This is a text3";

    sql:ParameterizedCallQuery sqlQuery = `exec StringProcedure ${rowId}, ${charValue}, ${varcharValue}, ${textValue};`;
    sql:ProcedureCallResult result = check callProcedure(sqlQuery, proceduresDb, [StringProcedureRecord]);

    sql:ParameterizedQuery query = `SELECT row_id, char_type, varchar_type, text_type FROM StringTypes WHERE row_id = ${rowId}`;

    StringProcedureRecord expectedDataRow = {
        row_id: rowId,
        char_type: "This is a char",
        varchar_type: "This is a varchar3",
        text_type: "This is a text3"
    };
    test:assertEquals(check queryProcedureClient(query, proceduresDb, StringProcedureRecord), expectedDataRow, 
        "Character Call procedure insert and query did not match.");
}

public type ExactNumericProcedureRecord record {
    int row_id;
    int smallint_type;
    int int_type;
    int bigint_type;
    decimal decimal_type;
    decimal numeric_type;
    int tinyint_type;
};

@test:Config {
    groups: ["procedures"],
    dependsOn: [testStringProcedureCall]
}
function testExactNumericProcedureCall() returns error? {
    int rowId = 35;
    sql:SmallIntValue smallintType = new (1);
    sql:IntegerValue intType = new (1);
    int bigintType = 123456;
    sql:DecimalValue decimalType = new (123.56);
    decimal numericType = 12.12000;
    int tinyintType = 255;

    sql:ParameterizedCallQuery sqlQuery =
        `exec ExactNumericProcedure ${rowId}, ${smallintType}, ${intType}, ${bigintType}, ${decimalType},
                                ${numericType}, ${tinyintType};`;
    sql:ProcedureCallResult result = check callProcedure(sqlQuery, proceduresDb, [ExactNumericProcedureRecord]);

    sql:ParameterizedQuery query =
        `SELECT row_id, smallint_type, int_type, bigint_type, decimal_type, numeric_type, tinyint_type
         FROM ExactNumeric WHERE row_id = ${rowId}`;

    ExactNumericProcedureRecord expectedDataRow = {
        row_id: rowId,
        smallint_type: 1,
        int_type: 1,
        bigint_type: 123456,
        decimal_type: 123.56,
        numeric_type: 12.12000,
        tinyint_type: 255
    };
    test:assertEquals(check queryProcedureClient(query, proceduresDb, ExactNumericProcedureRecord), expectedDataRow,
                      "Numeric Call procedure insert and query did not match.");
}

public type ApproximateNumericProcedureRecord record {
    int row_id;
    float float_type;
    float real_type;
};

@test:Config {
    groups: ["procedures"],
    dependsOn: [testExactNumericProcedureCall]
}
function testApproximateNumericProcedureCall() returns error? {
    int rowId = 35;
    float floatType = 1.79E+308;
    float realType = -1.179999945774631E-38;
    sql:ParameterizedCallQuery sqlQuery = `exec ApproximateNumericProcedure ${rowId}, ${floatType}, ${realType};`;
    sql:ProcedureCallResult result = check callProcedure(sqlQuery, proceduresDb, [ApproximateNumericProcedureRecord]);

    sql:ParameterizedQuery query = `SELECT * FROM ApproximateNumeric WHERE row_id = ${rowId}`;

    ApproximateNumericProcedureRecord expectedDataRow = {
        row_id: rowId,
        float_type: 1.79E+308,
        real_type:-1.179999945774631E-38
    };
    test:assertEquals(check queryProcedureClient(query, proceduresDb, ApproximateNumericProcedureRecord), expectedDataRow,
                      "ApproximateNumeric Call procedure insert and query did not match.");
}

public type DatetimeProcedureRecord record {
    int row_id;
    string date_type;
    string time_type;
    string dateTime_type;
    string dateTime2_type;
    string smallDateTime_type;
    string dateTimeOffset_type;
};

@test:Config {
    groups: ["procedures"],
    dependsOn: [testApproximateNumericProcedureCall]
}
function testDatetimeProcedureCall() returns error? {
    int rowId = 35;
    sql:DateValue date = new ("2017-06-26");
    sql:DateTimeValue date_time_offset = new("2020-01-01 19:14:51.0021425 +05:30");
    sql:DateTimeValue date_time2 = new ("1900-01-01 00:25:00.0021425");
    sql:DateTimeValue small_date_time = new ("2007-05-10 10:00:20");
    sql:DateTimeValue date_time = new ("2017-06-26 09:54:21.325");
    sql:TimeValue time = new ("09:46:22");
    sql:ParameterizedCallQuery sqlQuery =
        `exec DatetimeProcedure ${rowId}, ${date}, ${date_time_offset}, ${date_time2}, ${small_date_time}, ${date_time}, ${time};`;
    sql:ProcedureCallResult result = check callProcedure(sqlQuery, proceduresDb, [DatetimeProcedureRecord]);

    sql:ParameterizedQuery query = `SELECT * FROM DateandTime WHERE row_id = ${rowId}`;

    DatetimeProcedureRecord expectedDataRow = {
        row_id: rowId,
        date_type: "2017-06-26",
        time_type: "09:46:22",
        dateTime_type: "2017-06-26 09:54:21.327",
        dateTime2_type: "1900-01-01 00:25:00.0021425",
        smallDateTime_type: "2007-05-10 10:00:00.0",
        dateTimeOffset_type: "2020-01-01 19:14:51.0021425 +05:30"
    };
    test:assertEquals(check queryProcedureClient(query, proceduresDb, DatetimeProcedureRecord), expectedDataRow,
                      "Datetime Call procedure insert and query did not match.");
}

public type MoneyProcedureRecord record {
    int row_id;
    string money_type;
    string smallMoney_type;
};

@test:Config {
    groups: ["procedures"],
    dependsOn: [testDatetimeProcedureCall]
}
function testMoneyProcedureCall() returns error? {
    int rowId = 35;
    MoneyValue moneyType = new(2356.12);
    SmallMoneyValue smallMoneyType = new(123.45);
    sql:ParameterizedCallQuery sqlQuery = `exec MoneyProcedure ${rowId}, ${moneyType}, ${smallMoneyType};`;
    sql:ProcedureCallResult result = check callProcedure(sqlQuery, proceduresDb, [MoneyProcedureRecord]);

    sql:ParameterizedQuery query = `SELECT *
        from MoneyTypes where row_id = ${rowId}`;

    MoneyProcedureRecord expectedDataRow = {
        row_id: rowId,
        money_type: "2356.1200",
        smallMoney_type: "123.4500"
    };
    test:assertEquals(check queryProcedureClient(query, proceduresDb, MoneyProcedureRecord), expectedDataRow,
                      "Money Call procedure insert and query did not match.");

}

function queryProcedureClient(string|sql:ParameterizedQuery sqlQuery, string database, typedesc<record {}> resultType)
returns record {} | error {
    Client dbClient = check new (host, user, password, database, port);
    stream<record{}, error> streamData = dbClient->query(sqlQuery, resultType);
    record {|record {} value;|}? data = check streamData.next();
    check streamData.close();
    record {}? value = data?.value;
    check dbClient.close();
    if (value is ()) {
        return {};
    } else {
        return value;
    }
}

function callProcedure(sql:ParameterizedCallQuery sqlQuery, string database, typedesc<record {}>[] rowTypes = []) returns sql:ProcedureCallResult | error {
    Client dbClient = check new (host, user, password, database, port, connectionPool = {
        maxOpenConnections: 25,
        maxConnectionLifeTime : 15,
        minIdleConnections : 15
    });
    sql:ProcedureCallResult result = check dbClient->call(sqlQuery, rowTypes);
    check dbClient.close();
    return result;
}
