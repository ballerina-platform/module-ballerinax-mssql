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


function getMssqlClient(string? database = (), int port = 1433) returns Client|error {
    Client dbClient = check new (host, user, password, database, port);
    return dbClient;
}

function queryMssqlClient(sql:ParameterizedQuery sqlQuery, typedesc<record {}>? resultType = (), string? database = ())
returns record {}|error? {
    Client dbClient = check getMssqlClient(database);
    stream<record {}, error?> streamData;
    if resultType is () {
        streamData = dbClient->query(sqlQuery);
    } else {
        streamData = dbClient->query(sqlQuery, resultType);
    }
    record {|record {} value;|}? data = check streamData.next();
    check streamData.close();
    record {}? value = data?.value;
    check dbClient.close();
    return value;
}

function executeQueryMssqlClient(sql:ParameterizedQuery sqlQuery, string? database = (), int port = 1433)
returns sql:ExecutionResult|error {
    Client dbClient = check getMssqlClient(database, port);
    sql:ExecutionResult result = check dbClient->execute(sqlQuery);
    check dbClient.close();
    return result;
}

function batchExecuteQueryMssqlClient(sql:ParameterizedQuery[] sqlQueries, string? database = (), int port = 1433)
returns sql:ExecutionResult[]|error {
    Client dbClient = check getMssqlClient(database, port);
    sql:ExecutionResult[] result = check dbClient->batchExecute(sqlQueries);
    check dbClient.close();
    return result;
}

function callProcedureMssqlClient(sql:ParameterizedCallQuery sqlQuery, string database, typedesc<record {}>[] rowTypes = [])
returns sql:ProcedureCallResult|error {
    Client dbClient = check getMssqlClient(database);
    sql:ProcedureCallResult result = check dbClient->call(sqlQuery, rowTypes);
    check dbClient.close();
    return result;
}
