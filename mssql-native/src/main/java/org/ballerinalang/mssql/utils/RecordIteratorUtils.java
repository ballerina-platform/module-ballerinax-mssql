package org.ballerinalang.mssql.utils;

import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.mssql.parameterprocessor.MssqlResultParameterProcessor;

public class RecordIteratorUtils {
    public static Object nextResult(BObject mssqlRecordIterator, BObject recordIterator) {
        System.out.println("\nMssql RecordIteratorUtilsn");
        return org.ballerinalang.sql.utils.RecordIteratorUtils.nextResult(recordIterator, 
                        MssqlResultParameterProcessor.getInstance());
    }
}
