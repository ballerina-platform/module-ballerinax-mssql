/*
 * Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.ballerinalang.mssql;

import io.ballerina.runtime.api.utils.StringUtils;
import io.ballerina.runtime.api.values.BString;

/**
 * Constants for JDBC client.
 *
 * @since 1.2.0
 */
public final class Constants {
    /**
     * Constants for Client Configs.
     */
    public static final class ClientConfiguration {
        public static final BString HOST = StringUtils.fromString("host");
        public static final BString INSTANCE_NAME = StringUtils.fromString("instanceName");
        public static final BString INTEGRATED_SECURITY = StringUtils.fromString("integratedSecurity");
        public static final BString PORT = StringUtils.fromString("port");
        public static final BString USER = StringUtils.fromString("user");
        public static final BString PASSWORD = StringUtils.fromString("password");
        public static final BString DATABASE = StringUtils.fromString("database");
        public static final BString OPTIONS = StringUtils.fromString("options");
        public static final BString CONNECTION_POOL_OPTIONS = StringUtils.fromString("connectionPool");
    }

    /**
     * Constants for database options.
     */
    public static final class Options {
        public static final BString SSL = StringUtils.fromString("ssl");
        public static final BString USE_XA_DATASOURCE = StringUtils.fromString("useXADatasource");
        public static final BString SOCKET_TIMEOUT_SECONDS = StringUtils.fromString("socketTimeoutInSeconds");
        public static final BString QUERY_TIMEOUT_SECONDS = StringUtils.fromString("queryTimeoutInSeconds");
        public static final BString LOGIN_TIMEOUT_SECONDS = StringUtils.fromString("loginTimeoutInSeconds");
    }

    /**
     * Constants for ssl configuration.
     */
    public static final class SSLConfig {
        public static final BString ENCRYPT = StringUtils.fromString("encrypt");
        public static final BString TRUST_SERVER_CERTIFICATE = StringUtils.fromString("trustServerCertificate");
        public static final BString TRUST_STORE = StringUtils.fromString("trustStore");
        public static final BString TRUST_STORE_PASSWORD = StringUtils.fromString("trustStorePassword");


        /**
        * Constants for processing ballerina `crypto:KeyStore`.
        */
        public static final class CryptoKeyStoreRecord {
            public static final BString KEY_STORE_RECORD_PATH_FIELD = StringUtils.fromString("path");
            public static final BString KEY_STORE_RECORD_PASSWORD_FIELD = StringUtils.fromString("password");
        }
    }
    
    /**
    * Constants for database specific properties.
    */
    public static final class DatabaseProps {
        public static final BString QUERY_TIMEOUT = StringUtils.fromString("queryTimeout");
        public static final BString SOCKET_TIMEOUT = StringUtils.fromString("socketTimeout");
        public static final BString LOGIN_TIMEOUT = StringUtils.fromString("loginTimeout");

    }

    public static final String MSSQL_DATASOURCE_NAME = "com.microsoft.sqlserver.jdbc.SQLServerXADataSource";
    public static final String MSSQL_XA_DATASOURCE_NAME = "com.microsoft.sqlserver.jdbc.SQLServerXADataSource";
    static final String FILE = "file:";
    public static final String POOL_CONNECT_TIMEOUT = "ConnectionTimeout";
}
