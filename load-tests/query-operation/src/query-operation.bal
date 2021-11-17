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
import ballerinax/mssql;
import ballerinax/mssql.driver as _;
import ballerina/http;

// The username , password and name of the MSSQL database
configurable string dbHost = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = ?;

type Customer record {
    int customerId;
    string lastName;
    string firstName;
    int registrationId;
    float creditLimit;
    string country;
};

final mssql:Client dbClient = check new(host = dbHost, user = dbUsername, password = dbPassword, database = dbName, port = dbPort);

public function main() returns error? {
    // Runs the prerequisite setup for the example.
    check beforeExample();
}

// Initializes the database as a prerequisite to the example.
function beforeExample() returns sql:Error? {
    mssql:Client mssqlClient = check new(host = dbHost, user = dbUsername, password = dbPassword, port = dbPort);
    _ = check mssqlClient->execute(`DROP DATABASE IF EXISTS EXAMPLE_DB`);
    _ = check mssqlClient->execute(`CREATE DATABASE EXAMPLE_DB`);
    _ = check mssqlClient.close();

    _ = check dbClient->execute(`DROP TABLE IF EXISTS Customers`);
    _ = check dbClient->execute(`
        CREATE TABLE Customers (
            customerId INT NOT NULL IDENTITY PRIMARY KEY,
            firstName VARCHAR(300),
            lastName  VARCHAR(300),
            registrationID INT,
            creditLimit FLOAT,
            country  VARCHAR(300)
        );
    `);

    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Peter','Stuart', 1, 5000.75, 'USA')`);
    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Dan', 'Brown', 2, 10000, 'UK')`);
    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Peter','Stuart', 3, 5000.75, 'USA')`);
    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Dan', 'Brown', 4, 10000, 'UK')`);
    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Peter','Stuart', 5, 5000.75, 'USA')`);
    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Dan', 'Brown', 6, 10000, 'UK')`);
    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Peter','Stuart', 7, 5000.75, 'USA')`);
    _ = check dbClient->execute(`
        INSERT INTO Customers (firstName, lastName, registrationID, creditLimit, country)
        VALUES ('Dan', 'Brown', 8, 10000, 'UK')`);

    check dbClient.close();
}

isolated service /customer on new http:Listener(9092) {
    resource isolated function get .(http:Caller caller, int id) returns error? {
        Customer|error customer = dbClient->queryRow(`SELECT * FROM Customers WHERE customerId = ${id}`);

        http:Response response = new;
        if customer is error {
            response.statusCode = 500;
            response.setPayload(customer.toString());
        } else {
            response.statusCode = 200;
            response.setPayload(customer.toString());
        }
        _ = check caller->respond(response);

        check dbClient.close();
    }
}
