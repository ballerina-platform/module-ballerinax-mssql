/*
 *  Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
package org.ballerinalang.mssql;

import io.ballerina.runtime.api.creators.ValueCreator;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;

import org.ballerinalang.mssql.Constants;

/**
 * This class includes utility functions.
 *
 * @since 1.2.0
 */
public class Utils {

    public static BMap generateOptionsMap(BMap mssqlOptions) {
        if (mssqlOptions != null) {
            BMap<BString, Object> options = ValueCreator.createMapValue();    
            addSSLOptions(mssqlOptions.getMapValue(Constants.Options.SSL), options);

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
            if (((Boolean) value) == true) {
                return 1;
            }
            return 0;
        }
        return -1;
    }

    private static long getTimeout(Object secondsInt) {
        if (secondsInt instanceof Long) {
            Long timeoutSec = (Long) secondsInt;
            if (timeoutSec.longValue() > 0) {
                return Long.valueOf(timeoutSec.longValue() * 1000).longValue();
            }
        }
        return -1;
    }

    private static void addSSLOptions(BMap sslConfig, BMap<BString, Object> options) {
        if (sslConfig != null) {
            int encrypt = getBooleanValue(sslConfig.get(Constants.SSLConfig.ENCRYPT));
            if (encrypt == 1) {
                options.put(Constants.SSLConfig.ENCRYPT,encrypt);
            }
            
            int trustServerCertificate = getBooleanValue(sslConfig.get(Constants.SSLConfig.TRUST_SERVER_CERTIFICATE));
            if (trustServerCertificate == 1) {
                options.put(Constants.SSLConfig.TRUST_SERVER_CERTIFICATE,trustServerCertificate);
            }
            // Boolean encrypt = sslConfig.getBooleanValue(Constants.SSLConfig.ENCRYPT);
            // if (encrypt == true) {
            //     options.put(Constants.SSLConfig.ENCRYPT,encrypt);
            // }
            
            // Boolean trustServerCertificate = sslConfig.getBooleanValue(Constants.SSLConfig.TRUST_SERVER_CERTIFICATE);
            // if (trustServerCertificate == true) {
            //     options.put(Constants.SSLConfig.TRUST_SERVER_CERTIFICATE,trustServerCertificate);
            // }
        
            BString trustStore = sslConfig.getStringValue(Constants.SSLConfig.TRUST_STORE);
            if(trustStore != null){
                options.put(Constants.SSLConfig.TRUST_STORE,trustStore);
            }

            BString trustStorePassword = sslConfig.getStringValue(Constants.SSLConfig.TRUST_STORE_PASSWORD);
            if(trustStorePassword != null){
                options.put(Constants.SSLConfig.TRUST_STORE_PASSWORD,trustStorePassword);
            }

        }
    }
}
