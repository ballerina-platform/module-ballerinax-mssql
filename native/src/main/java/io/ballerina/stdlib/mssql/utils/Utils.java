/*
 *  Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  WSO2 Inc. licenses this file to you under the Apache License,
 *  Version 2.0 (the "License"); you may not use this file except
 *  in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */
package io.ballerina.stdlib.mssql.utils;

import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mssql.Constants;

/**
 * This class includes utility functions.
 *
 * @since 1.2.0
 */
public class Utils {

    public static BMap populateProperties(BMap options, BMap mssqlOptions) {

        if (mssqlOptions != null) {
            addSSLOptions(mssqlOptions.getMapValue(Constants.Options.SECURE_SOCKET), options);

            long queryTimeout = getTimeout(mssqlOptions.get(Constants.Options.QUERY_TIMEOUT_SECONDS));
            if (queryTimeout > 0) {
                options.put(Constants.DatabaseProps.QUERY_TIMEOUT, queryTimeout);
            }

            long socketTimeout = getTimeout(mssqlOptions.get(Constants.Options.SOCKET_TIMEOUT_SECONDS));
            if (socketTimeout > 0) {
                options.put(Constants.DatabaseProps.SOCKET_TIMEOUT, socketTimeout);
            }

            long loginTimeout = getTimeout(mssqlOptions.get(Constants.Options.LOGIN_TIMEOUT_SECONDS));
            if (loginTimeout > 0) {
                options.put(Constants.DatabaseProps.LOGIN_TIMEOUT, loginTimeout);
            }

            return options;
        }
        return null;
    }

    private static int getBooleanValue(Object value) {
        if (value instanceof Boolean) {
            if (((Boolean) value)) {
                return 1;
            }
            return 0;
        }
        return -1;
    }

    private static long getTimeout(Object secondsDecimal) {
        if (secondsDecimal instanceof BDecimal) {
            BDecimal timeoutSec = (BDecimal) secondsDecimal;
            if (((BDecimal) secondsDecimal).floatValue() > 0) {
                return Double.valueOf(timeoutSec.floatValue() * 1000).longValue();
            }
        }
        return -1;
    }

    private static void addSSLOptions(BMap sslConfig, BMap<BString, Object> options) {
        if (sslConfig != null) {

            int encrypt = getBooleanValue(sslConfig.get(Constants.SSLConfig.ENCRYPT));
            if (encrypt == 1) {
                options.put(Constants.DatabaseProps.ENCRYPT, true);
            }
            
            int trustServerCertificate = getBooleanValue(sslConfig.get(Constants.SSLConfig.TRUST_SERVER_CERTIFICATE));
            if (trustServerCertificate == 1) {
                options.put(Constants.DatabaseProps.TRUST_SERVER_CERTIFICATE, true);
            }

            BMap trustCertKeystore = sslConfig.getMapValue(Constants.SSLConfig.CLIENT_CERT);
            if (trustCertKeystore != null) {
                options.put(Constants.DatabaseProps.TRUSTSTORE_LOCATION,
                        trustCertKeystore.getStringValue(
                                Constants.SSLConfig.CryptoTrustStoreRecord.TRUSTSTORE_RECORD_PATH_FIELD));
                options.put(Constants.DatabaseProps.TRUSTSTORE_PASSWORD,
                        trustCertKeystore.getStringValue(
                                Constants.SSLConfig.CryptoTrustStoreRecord.TRUSTSTORE_RECORD_PASSWORD_FIELD));
                }

            BMap clientCertKeystore = sslConfig.getMapValue(Constants.SSLConfig.CLIENT_KEY);
            if (clientCertKeystore != null) {
                options.put(Constants.DatabaseProps.KEYSTORE_AUTHENTICATION,
                        Constants.SSLConfig.JAVA_KEYSTORE_PASSWORD);
                options.put(Constants.DatabaseProps.KEYSTORE_LOCATION,
                        clientCertKeystore.getStringValue(
                                Constants.SSLConfig.CryptoKeyStoreRecord.KEYSTORE_RECORD_PATH_FIELD));
                options.put(Constants.DatabaseProps.KEYSTORE_PASSWORD,
                        clientCertKeystore.getStringValue(
                                Constants.SSLConfig.CryptoKeyStoreRecord.KEYTSTORE_RECORD_PASSWORD_FIELD));
            }
        }
    }
}
