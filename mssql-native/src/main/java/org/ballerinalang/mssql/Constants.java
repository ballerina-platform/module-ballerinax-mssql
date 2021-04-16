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
        public static final BString INSTANCE = StringUtils.fromString("instance");
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
        public static final BString SECURESOCKET = StringUtils.fromString("secureSocket");
        public static final BString SOCKET_TIMEOUT_SECONDS = StringUtils.fromString("socketTimeout");
        public static final BString QUERY_TIMEOUT_SECONDS = StringUtils.fromString("queryTimeout");
        public static final BString LOGIN_TIMEOUT_SECONDS = StringUtils.fromString("loginTimeout");
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

    /**
    * Constants for MsSQLGeometric datatypes.
    */
    public static final class Geometric {
        public static final String X = "x";
        public static final String Y = "y";
        public static final String X1 = "x1";
        public static final String Y1 = "y1";
        public static final String X2 = "x2";
        public static final String Y2 = "y2";
    }

    /**
    * Constants for Mssql Ballerina datatypes names.
    */
    public static final class CustomTypeNames {
        public static final String POINT = "PointValue";
        public static final String LINESTRING = "LineStringValue";
        public static final String CIRCULARSTRING = "CircularStringValue";
        public static final String COMPOUNDCURVE = "CompoundCurveValue";
        public static final String POLYGON = "PolygonValue";
        public static final String CURVEPOLYGON = "CurvePolygonValue";
        public static final String MULTIPOLYGON = "MultiPolygonValue";
        public static final String MULTILINESTRING = "MultiLineStringValue";
        public static final String MULTIPOINT = "MultiPointValue";
        public static final String GEOMETRYCOLLECTION = "GeometryCollectionValue";
        public static final String MONEY = "MoneyValue";
        public static final String SMALLMONEY = "SmallMoneyValue";
    }

    public static final String MSSQL_DATASOURCE_NAME = "com.microsoft.sqlserver.jdbc.SQLServerDataSource";
    public static final String POOL_CONNECT_TIMEOUT = "ConnectionTimeout";
}
