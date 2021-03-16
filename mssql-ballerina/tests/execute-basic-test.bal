
// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerina/io;

string executeDb = "EXECUTE_DB";

@test:Config {
    groups: ["execute", "execute-basic"]
}
function testCreateTable() {
    Client dbClient = checkpanic new (host, user, password, executeDb, port);
    sql:ExecutionResult result = checkpanic dbClient->execute("CREATE TABLE TestCreateTable(studentID int, LastName"
        + " varchar(255))");
    checkpanic dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 0, "Affected row count is different.");
    test:assertExactEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testCreateTable]
}
function testInsertTable() {
    Client dbClient = checkpanic new (host, user, password, executeDb, port);
    sql:ExecutionResult result = checkpanic dbClient->execute("Insert into ExactNumericTypes (int_type) values (20)");
    checkpanic dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
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

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTable]
}
function testInsertTableWithoutGeneratedKeys() {
    Client dbClient = checkpanic new (host, user, password, executeDb, port);
    sql:ExecutionResult result = checkpanic dbClient->execute("Insert into StringTypes (id, varchar_type)"
        + " values (20, 'test')");
    checkpanic dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    test:assertEquals(result.lastInsertId, (), "Last Insert Id is nil.");
}

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithoutGeneratedKeys]
}
function testInsertTableWithGeneratedKeys() {
    Client dbClient = checkpanic new (host, user, password, executeDb, port);
    sql:ExecutionResult result = checkpanic dbClient->execute("insert into ExactNumericTypes (int_type) values (21)");
    checkpanic dbClient.close();
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
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

type ExactNumericType record {
    int id;
    int? int_type;
    int? bigint_type;
    int? smallint_type;
    int? tinyint_type;
    decimal? decimal_type;
    decimal? numeric_type;
    float? float_type;
    float? real_type;
};

@test:Config {
    groups: ["execute", "execute-basic"],
    dependsOn: [testInsertTableWithGeneratedKeys]
}
function testInsertAndSelectTableWithGeneratedKeys() {
    Client dbClient = checkpanic new (host, user, password, executeDb, port);
    sql:ExecutionResult result = checkpanic dbClient->execute("insert into ExactNumericTypes (int_type) values (31)");

    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    var insertId = result.lastInsertId;
    if (insertId is string) {
        int|error id = int:fromString(insertId);
        if (id is int) {
            string query = string `SELECT * from ExactNumericTypes where id = ${id}`;
            stream<record{}, error> queryResult = dbClient->query(query, ExactNumericType);
            stream<ExactNumericType, sql:Error> streamData = <stream<ExactNumericType, sql:Error>>queryResult;
            record {|ExactNumericType value;|}? data = checkpanic streamData.next();
            checkpanic streamData.close();
            test:assertNotExactEquals(data?.value, (), "Incorrect InsetId returned.");
        } else {
        test:assertFail("Insert Id should be an integer.");
        }
    }    
    checkpanic dbClient.close();
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
function testInsertWithStringAndSelectTable() {
    Client dbClient = checkpanic new (host, user, password, executeDb, port);
    string intIDVal = "25";
    string insertQuery = "Insert into StringTypes (id, varchar_type, char_type, text_type"
        + ", nchar_type, nvarchar_type) values ("
        + intIDVal + ",'str1','str2','str3','str4','str5')";
    sql:ExecutionResult result = checkpanic dbClient->execute(insertQuery);
    
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");

    string query = string `SELECT * from StringTypes where id = ${intIDVal}`;
    stream<record{}, error> queryResult = dbClient->query(query, StringData);
    stream<StringData, sql:Error> streamData = <stream<StringData, sql:Error>>queryResult;
    record {|StringData value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();

    StringData expectedInsertRow = {
        id: 25,
        varchar_type: "str1",
        char_type: "str2",
        text_type: "str3",
        nchar_type: "str4",
        nvarchar_type: "str5"
    };
    test:assertEquals(data?.value, expectedInsertRow, "Incorrect InsetId returned.");

    checkpanic dbClient.close();
}

// @test:Config {
//     groups: ["execute", "execute-basic"],
//     dependsOn: [testInsertWithStringAndSelectTable]
// }
// function testInsertTableWithDatabaseError() {
//     Client dbClient = checkpanic new (host, user, password, executeDb, port);
//     sql:ExecutionResult|sql:Error result = dbClient->execute("Insert into NumericTypesNonExistTable (int_type) values (20)");

//     if (result is sql:DatabaseError) {
//         test:assertTrue(result.message().startsWith("Error while executing SQL query: Insert into NumericTypesNonExistTable " + 
//                         "(int_type) values (20). Table 'EXECUTE_DB.NumericTypesNonExistTable' doesn't exist."), 
//                         "Error message does not match, actual :'" + result.message() + "'");
//         sql:DatabaseErrorDetail errorDetails = result.detail();
//         test:assertEquals(errorDetails.errorCode, 1146, "SQL Error code does not match");
//         test:assertEquals(errorDetails.sqlState, "42S02", "SQL Error state does not match");
//     } else {
//         test:assertFail("Database Error expected.");
//     }

//     checkpanic dbClient.close();
// }

// @test:Config {
//     groups: ["execute", "execute-basic"],
//     // dependsOn: [testInsertTableWithDatabaseError]
//     dependsOn: [testInsertWithStringAndSelectTable]
// }
// function testInsertTableWithDataTypeError() {
//     Client dbClient = checkpanic new (host, user, password, executeDb, port);
//     sql:ExecutionResult|sql:Error result = dbClient->execute("Insert into ExactNumericTypes (int_type) values"
//         + " ('This is wrong type')");

//     if (result is sql:DatabaseError) {
//         test:assertTrue(result.message().startsWith("Error while executing SQL query: Insert into ExactNumericTypes " + 
//                     "(int_type) values ('This is wrong type'). Incorrect integer value: 'This is wrong type' for column 'int_type'"), 
//                     "Error message does not match, actual :'" + result.message() + "'");
//         sql:DatabaseErrorDetail errorDetails = result.detail();
//         test:assertEquals(errorDetails.errorCode, 1366, "SQL Error code does not match");
//         test:assertEquals(errorDetails.sqlState, "HY000", "SQL Error state does not match");
//     } else {
//         test:assertFail("Database Error expected.");
//     }

//     checkpanic dbClient.close();
// }

type ResultCount record {
    int countVal;
};

@test:Config {
    groups: ["execute", "execute-basic"],
    // dependsOn: [testInsertTableWithDataTypeError]
    dependsOn: [testInsertWithStringAndSelectTable]
}
function testUpdateData() {
    Client dbClient = checkpanic new (host, user, password, executeDb, port);
    sql:ExecutionResult result = checkpanic dbClient->execute("Update ExactNumericTypes set int_type = 11 where int_type = 10");
    test:assertExactEquals(result.affectedRowCount, 1, "Affected row count is different.");
    
    stream<record{}, error> queryResult = dbClient->query("SELECT count(*) as countval from ExactNumericTypes"
        + " where int_type = 11", ResultCount);
    stream<ResultCount, sql:Error> streamData = <stream<ResultCount, sql:Error>>queryResult;
    record {|ResultCount value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    test:assertEquals(data?.value?.countVal, 1, "Update command was not successful.");

    checkpanic dbClient.close();
}
