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

package org.ballerinalang.mssql.utils;

import com.microsoft.sqlserver.jdbc.Geometry;
import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.types.ArrayType;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.StructureType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BString;
import org.ballerinalang.mssql.Constants;
import org.ballerinalang.sql.exception.ApplicationError;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
* This class implements the utils methods for the MSSQL Datatypes.
*
* @since 0.1.0
*/
public class ConverterUtils {
    public static Geometry convertPoint(Object value) throws ApplicationError, SQLException {
        Geometry point;
        Map<String, Object> pointValue = getRecordData(value);
        double x = ((BDecimal) pointValue.get(Constants.Geometric.X)).decimalValue().doubleValue();
        double y = ((BDecimal) pointValue.get(Constants.Geometric.Y)).decimalValue().doubleValue();
        int srid = 0;
        if (pointValue.get(Constants.Geometric.SRID) != null) {
            srid = ((Long) pointValue.get(Constants.Geometric.SRID)).intValue();
        }
        point = Geometry.point(x, y, srid);
        return point;
    }

    public static Geometry convertLineString(Object value) throws ApplicationError, SQLException {
        Geometry lineString;
        if (value instanceof BString) {
            try {
                lineString = Geometry.STGeomFromText(value.toString(), 0);
            } catch (SQLException ex) {
                throw new SQLException("Unsupported Value: " + value + " for type: " + "linestring");
            }
        } else {
            Map<String, Object> lineStringValue = getRecordData(value);
            double x1 = ((BDecimal) lineStringValue.get(Constants.Geometric.X1)).decimalValue().doubleValue();
            double y1 = ((BDecimal) lineStringValue.get(Constants.Geometric.Y1)).decimalValue().doubleValue();
            double x2 = ((BDecimal) lineStringValue.get(Constants.Geometric.X2)).decimalValue().doubleValue();
            double y2 = ((BDecimal) lineStringValue.get(Constants.Geometric.Y2)).decimalValue().doubleValue();
            lineString = Geometry.STGeomFromText("LINESTRING (" + x1 + " " + y1 + ", " + x2 + " " + y2 + ")", 0);
        }
        return lineString;
    }    

    public static Object convertMoney(Object value) throws SQLException {
        Object money;
        if (value instanceof BString) {
            money = value.toString();
        } else if (value instanceof BDecimal) {
            money = ((BDecimal) value).decimalValue().doubleValue();
        } else if (value instanceof Double) {
            money = value;
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: " + "money");
        }
        return money;
    }

    public static Geometry convertGeometryString(Object value) throws SQLException {
        Geometry geometryString;
        if (value instanceof BString) {
            try {
                geometryString = Geometry.STGeomFromText(value.toString(), 0);
            } catch (SQLException ex) {
                throw new SQLException("Unsupported Value: " + value + " for type: " + "geometry");
            }
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: " + "geometry");
        }
        return geometryString;
    }

    private static Map<String, Object> getRecordData(Object value) throws ApplicationError {
        Type type = TypeUtils.getType(value);
        Map<String, Field> structFields = ((StructureType) type).getFields();
        int fieldCount = structFields.size();
        Iterator<Field> fieldIterator = structFields.values().iterator();
        HashMap<String, Object> structData = new HashMap<>();
        for (int i = 0; i < fieldCount; i++) {
            Field field = fieldIterator.next();
            Object bValue = ((BMap) value).get(fromString(field.getFieldName()));
            int typeTag = field.getFieldType().getTag();
            switch (typeTag) {
                case TypeTags.INT_TAG:
                case TypeTags.FLOAT_TAG:
                case TypeTags.STRING_TAG:
                case TypeTags.BOOLEAN_TAG:
                case TypeTags.DECIMAL_TAG:
                    structData.put(field.getFieldName(), bValue);
                    break;
                case TypeTags.ARRAY_TAG:
                    structData.put(field.getFieldName(), getArrayData(field, bValue));
                    break;
                case TypeTags.RECORD_TYPE_TAG:
                    structData.put(field.getFieldName(), getRecordData(bValue));
                    break;
                default:
                    break;
            }
        }
        return structData;
    }

     protected static Object getArrayData(Field field, Object bValue)
            throws ApplicationError {
        Type elementType = ((ArrayType) field.getFieldType()).getElementType();
        if (elementType.getTag() == TypeTags.BYTE_TAG) {
            return ((BArray) bValue).getBytes();
        } else {
            throw new ApplicationError("unsupported data type for array specified for struct parameter");
        }
    }
}
