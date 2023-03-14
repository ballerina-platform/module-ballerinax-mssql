/*
 * Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package io.ballerina.stdlib.mssql.compiler;

/**
 * Constants for MSSQL compiler plugin.
 */
public class Constants {
    public static final String BALLERINAX = "ballerinax";
    public static final String MSSQL = "mssql";
    public static final String CONNECTION_POOL_PARM_NAME = "connectionPool";
    public static final String OPTIONS_PARM_NAME = "options";

    private Constants() {
    }

    /**
     * Constants related to Client object.
     */
    public static class Client {
        public static final String CLIENT = "Client";

        private Client() {
        }
    }

    /**
     * Constants for fields in sql:ConnectionPool.
     */
    public static class ConnectionPool {
        public static final String MAX_OPEN_CONNECTIONS = "maxOpenConnections";
        public static final String MAX_CONNECTION_LIFE_TIME = "maxConnectionLifeTime";
        public static final String MIN_IDLE_CONNECTIONS = "minIdleConnections";

        private ConnectionPool() {
        }
    }

    /**
     * Constants for fields in mssql:Options.
     */
    public static class Options {
        public static final String NAME = "Options";
        public static final String LOGIN_TIMEOUT = "loginTimeout";
        public static final String SOCKET_TIMEOUT = "socketTimeout";
        public static final String QUERY_TIMEOUT = "queryTimeout";

        private Options() {
        }
    }

    public static final String UNNECESSARY_CHARS_REGEX = "\"|\\n";

}
