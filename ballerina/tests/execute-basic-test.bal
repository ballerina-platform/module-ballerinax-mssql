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

@test:Config {
    groups: ["execute", "execute-basic"]
}
function testCreateTable() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute("CREATE TABLE Student(studentID int, LastName"
        + " varchar(255))");
    check dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testCreateTable]
}
function testInsertTable() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute("INSERT INTO ExactNumericTypes (int_type) VALUES (20)");
    check dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    string|int? insertId = result.lastInsertId;
    if (insertId is string) {
        int|error id = int:fromString(insertId);
        if (id is int) {
            test:assertTrue(id == 1, "Last Insert Id is nil.");
        } else {
            test:assertFail("Insert Id should be an integer.");
        }
    } else {
        test:assertFail("Insert Id is not string");
    }
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTable]
}
function testInsertTableWithoutGeneratedKeys() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute(
        "INSERT INTO StringTypes (id, varchar_type) VALUES (5, 'test data')");
    check dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    test:assertEquals(result.lastInsertId, (), "Last Insert Id is nil.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithoutGeneratedKeys]
}
function testInsertTableWithGeneratedKeys() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute("INSERT INTO ExactNumericTypes (int_type) VALUES (21)");
    check dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertId = result.lastInsertId;
    if (insertId is string) {
        int|error id = int:fromString(insertId);
        if (id is int) {
            test:assertTrue(id > 1, "Last Insert Id is nil.");
        } else {
            test:assertFail("Insert Id should be an integer.");
        }
    } else {
        test:assertFail("Insert Id is not string");
    }
}

type ExactNumericType record {
    int id;
    int? int_type;
    int? bigint_type;
    int? smallint_type;
    int? tinyint_type;
    decimal? decimal_type;
    decimal? numeric_type;
};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithGeneratedKeys]
}
function testInsertAndSelectTableWithGeneratedKeys() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute("INSERT INTO ExactNumericTypes (int_type) VALUES (31)");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertId = result.lastInsertId;
    if (insertId is string) {
        int|error id = int:fromString(insertId);
        if (id is int) {
            string query = string `SELECT * from ExactNumericTypes where id = ${id}`;
            stream<record{}, error?> queryResult = dbClient->query(query, ExactNumericType);
            stream<ExactNumericType, sql:Error?> streamData = <stream<ExactNumericType, sql:Error?>>queryResult;
            record {|ExactNumericType value;|}? data = check streamData.next();
            check streamData.close();
            test:assertNotExactEquals(data?.value, (), "Incorrect InsetId returned.");
        } else {
        test:assertFail("Insert Id should be an integer.");
        }
    } else {
        test:assertFail("Insert Id is not string");
    }
    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertAndSelectTableWithGeneratedKeys]
}
function testInsertWithAllNilAndSelectTableWithGeneratedKeys() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute(
        "INSERT INTO ExactNumericTypes (smallint_type, int_type, bigint_type, decimal_type, numeric_type) "
        + "VALUES (null, null, null, null, null)");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string|int? insertedId = result.lastInsertId;
    if (insertedId is string) {
        int|error id = int:fromString(insertedId);
        if (id is int) {
            string query = string `SELECT * FROM ExactNumericTypes WHERE id = ${id}`;
            stream<record{}, error?> queryResult = dbClient->query(query, ExactNumericType);
            stream<ExactNumericType, sql:Error?> streamData = <stream<ExactNumericType, sql:Error?>>queryResult;
            record {|ExactNumericType value;|}? data = check streamData.next();
            check streamData.close();
            test:assertNotExactEquals(data?.value, (), "Incorrect InsetId returned.");
        } else {
            test:assertFail("Insert Id should be an integer.");
        }
    } else {
        test:assertFail("Insert Id is not string");
    }
}

type StringData record {
    int id;
    string varchar_type;
    string char_type;
    string text_type;
    string nchar_type;
    string nvarchar_type;
};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertAndSelectTableWithGeneratedKeys]
}
function testInsertWithStringAndSelectTable() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    string intIDVal = "25";
    string insertQuery = "INSERT INTO StringTypes (id, varchar_type, char_type, text_type"
        + ", nchar_type, nvarchar_type) VALUES (" + intIDVal + ",'str1','str2','str3','str4','str5')";
    sql:ExecutionResult result = check dbClient->execute(insertQuery);
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string query = string `SELECT * FROM StringTypes WHERE id = ${intIDVal}`;
    stream<record{}, error?> queryResult = dbClient->query(query, StringData);
    stream<StringData, sql:Error?> streamData = <stream<StringData, sql:Error?>>queryResult;
    record {|StringData value;|}? data = check streamData.next();
    check streamData.close();

    StringData expectedInsertRow = {
        id: 25,
        varchar_type: "str1",
        char_type: "str2",
        text_type: "str3",
        nchar_type: "str4",
        nvarchar_type: "str5"
    };
    test:assertEquals(data?.value, expectedInsertRow, "Incorrect InsetId returned.");

    check dbClient.close();
}

type ResultCount record {
    int countVal;
};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertWithStringAndSelectTable]
}
function testUpdateNumericData() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute("UPDATE ExactNumericTypes SET int_type = 11 WHERE int_type = 20");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    
    stream<record{}, error?> queryResult = dbClient->query(
        "SELECT COUNT(*) as countval FROM ExactNumericTypes WHERE int_type = 11", ResultCount);
    stream<ResultCount, sql:Error?> streamData = <stream<ResultCount, sql:Error?>>queryResult;
    record {|ResultCount value;|}? data = check streamData.next();
    check streamData.close();
    test:assertEquals(data?.value?.countVal, 1, "Update command was not successful.");

    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testUpdateNumericData]
}
function testUpdateStringData() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute(
        "UPDATE StringTypes SET varchar_type = 'updatedstring' WHERE varchar_type = 'str1'");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    
    stream<record{}, error?> queryResult = dbClient->query(
        "SELECT COUNT(*) as countval FROM StringTypes WHERE varchar_type = 'updatedstring'", ResultCount);
    stream<ResultCount, sql:Error?> streamData = <stream<ResultCount, sql:Error?>>queryResult;
    record {|ResultCount value;|}? data = check streamData.next();
    check streamData.close();
    test:assertEquals(data?.value?.countVal, 1, "String table Update command was not successful.");

    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testUpdateStringData]
}
function testDeleteNumericData() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult result = check dbClient->execute("INSERT INTO ExactNumericTypes (int_type) VALUES (1451)");
    result = check dbClient->execute("DELETE FROM ExactNumericTypes WHERE int_type = 1451");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    
    stream<record{}, error?> queryResult = dbClient->query(
        "SELECT COUNT(*) as countval FROM ExactNumericTypes WHERE int_type = 1451", ResultCount);
    stream<ResultCount, sql:Error?> streamData = <stream<ResultCount, sql:Error?>>queryResult;
    record {|ResultCount value;|}? data = check streamData.next();
    check streamData.close();
    test:assertEquals(data?.value?.countVal, 0, "Numeric table Delete command was not successful.");

    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testDeleteNumericData]
}
function testDeleteStringData() returns error? {
    Client dbClient = check new (host, user, password, executeDb, port);
    string intId = "28";
    sql:ExecutionResult result = check dbClient->execute(
        "INSERT INTO StringTypes (id, varchar_type) VALUES (" + intId +", 'deletestr')");
    result = check dbClient->execute("DELETE FROM StringTypes WHERE varchar_type = 'deletestr'");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    
    stream<record{}, error?> queryResult = dbClient->query(
        "SELECT COUNT(*) as countval FROM StringTypes WHERE varchar_type = 'deletestr'", ResultCount);
    stream<ResultCount, sql:Error?> streamData = <stream<ResultCount, sql:Error?>>queryResult;
    record {|ResultCount value;|}? data = check streamData.next();
    check streamData.close();
    test:assertEquals(data?.value?.countVal, 0, "String table Delete command was not successful.");

    check dbClient.close();
}

@test:Config {
    groups: ["execute", "execute-basic"]
}
function testPointTypeError() returns error? {
    int id =11;
    PointValue pointValue = new ("Invalid Value");
    sql:ParameterizedQuery sqlQuery = `INSERT INTO GeometricTypes (row_id, point_type) VALUES (${id}, ${pointValue});`;
    sql:ExecutionResult|sql:Error result = executeMSSQLClient(sqlQuery);
    test:assertTrue(result is error);
    string expectedErrorMessage = "Error while executing SQL query: INSERT INTO GeometricTypes (row_id, point_type) "+
        "VALUES ( ? ,  ? );. Illegal character in Well-Known text";
    if (result is sql:Error) {
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
    int id =11;
    GeometryCollectionValue GeometryValue = new ("Invalid Value");
    sql:ParameterizedQuery sqlQuery = `INSERT INTO GeometricTypes (row_id, geometry_type) VALUES (${id}, ${GeometryValue});`;
    sql:ExecutionResult|sql:Error result = executeMSSQLClient(sqlQuery);
    test:assertTrue(result is error);
    string expectedErrorMessage = "Error while executing SQL query: INSERT INTO GeometricTypes (row_id, geometry_type) "+
        "VALUES ( ? ,  ? );. Illegal character in Well-Known text";
    if (result is sql:Error) {
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
    int id =11;
    MoneyValue moneyValue = new ("Invalid Value");
    sql:ParameterizedQuery sqlQuery = `INSERT INTO MoneyTypes (row_id, money_type) VALUES (${id}, ${moneyValue});`;
    sql:ExecutionResult|sql:Error result = executeMSSQLClient(sqlQuery);
    test:assertTrue(result is error);
    string expectedErrorMessage = "Error while executing SQL query: INSERT INTO MoneyTypes (row_id, money_type) " +
        "VALUES ( ? ,  ? );. Cannot convert a char value to money.";
    if (result is sql:Error) {
        test:assertTrue(result.message().startsWith(expectedErrorMessage), 
           "Error message does not match, actual :\n'" + result.message() + "'\nExpected : \n" + expectedErrorMessage);
    } else {
        test:assertFail("Error expected");
    }
}

function executeMSSQLClient (sql:ParameterizedQuery|string sqlQuery) returns sql:ExecutionResult|sql:Error {
    Client dbClient = check new (host, user, password, executeDb, port);
    sql:ExecutionResult|sql:Error result = dbClient->execute(sqlQuery);
    check dbClient.close();
    return result;
}
