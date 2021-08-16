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

import ballerina/io;
import ballerina/sql;

isolated function createQuery(sql:ParameterizedQuery query) {

    Client|sql:Error mssqlClient = new(user="sa",password="Test123#");

    if(mssqlClient is sql:Error) {
        io:println("Client init failed\n",mssqlClient);
    }
    else{
        sql:ExecutionResult|sql:Error result__;
        sql:Error? e__;

        result__ = mssqlClient->execute(query);
        if(result__ is sql:Error) {
            io:println("Init Database drop failed\n",result__);
        }
        else{
            io:println("Init Database drop passed\n",result__);
        }
        e__ = mssqlClient.close();

        if(e__ is sql:Error) {
            io:println("Client close failed\n",e__);
        }
        else{
            io:println("Client closed");
        }
    }

}

isolated function executeQuery(string database, sql:ParameterizedQuery query) {

    Client|sql:Error mssqlClient = new(user="sa",password="Test123#", database = database);

    if(mssqlClient is sql:Error) {
        io:println("Client init failed\n",mssqlClient);
    }
    else{
        sql:ExecutionResult|sql:Error result__;
        sql:Error? e__;

        result__ = mssqlClient->execute(query);
        if(result__ is sql:Error) {
            io:println("Init Execute drop failed\n",result__);
        }
        else{
            io:println("Init Execute drop passed\n",result__);
        }
        e__ = mssqlClient.close();

        if(e__ is sql:Error) {
            io:println("Client close1 failed\n",e__);
        }
        else{
            io:println("Client closed");
        }
    }
}
