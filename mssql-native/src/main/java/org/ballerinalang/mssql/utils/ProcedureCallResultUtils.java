package org.ballerinalang.mssql.utils;

import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.mssql.parameterprocessor.MssqlResultParameterProcessor;

public class ProcedureCallResultUtils {
    public static Object getNextQueryResult(BObject procedureCallResultset, BObject procedureCallResult) {
        System.out.println("\nMssql RecordIteratorUtilsn procedureCallResult" + procedureCallResult);
        return org.ballerinalang.sql.utils.ProcedureCallResultUtils.getNextQueryResult(procedureCallResult, 
                        MssqlResultParameterProcessor.getInstance());
    }
}
