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
import ballerina/time;
import ballerina/test;

string proceduresDb = "procedures_db";

@test:BeforeGroups {
    value: ["procedures"]
}
function initCallProceduresTests() returns error? {
    _ = check executeQueryMssqlClient(`DROP DATABASE IF EXISTS PROCEDURES_DB`);
    _ = check executeQueryMssqlClient(`CREATE DATABASE PROCEDURES_DB`);

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

    sql:ParameterizedQuery query1 = `
        CREATE PROCEDURE StringProcedure
            @row_id_in int,
            @char_in char(14),
            @varchar_in varchar(255),
            @text_in text
        AS
            SET NOCOUNT ON
            INSERT INTO StringTypes ([row_id], [char_type], [varchar_type], [text_type])
            VALUES(@row_id_in, @char_in, @varchar_in, @text_in)
    `;

    sql:ParameterizedQuery query2 = `
        CREATE PROCEDURE ExactNumericProcedure
            @row_id_in int,
            @smallint_in smallint,
            @int_in int,
            @bigint_in bigint,
            @decimal_in decimal(5,2),
            @numeric_in numeric(10,5),
            @tinyint_in tinyint
        AS
            SET NOCOUNT ON
            INSERT INTO
            ExactNumeric ([row_id], [smallint_type], [int_type], [bigint_type], [decimal_type], [numeric_type], [tinyint_type])
            VALUES(@row_id_in, @smallint_in, @int_in, @bigint_in, @decimal_in, @numeric_in, @tinyint_in)
    `;

    sql:ParameterizedQuery query3 = `
        CREATE PROCEDURE DateTimeProcedure
            @row_id_in int,
            @date_type_in  date,
            @dateTimeOffset_type_in  datetimeoffset,
            @dateTime2_type_in datetime2,
            @smallDateTime_type_in smalldatetime,
            @dateTime_type_in datetime,
            @time_type_in time
        AS
            SET NOCOUNT ON
            INSERT INTO
                DateandTime ([row_id], [date_type], [dateTimeOffset_type], [dateTime2_type], [smallDateTime_type], [dateTime_type], [time_type])
            VALUES(
                @row_id_in, @date_type_in, @dateTimeOffset_type_in, @dateTime2_type_in, @smallDateTime_type_in,
                @dateTime_type_in, @time_type_in
            )
    `;

    sql:ParameterizedQuery query4 = `
        CREATE PROCEDURE ApproximateNumericProcedure
            @row_id_in int,
            @float_type_in float,
            @real_type_in real
        AS
            SET NOCOUNT ON
            INSERT INTO ApproximateNumeric ([row_id], [float_type], [real_type])
            VALUES (@row_id_in, @float_type_in, @real_type_in)
    `;

    sql:ParameterizedQuery query5 = `
        CREATE PROCEDURE MoneyProcedure
            @row_id_in int,
            @money_type_in money,
            @smallmoney_type_in smallmoney
        AS
            SET NOCOUNT ON
            INSERT INTO
            MoneyTypes ([row_id], [money_type], [smallMoney_type])
            VALUES (@row_id_in, @money_type_in,  @smallmoney_type_in)
    `;

    sql:ParameterizedQuery query6 = `
        CREATE PROCEDURE ExactNumericOutProcedure (
            @row_id_in int,
            @smallint_out smallint OUTPUT,
            @int_out int OUTPUT,
            @bigint_out bigint OUTPUT,
            @tinyint_out tinyint OUTPUT,
            @decimal_out decimal(5,2) OUTPUT,
            @numeric_out numeric(10,5) OUTPUT
        )
        AS
            SET NOCOUNT ON
            SELECT
                @smallint_out,
                @int_out,
                @bigint_out,
                @tinyint_out,
                @decimal_out,
                @numeric_out
            FROM
              ExactNumeric
            WHERE
              ExactNumeric.row_id = @row_id_in
    `;

    sql:ParameterizedQuery query7 = `
        CREATE PROCEDURE DateTimeOutProcedure
            @row_id_in int,
            @dateTimeOffset_type_out  datetimeoffset OUTPUT
        AS
            SET NOCOUNT OFF
            SELECT @dateTimeOffset_type_out = dateTimeOffset_type
            FROM DateandTime
            WHERE row_id = @row_id_in;
    `;

    // Data for timestamp retrieval test
    sql:ParameterizedQuery query8 = `INSERT INTO DateandTime (row_id, dateTimeOffset_type) VALUES (2,  '2021-07-21 19:14:51.00 +01:30')`;

    sql:ParameterizedQuery query9 = `
        CREATE PROCEDURE SelectStringTypesMultiple AS
        BEGIN
            SELECT row_id, varchar_type, char_type, text_type FROM StringTypes WHERE row_id = 1;
            SELECT varchar_type FROM StringTypes WHERE row_id = 1;
        END
     `;

    _ = check executeQueryMssqlClient(query, proceduresDb);
    _ = check executeQueryMssqlClient(query1, proceduresDb);
    _ = check executeQueryMssqlClient(query2, proceduresDb);
    _ = check executeQueryMssqlClient(query3, proceduresDb);
    _ = check executeQueryMssqlClient(query4, proceduresDb);
    _ = check executeQueryMssqlClient(query5, proceduresDb);
    _ = check executeQueryMssqlClient(query6, proceduresDb);
    _ = check executeQueryMssqlClient(query7, proceduresDb);
    _ = check executeQueryMssqlClient(query8, proceduresDb);
    _ = check executeQueryMssqlClient(query9, proceduresDb);
}

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
    sql:ProcedureCallResult result = check callProcedureMssqlClient(sqlQuery, proceduresDb, [StringProcedureRecord]);

    sql:ParameterizedQuery query = `SELECT row_id, char_type, varchar_type, text_type FROM StringTypes WHERE row_id = ${rowId}`;

    StringProcedureRecord expectedDataRow = {
        row_id: rowId,
        char_type: "This is a char",
        varchar_type: "This is a varchar3",
        text_type: "This is a text3"
    };
    test:assertEquals(check queryMssqlClient(query, StringProcedureRecord, proceduresDb), expectedDataRow,
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
    groups: ["procedures"]
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
    sql:ProcedureCallResult result = check callProcedureMssqlClient(sqlQuery, proceduresDb, [ExactNumericProcedureRecord]);

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
    test:assertEquals(check queryMssqlClient(query, ExactNumericProcedureRecord, proceduresDb), expectedDataRow,
                      "Numeric Call procedure insert and query did not match.");
}

public type ApproximateNumericProcedureRecord record {
    int row_id;
    float float_type;
    float real_type;
};

@test:Config {
    groups: ["procedures"]
}
function testApproximateNumericProcedureCall() returns error? {
    int rowId = 35;
    float floatType = 1.79E+308;
    float realType = -1.179999945774631E-38;
    sql:ParameterizedCallQuery sqlQuery = `exec ApproximateNumericProcedure ${rowId}, ${floatType}, ${realType};`;
    sql:ProcedureCallResult result = check callProcedureMssqlClient(sqlQuery, proceduresDb, [ApproximateNumericProcedureRecord]);

    sql:ParameterizedQuery query = `SELECT * FROM ApproximateNumeric WHERE row_id = ${rowId}`;

    ApproximateNumericProcedureRecord expectedDataRow = {
        row_id: rowId,
        float_type: 1.79E+308,
        real_type:-1.179999945774631E-38
    };
    test:assertEquals(check queryMssqlClient(query, ApproximateNumericProcedureRecord, proceduresDb), expectedDataRow,
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
    groups: ["procedures"]
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
    sql:ProcedureCallResult result = check callProcedureMssqlClient(sqlQuery, proceduresDb, [DatetimeProcedureRecord]);

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
    test:assertEquals(check queryMssqlClient(query, DatetimeProcedureRecord, proceduresDb), expectedDataRow,
                      "Datetime Call procedure insert and query did not match.");
}

public type MoneyProcedureRecord record {
    int row_id;
    string money_type;
    string smallMoney_type;
};

@test:Config {
    groups: ["procedures"]
}
function testMoneyProcedureCall() returns error? {
    int rowId = 35;
    MoneyValue moneyType = new(2356.12);
    SmallMoneyValue smallMoneyType = new(123.45);
    sql:ParameterizedCallQuery sqlQuery = `exec MoneyProcedure ${rowId}, ${moneyType}, ${smallMoneyType};`;
    sql:ProcedureCallResult result = check callProcedureMssqlClient(sqlQuery, proceduresDb, [MoneyProcedureRecord]);

    sql:ParameterizedQuery query = `SELECT *
        from MoneyTypes where row_id = ${rowId}`;

    MoneyProcedureRecord expectedDataRow = {
        row_id: rowId,
        money_type: "2356.1200",
        smallMoney_type: "123.4500"
    };
    test:assertEquals(check queryMssqlClient(query, MoneyProcedureRecord, proceduresDb), expectedDataRow,
                      "Money Call procedure insert and query did not match.");
}

@test:Config {
    groups: ["procedures"]
}
function testTimestamptzRetrieval() returns error? {
    string datetimetz = "2021-07-21T19:14:51.00+01:30";
    sql:TimestampWithTimezoneOutParameter datetimetzOutValue = new;

    sql:ParameterizedCallQuery sqlQuery = `{call DateTimeOutProcedure (2, ${datetimetzOutValue})}`;
    _ = check callProcedureMssqlClient(sqlQuery, proceduresDb, [DatetimeProcedureRecord]);

    test:assertEquals(check datetimetzOutValue.get(time:Utc), check time:utcFromString(datetimetz),
                      "Retrieved date time with timestamp does not match.");
}

@test:Config {
    groups: ["procedures"]
}
function testMultipleSelectProcedureCall() returns error? {
    sql:ParameterizedCallQuery sqlQuery = `{call SelectStringTypesMultiple}`;
    Client dbClient = check getMssqlClient(proceduresDb);
    sql:ProcedureCallResult result = check dbClient->call(sqlQuery, [StringProcedureRecord, StringProcedureRecord]);

    stream<record {}, sql:Error?>? qResult = result.queryResult;
    if qResult is () {
        test:assertFail("First result set is empty.");
    } else {
        record {|record {} value;|}? data = check qResult.next();
        record {}? result1 = data?.value;
        StringProcedureRecord expectedDataRow = {
            row_id: 1,
            char_type: "This is a char",
            varchar_type: "This is a varchar",
            text_type: "This is a long text"
        };
        test:assertEquals(result1, expectedDataRow, "Call procedure first select did not match.");
    }

    boolean nextResult = check result.getNextQueryResult();
    if !nextResult {
        test:assertFail("Only one result set returned.");
    }

    qResult = result.queryResult;
    if qResult is () {
        test:assertFail("Second result set is empty.");
    } else {
        record {|record {} value;|}? data = check qResult.next();
        record {}? result1 = data?.value;
        record {} expectedDataRow = {
            "varchar_type": "This is a varchar"
        };
        test:assertEquals(result1, expectedDataRow, "Call procedure second select did not match.");
    }

    check result.close();
    check dbClient.close();
}
