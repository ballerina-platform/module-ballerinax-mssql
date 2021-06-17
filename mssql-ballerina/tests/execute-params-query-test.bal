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

string executeParamsDb = "EXECUTE_PARAMS_DB";

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoExactNumericTable1() returns error? {
    int rowId = 6;
    int big_int = 9223372036854775807;
    decimal numeric = 12.12000;
    int bit = 1;
    float small_int = 32767;
    float decimalc = 123.00;
    decimal intc = 2147483647;
    int tiny_int = 255;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, smallint_type, decimal_type, int_type, tinyint_type)
         VALUES (${rowId}, ${big_int}, ${numeric}, ${bit}, ${small_int}, ${decimalc}, ${intc}, ${tiny_int})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoExactNumericTable1]
}
function insertIntoExactNumericTable2() returns error? {
    int rowId = 5;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO ExactNumeric (row_id) VALUES(${rowId})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoExactNumericTable2]
}
function insertIntoExactNumericTable3() returns error? {
    int rowId = 7;
    sql:IntegerValue big_int = new(9223372036854775807);
    sql:DecimalValue numeric = new(12.12000);
    sql:IntegerValue bit = new(1);
    sql:FloatValue small_int = new(32767);
    sql:DecimalValue decimalc = new(123.00);
    sql:IntegerValue intc = new(2147483647);
    sql:IntegerValue tiny_int = new(255);

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, smallint_type, decimal_type, int_type, tinyint_type)
         VALUES (${rowId},${big_int}, ${numeric}, ${bit}, ${small_int}, ${decimalc}, ${intc}, ${tiny_int})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoExactNumericTable3]
}
function insertIntoApproximateNumericTable1() returns error? {
    int rowId = 7;
    float float_value = 1.79E+308;
    decimal real_value = -1.18E-38;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ApproximateNumeric (row_id, float_type, real_type) VALUES (${rowId}, ${float_value}, ${real_value})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoApproximateNumericTable1]
}
function insertIntoApproximateNumericTable2() returns error? {
    int rowId = 8;
    float float_value = 1.79E+308;
    float real_value = -1.18E-38;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ApproximateNumeric (row_id, float_type, real_type) VALUES (${rowId}, ${float_value}, ${real_value})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoExactNumericTable3]
}
function deleteExactNumeric() returns error? {
    int rowId = 1;
    int big_int = 9223372036854775807;
    decimal numeric = 12.12000;
    int bit = 1;
    float small_int = 32767;
    float decimalc = 123.00;

    sql:ParameterizedQuery sqlQuery =
        `DELETE FROM ExactNumeric WHERE row_id=${rowId} AND bigint_type=${big_int} AND numeric_type=${numeric}
         AND bit_type=${bit} AND smallint_type=${small_int} AND decimal_type=${decimalc}`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoApproximateNumericTable2]
}
function insertIntoStringTypeTable1() returns error? {
    int rowId = 2;
    string varchar_type = "This is a varchar";
    string char_type = "test";
    string text_type = "This is a text";
    string nchar_type = "test" ;
    string nvarchar_type = "nvarchar";

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type)
         VALUES (${rowId}, ${varchar_type}, ${char_type}, ${text_type}, ${nchar_type}, ${nvarchar_type})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoStringTypeTable1]
}
function insertIntoStringTypeTable2() returns error? {
    int rowId = 3;
    sql:VarcharValue varchar_type = new ("This is a varchar");
    sql:CharValue char_type = new ("test");
    sql:TextValue text_type = new ("This is a text");
    sql:CharValue nchar_type = new ("test");
    sql:VarcharValue nvarchar_type = new ("nvarchar");

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type)
         VALUES (${rowId}, ${varchar_type}, ${char_type}, ${text_type}, ${nchar_type}, ${nvarchar_type})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoStringTypeTable2]
}
function insertIntoStringTypeTable3() returns error? {
    int rowId = 4;
    sql:VarcharValue varchar_type = new ();
    sql:CharValue char_type = new ();
    sql:TextValue text_type = new ();
    sql:CharValue nchar_type = new ();
    sql:VarcharValue nvarchar_type = new ();

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type)
         VALUES (${rowId}, ${varchar_type}, ${char_type}, ${text_type}, ${nchar_type}, ${nvarchar_type})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoStringTypeTable3]
}
function insertIntoDateTimeTable1() returns error? {
    int rowId = 2;
    string date = "2017-06-26";
    string date_time_offset = "1900-01-01 00:25:00.0021425 +05:30";
    string date_time2 = "1900-01-01 00:25:00.0021425";
    string small_date_time = "2007-05-10 10:00:20";
    string date_time = "2017-06-26 09:54:21.325";
    string time = "09:46:22";

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type, dateTime_type, time_type)
         VALUES(${rowId}, ${date}, ${date_time_offset}, ${date_time2}, ${small_date_time}, ${date_time}, ${time})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable1]
}
function insertIntoDateTimeTable2() returns error? {
    int rowId = 3;
    sql:DateValue date = new ("2017-06-26");
    sql:DateTimeValue date_time_offset = new("1900-01-01 00:25:00.0021425 +05:30");
    sql:DateTimeValue date_time2 = new ("1900-01-01 00:25:00.0021425");
    sql:DateTimeValue small_date_time = new ("2007-05-10 10:00:20");
    sql:DateTimeValue date_time = new ("2017-06-26 09:54:21.325");
    sql:TimeValue time = new ("09:46:22");

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type, dateTime_type, time_type)
         VALUES(${rowId}, ${date}, ${date_time_offset}, ${date_time2}, ${small_date_time}, ${date_time}, ${time})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable2]
}
function insertIntoDateTimeTable3() returns error? {
    int rowId = 4;
    sql:DateValue date = new ();
    sql:DateTimeValue date_time_offset = new();
    sql:DateTimeValue date_time2 = new ();
    sql:DateTimeValue small_date_time = new ();
    sql:DateTimeValue date_time = new ();
    sql:TimeValue time = new ();

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type, dateTime_type, time_type)
         VALUES(${rowId}, ${date}, ${date_time_offset}, ${date_time2}, ${small_date_time}, ${date_time}, ${time})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable3]
}
function insertIntoDateTimeTable4() returns error? {
    int rowId = 5;
    time:Date dateValue = {year: 2017, month: 12, day: 18};
    time:TimeOfDay timeValue = {hour: 23, minute: 12, second: 18};
    time:Civil timestamp = {year: 2017, month:2, day: 3, hour: 11, minute: 53, second:0, "utcOffset": {hours: 8, minutes: 30}};
    sql:DateValue date = new (dateValue);
    sql:DateTimeValue date_time_offset = new(timestamp);
    sql:DateTimeValue date_time2 = new ();
    sql:DateTimeValue small_date_time = new ();
    sql:DateTimeValue date_time = new ();
    sql:TimeValue time = new (timeValue);

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type, dateTime_type, time_type)
         VALUES(${rowId}, ${date}, ${date_time_offset}, ${date_time2}, ${small_date_time}, ${date_time}, ${time})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute-params", "execute"],
    dependsOn: [insertIntoDateTimeTable3]
}
function testInsertIntoGeometricDataTable1() returns error? {
    int rowId = 43;
    PointValue pointType = new ({x: 4.34, y:6, srid: 2});
    LineStringValue lineStringType = new ({x1:2, y1:4, x2:3, y2:6});

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO GeometricTypes (row_id, point_type, lineString_type)
         VALUES(${rowId}, ${pointType}, ${lineStringType})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute-params", "execute"],
    dependsOn: [testInsertIntoGeometricDataTable1]
}
function testInsertIntoGeometricDataTable2() returns error? {
    int rowId = 21;
    Point point = {x: 2, y:2};
    PointValue pointType = new(point);
    LineStringValue lineStringType = new("LINESTRING(1 1,2 3,4 8, -6 3)");
    GeometryCollectionValue geometryType = new("GEOMETRYCOLLECTION (POINT (4 0), LINESTRING (4 2, 5 3), POLYGON ((0 0, 3 0, 3 3, 0 3, 0 0), (1 1, 1 2, 2 2, 2 1, 1 1)))");
    CircularStringValue circularStringType = new("CIRCULARSTRING(2 0, 1 1, 0 0)");
    CompoundCurveValue compoundCurveType = new("COMPOUNDCURVE(CIRCULARSTRING(1 0, 0 1, -1 0), (-1 0, 1.25 0))");
    PolygonValue polygonType = new("POLYGON((1 1, 3 1, 3 7, 1 7, 1 1))");
    MultiPolygonValue multiPolygonType = new("MultiPolygon(((2 0, 3 1, 2 2, 1.5 1.5, 2 1, 1.5 0.5, 2 0)), ((1 0, 1.5 0.5, 1 1, 1.5 1.5, 1 2, 0 1, 1 0)))");
    CurvePolygonValue curvePolygonType = new("CURVEPOLYGON ((4 2, 8 2, 8 6, 4 6, 4 2))");
    MultiLineStringValue multiLineStringType = new("MultiLineString ((0 2, 1 1), (2 1, 1 2))");
    MultiPointValue multiPointType = new("MULTIPOINT((21 2), (12 2), (30 40))");

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO GeometricTypes (row_id, point_type, lineString_type, geometry_type, circularstring_type,
            compoundcurve_type, polygon_type, curvepolygon_type, multipolygon_type, multilinestring_type, multipoint_type)
         VALUES(${rowId}, ${pointType}, ${lineStringType}, ${geometryType}, ${circularStringType}, ${compoundCurveType},
            ${polygonType}, ${multiPolygonType}, ${curvePolygonType}, ${multiLineStringType}, ${multiPointType})
    `;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute-params", "execute"],
    dependsOn: [testInsertIntoGeometricDataTable2]
}
function testInsertIntoGeometricDataTable3() returns error? {
    //int rowId = 22;
    //PointValue pointType = new ();
    //LineStringValue lineStringType = new ();
    //GeometryCollectionValue geometryType = new ();
    //CircularStringValue circularStringType = new ();
    //CompoundCurveValue compoundCurveType = new ();
    //PolygonValue polygonType = new ();
    //MultiPolygonValue multiPolygonType = new ();
    //CurvePolygonValue curvePolygonType = new ();
    //MultiLineStringValue multiLineStringType = new ();
    //MultiPointValue multiPointType = new ();
//
    //sql:ParameterizedQuery sqlQuery =
    //  `INSERT INTO GeometricTypes (row_id, point_type, lineString_type, geometry_type, circularstring_type, compoundcurve_type,
    //        polygon_type, curvepolygon_type, multipolygon_type, multilinestring_type, multipoint_type)
    //   VALUES(${rowId}, ${pointType}, ${lineStringType}, ${geometryType}, ${circularStringType}, ${compoundCurveType},
    //        ${polygonType}, ${multiPolygonType}, ${curvePolygonType}, ${multiLineStringType}, ${multiPointType})`;
    //validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute-params", "execute"],
    dependsOn: [testInsertIntoGeometricDataTable3]
}
function testInsertIntoGeometricDataTable4() returns error? {
    int rowId = 24;
    Point point = {x: 2, y:2};
    LineString lineString = {x1:2, y1:4, x2:3, y2:6};

    PointValue pointType = new (point);
    LineStringValue lineStringType = new (lineString);

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO GeometricTypes (row_id, point_type, lineString_type)
         VALUES(${rowId}, ${pointType}, ${lineStringType})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute-params", "execute"],
    dependsOn: [testInsertIntoGeometricDataTable4]
}
function testInsertIntoMoneyDataTable1() returns error? {
    int rowId = 2;
    MoneyValue moneyType = new (12223233837.7868);
    SmallMoneyValue smallMoneyType = new (2345.56);

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO MoneyTypes (row_id, money_type, smallmoney_type)
         VALUES(${rowId}, ${moneyType}, ${smallMoneyType})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute-params", "execute"],
    dependsOn: [testInsertIntoMoneyDataTable1]
}
function testInsertIntoMoneyDataTable2() returns error? {
    int rowId = 3;
    float moneyType = 12223233837.7868;
    decimal smallMoneyType = 2345.56;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO MoneyTypes (row_id, money_type, smallmoney_type)
         VALUES(${rowId}, ${moneyType}, ${smallMoneyType})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

@test:Config {
    groups: ["execute-params", "execute"],
    dependsOn: [testInsertIntoMoneyDataTable2]
}
function testInsertIntoMoneyDataTable3() returns error? {
    int rowId = 4;
    MoneyValue moneyType = new ();
    SmallMoneyValue smallMoneyType = new ();

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO MoneyTypes (row_id, money_type, smallmoney_type)
         VALUES(${rowId}, ${moneyType}, ${smallMoneyType})`;
    validateResult(check executeQueryMssqlClient(sqlQuery, executeParamsDb), 1, rowId);
}

function executeQueryMssqlClient(sql:ParameterizedQuery sqlQuery, string database) returns sql:ExecutionResult | error {
    Client dbClient = check new (host, user, password, database, port);
    sql:ExecutionResult result = check dbClient->execute(sqlQuery);
    check dbClient.close();
    return result;
}

isolated function validateResult(sql:ExecutionResult result, int rowCount, int? lastId = ()) {
    test:assertExactEquals(result.affectedRowCount, rowCount, "Affected row count is different.");

    if (lastId is ()) {
        test:assertEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    } else {
        string|int? insertId = result.lastInsertId;
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
