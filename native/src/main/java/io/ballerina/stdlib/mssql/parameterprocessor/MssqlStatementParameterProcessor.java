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

package io.ballerina.stdlib.mssql.parameterprocessor;

import com.microsoft.sqlserver.jdbc.Geometry;
import com.microsoft.sqlserver.jdbc.SQLServerPreparedStatement;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.stdlib.mssql.Constants;
import io.ballerina.stdlib.mssql.utils.ConverterUtils;
import io.ballerina.stdlib.sql.exception.DataError;
import io.ballerina.stdlib.sql.exception.UnsupportedTypeError;
import io.ballerina.stdlib.sql.parameterprocessor.DefaultStatementParameterProcessor;

import java.math.BigDecimal;
import java.math.MathContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

/**
 * This class overrides DefaultStatementParameterProcessor to implement methods required to convert ballerina types
 * into SQL types and other methods that process the parameters of the result.
 *
 * @since 0.1.0
 */
public class MssqlStatementParameterProcessor extends DefaultStatementParameterProcessor {

    private static final MssqlStatementParameterProcessor instance = new MssqlStatementParameterProcessor();

    /**
    * Singleton static method that returns an instance of `MssqlStatementParameterProcessor`.
    * @return MssqlStatementParameterProcessor
    */
    public static MssqlStatementParameterProcessor getInstance() {
        return instance;
    }

    // The MSSQL JDBC driver builds the batch cache key from preparedTypeDefinitions
    // (e.g. "decimal(38,S)") where S = BigDecimal.scale(). Varying scales across rows produce
    // different cache keys, forcing sp_prepexec (re-prepare + plan recompile) per row instead
    // of the cheap sp_execute reuse. Using setObject with an explicit fixed minimum scale pins
    // the type definition to a single stable string for all rows. Values with a larger natural
    // scale keep it (no truncation); values below the minimum are zero-padded (lossless).
    private static final int MSSQL_BATCH_DECIMAL_SCALE = 10;

    private void setMssqlDecimalParam(PreparedStatement preparedStatement, int index, Object value, int jdbcType)
            throws SQLException, DataError {
        if (value == null) {
            // setNull leaves Parameter.scale=0 ("decimal(38,0)"); setObject with explicit scale
            // keeps null rows consistent with non-null rows in the type definition.
            preparedStatement.setObject(index, null, jdbcType, MSSQL_BATCH_DECIMAL_SCALE);
        } else if (value instanceof BDecimal) {
            BigDecimal bd = ((BDecimal) value).decimalValue();
            int scale = Math.max(bd.scale(), MSSQL_BATCH_DECIMAL_SCALE);
            preparedStatement.setObject(index, bd.setScale(scale), jdbcType, scale);
        } else if (value instanceof Double || value instanceof Long) {
            preparedStatement.setBigDecimal(index, new BigDecimal(((Number) value).doubleValue(),
                    MathContext.DECIMAL64));
        } else if (value instanceof Integer || value instanceof Float) {
            preparedStatement.setBigDecimal(index, new BigDecimal(((Number) value).doubleValue(),
                    MathContext.DECIMAL32));
        } else {
            throw new UnsupportedTypeError("DECIMAL", index);
        }
    }

    @Override
    protected void setNumeric(PreparedStatement preparedStatement, String sqlType, int index, Object value)
            throws DataError, SQLException {
        setMssqlDecimalParam(preparedStatement, index, value, Types.NUMERIC);
    }

    @Override
    protected void setDecimal(PreparedStatement preparedStatement, String sqlType, int index, Object value)
            throws DataError, SQLException {
        setMssqlDecimalParam(preparedStatement, index, value, Types.DECIMAL);
    }

    @Override
    public int setSQLValueParam(Connection connection, PreparedStatement preparedStatement,
                                int index, Object object, boolean returnType)
            throws DataError, SQLException {
        if (object == null) {
            // Types.NULL (=0) is unknown to the MSSQL JDBC driver, which omits
            // the parameter from preparedTypeDefinitions, breaking the sp_execute cache key
            // and forcing sp_prepexec (re-prepare) on every batch row. Types.VARCHAR gives
            // the driver a known type so it can build a stable cache key for sp_execute reuse.
            // SQL Server inserts NULL into any nullable column regardless of this type hint.
            preparedStatement.setNull(index, Types.VARCHAR);
            return Types.VARCHAR;
        }
        return super.setSQLValueParam(connection, preparedStatement, index, object, returnType);
    }

    @Override
    protected void setCustomSqlTypedParam(Connection connection, PreparedStatement preparedStatement,
                                          int index, BObject typedValue)
            throws SQLException, DataError {
        String sqlType = TypeUtils.getType(typedValue).getName();
        Object value = typedValue.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);
        switch (sqlType) {
            case Constants.CustomTypeNames.POINT:
                setPoint(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.LINESTRING:
                setLineString(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.CIRCULARSTRING:
                setCircularString(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.COMPOUNDCURVE:
                setCompoundCurve(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.POLYGON:
                setPolygon(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.CURVEPOLYGON:
                setCurvePolygon(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.MULTIPOLYGON:
                setMultiPolygon(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.MULTIPOINT:
                setMultiPoint(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.MULTILINESTRING:
                setMultiLineString(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.GEOMETRYCOLLECTION:
                setGeometryString(preparedStatement, index, value, typedValue.get(Constants.TypedValueFields.SRID));
                break;
            case Constants.CustomTypeNames.MONEY:
            case Constants.CustomTypeNames.SMALLMONEY:
                setMoney(preparedStatement, index, value);
                break;
            default:
                throw new UnsupportedTypeError(sqlType, index);
        }
    }

    private void setPoint(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertPoint(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setLineString(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertLineString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setCircularString(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertCircularString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setCompoundCurve(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertCompoundCurve(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setPolygon(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertPolygon(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setCurvePolygon(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertCurvePolygon(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMultiPoint(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertMultiPoint(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMultiLineString(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertMultiLineString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMultiPolygon(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertMultiPolygon(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setGeometryString(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertGeometryString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMoney(PreparedStatement preparedStatement, int index, Object value)
        throws DataError, SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Object object = ConverterUtils.convertMoney(value);
            preparedStatement.setObject(index, object);
        }
    }
}
