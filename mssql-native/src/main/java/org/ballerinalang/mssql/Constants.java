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
import static io.ballerina.runtime.api.utils.StringUtils.fromString;
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
        public static final BString SOCKET_TIMEOUT = StringUtils.fromString("socketTimeout");
        public static final BString QUERY_TIMEOUT = StringUtils.fromString("queryTimeout");
        public static final BString LOGIN_TIMEOUT = StringUtils.fromString("loginTimeout");
    }

    /**
     * Constants for ssl configuration.
     */
    public static final class SSLConfig {
        public static final BString CLIENT_CERT_KEYSTORE = StringUtils.fromString("clientCertKeystore");
        public static final BString TRUST_CERT_KEYSTORE = StringUtils.fromString("trustCertKeystore");

         // The following constants are used to process ballerina `crypto:KeyStore`
        public static final class CryptoKeyStoreRecord {
            public static final BString KEY_STORE_RECORD_PATH_FIELD = StringUtils.fromString("path");
            public static final BString KEY_STORE_RECORD_PASSWORD_FIELD = StringUtils.fromString("password");
        }

        }
    
    public static final class DatabaseProps {
        public static final BString SSL_MODE = StringUtils.fromString("sslMode");
        public static final BString SSL_MODE_DISABLED = StringUtils.fromString("DISABLE");
        public static final BString SSL_MODE_VERIFY_CA = StringUtils.fromString("VERIFY_CA");

        public static final BString KEYSTORE_TYPE_PKCS12 = StringUtils.fromString("PKCS12");
        public static final BString CLIENT_KEYSTORE_URL = StringUtils.fromString("clientCertificateKeyStoreUrl");
        public static final BString CLIENT_KEYSTORE_PASSWORD = StringUtils.fromString("clientCertificateKeyStorePassword");
        public static final BString CLIENT_KEYSTORE_TYPE = StringUtils.fromString("clientCertificateKeyStoreType");
        public static final BString TRUST_KEYSTORE_URL = StringUtils.fromString("trustCertificateKeyStoreUrl");
        public static final BString TRUST_KEYSTORE_PASSWORD = StringUtils.fromString("trustCertificateKeyStorePassword");
        public static final BString TRUST_KEYSTORE_TYPE = StringUtils.fromString("trustCertificateKeyStoreType");

        public static final BString DB_METADATA_CACHE_FIELDS = StringUtils.fromString("databaseMetadataCacheFields");
        public static final BString DB_METADATA_CACHE_FIELDS_MIB = StringUtils.fromString("databaseMetadataCacheFieldsMiB");
        public static final BString PREPARE_THRESHOLD = StringUtils.fromString("prepareThreshold");
        public static final BString PREPARED_STATEMENT_CACHE_QUERIES = StringUtils.
                            fromString("preparedStatementCacheQueries");
        public static final BString PREPARED_STATEMENT_CACHE_SIZE_MIB = StringUtils.
                            fromString("preparedStatementCacheSizeMiB");
        public static final BString CANCEL_SIGNAL_TIMEOUT = StringUtils.fromString("cancelSignalTimeout");
        public static final BString TCP_KEEP_ALIVE = StringUtils.fromString("tcpKeepAlive");
        public static final BString CONNECT_TIMEOUT = StringUtils.fromString("connectTimeout");
        public static final BString SOCKET_TIMEOUT = StringUtils.fromString("socketTimeout");
        public static final BString LOGIN_TIMEOUT = StringUtils.fromString("loginTimeout");
        public static final BString ROW_FETCH_SIZE = StringUtils.fromString("defaultRowFetchSize");

    }

    public static final String MSSQL_DATASOURCE_NAME = "com.microsoft.sqlserver.jdbc.SQLServerXADataSource";
    public static final String MSSQL_XA_DATASOURCE_NAME = "com.microsoft.sqlserver.jdbc.SQLServerXADataSource";
    static final String FILE = "file:";
    public static final String POOL_CONNECT_TIMEOUT = "ConnectionTimeout";
}