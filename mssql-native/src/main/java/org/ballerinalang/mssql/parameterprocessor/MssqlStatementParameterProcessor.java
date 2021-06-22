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

package org.ballerinalang.mssql.parameterprocessor;

import com.microsoft.sqlserver.jdbc.Geometry;
import com.microsoft.sqlserver.jdbc.SQLServerPreparedStatement;
import io.ballerina.runtime.api.values.BObject;
import org.ballerinalang.mssql.Constants;
import org.ballerinalang.mssql.utils.ConverterUtils;
import org.ballerinalang.sql.exception.ApplicationError;
import org.ballerinalang.sql.parameterprocessor.DefaultStatementParameterProcessor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

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

    @Override
    protected void setCustomSqlTypedParam(Connection connection, PreparedStatement preparedStatement,
                                          int index, BObject typedValue)
            throws SQLException, ApplicationError {
        String sqlType = typedValue.getType().getName();
        Object value = typedValue.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE);
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
                throw new ApplicationError("Unsupported SQL type: " + sqlType);
        }
    }

    private void setPoint(PreparedStatement preparedStatement, int index, Object value, Object srid)
        throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertPoint(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setLineString(PreparedStatement preparedStatement, int index, Object value, Object srid)
        throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertLineString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setCircularString(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertCircularString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setCompoundCurve(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertCompoundCurve(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setPolygon(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertPolygon(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setCurvePolygon(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertCurvePolygon(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMultiPoint(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertMultiPoint(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMultiLineString(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertMultiLineString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMultiPolygon(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertMultiPolygon(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setGeometryString(PreparedStatement preparedStatement, int index, Object value, Object srid)
            throws SQLException, ApplicationError {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Geometry object = ConverterUtils.convertGeometryString(value, srid);
            SQLServerPreparedStatement sqlServerStatement = preparedStatement.unwrap(SQLServerPreparedStatement.class);
            sqlServerStatement.setGeometry(index, object);
        }
    }

    private void setMoney(PreparedStatement preparedStatement, int index, Object value)
        throws SQLException {
        if (value == null) {
            preparedStatement.setObject(index, null);
        } else {
            Object object = ConverterUtils.convertMoney(value);
            preparedStatement.setObject(index, object);
        }
    }
}
