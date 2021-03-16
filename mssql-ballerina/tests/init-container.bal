// / Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
// //
// // WSO2 Inc. licenses this file to you under the Apache License,
// // Version 2.0 (the "License"); you may not use this file except
// // in compliance with the License.
// // You may obtain a copy of the License at
// //
// // http://www.apache.org/licenses/LICENSE-2.0
// //
// // Unless required by applicable law or agreed to in writing,
// // software distributed under the License is distributed on an
// // "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// // KIND, either express or implied.  See the License for the
// // specific language governing permissions and limitations
// // under the License.

 import ballerina/io;
// import ballerina/os;
 import ballerina/test;
 import ballerina/file;
// import ballerina/lang.runtime as runtime;

string resourcePath = check file:getAbsolutePath("tests/resources");

string host = "localhost";
string user = "root";
string password = "root123#";
int port = 1433;

// @test:BeforeSuite
// function beforeSuite() {
    
//     os:Process process = checkpanic os:exec("docker", {}, resourcePath, "build", "-t", "ballerina-mssql", ".");
//     int exitCode = checkpanic process.waitForExit();
//     test:assertExactEquals(exitCode, 0, "Docker image 'ballerina-mssql' creation failed!");
 
//     process = checkpanic os:exec("docker", {}, resourcePath,
//                     "run", "--rm", "-d", "--name", "ballerina-mssql", "-p", "3305:3306", "-t", "ballerina-mssql");
//     exitCode = checkpanic process.waitForExit();
//     test:assertExactEquals(exitCode, 0, "Docker container 'ballerina-mssql' creation failed!");
//     runtime:sleep(50);

//     int healthCheck = 1;
//     int counter = 0;
//     while(healthCheck > 0 && counter < 12) {
//         runtime:sleep(10);
//         process = checkpanic os:exec("docker", {}, resourcePath,
//                     "exec", "ballerina-mssql", "mssqladmin", "ping", "-hlocalhost", "-uroot", "-pTest123#", "--silent");
//         healthCheck = checkpanic process.waitForExit();
//         counter = counter + 1;
//     }
//     test:assertExactEquals(healthCheck, 0, "Docker container 'ballerina-mssql' health test exceeded timeout!");    
//     io:println("Docker container started.");
// }

// @test:AfterSuite {}
// function afterSuite() {
//     os:Process process = checkpanic os:exec("docker", {}, resourcePath, "stop", "ballerina-mssql");
//     int exitCode = checkpanic process.waitForExit();
//     test:assertExactEquals(exitCode, 0, "Docker container 'ballerina-mssql' stop failed!");
// }
@test:BeforeSuite
function beforeSuite() {
    io:println("start test");
    _ = initTestScripts();
    io:println("End init test");
}

@test:AfterSuite
function afterSuite() {
    io:println("End Test");
}
