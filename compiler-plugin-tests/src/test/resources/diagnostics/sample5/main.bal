// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerinax/mssql;
import ballerinax/mssql.driver as _;

type SqlConnectionPoolConfig record {|
    int maxOpenConnections = 10;
    decimal maxConnectionLifeTime = 180;
    int minIdleConnections = 5;
|};

type MssqlOptionsConfig record {|
    decimal connectTimeout = 10;
|};

type AllocationDatabase record {|
    SqlConnectionPoolConfig connectionPool;
    MssqlOptionsConfig mssqlOptions;
|};

configurable AllocationDatabase allocationDatabase = ?;

final mssql:Client allocationDbClient = check new (
    host = "localhost",
    user = "test",
    password = "test",
    port = 3306,
    database = "test",
    connectionPool = {
        ...allocationDatabase.connectionPool
    },
    options = {
        ssl: {
            mode: mssql:SSL_PREFERRED
        },
        connectTimeout: allocationDatabase.mssqlOptions.connectTimeout
    }
);
