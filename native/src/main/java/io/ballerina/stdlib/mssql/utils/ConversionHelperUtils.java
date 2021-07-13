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

import io.ballerina.runtime.api.TypeTags;
import io.ballerina.runtime.api.types.Field;
import io.ballerina.runtime.api.types.StructureType;
import io.ballerina.runtime.api.types.Type;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BMap;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mssql.Constants;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static io.ballerina.runtime.api.utils.StringUtils.fromString;

/**
 * This class includes helper functions for custom MSSQL-Ballerina datatypes.
 *
 */
public class ConversionHelperUtils {

    private ConversionHelperUtils() {

    }

    public static Map<String, Object> getRecordData(Object value) {
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
                case TypeTags.RECORD_TYPE_TAG:
                    structData.put(field.getFieldName(), getRecordData(bValue));
                    break;
                default:
                    break;
            }
        }
        return structData;
    }

    protected static String getPointText(Map<String, Object> pointValue) {
        double x = ((BDecimal) pointValue.get(Constants.Geometric.X)).decimalValue().doubleValue();
        double y = ((BDecimal) pointValue.get(Constants.Geometric.Y)).decimalValue().doubleValue();
        return String.format("%f %f", x, y);
    }

    protected static String getLineStringText(Object[] points, int numPoints) {
        String[] pointStrings = new String[numPoints];

        // Convert array of points into an array of strings
        for (int i = 0; i < numPoints; i++) {
            Map<String, Object> pointValue = getRecordData(points[i]);
            pointStrings[i] = getPointText(pointValue);
        }
        // Combine all points into a line string
        return String.join(", ", pointStrings);
    }

    protected static String getCircularStringText(Object[] elements, int numElements) {
        String[] pointStrings = new String[numElements];
        //Convert array of points into an array of strings
        for (int i = 0; i < numElements; i++) {
            Map<String, Object> pointValue = getRecordData(elements[i]);
            pointStrings[i] = getPointText(pointValue);
        }
        // Combine all points into a line string
        return String.join(", ", pointStrings);
    }

    protected static String getCompoundCurveText(Object[] elements, int numElements) throws SQLException {
        String[] stringElements = new String[numElements];
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);

            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.LINESTRING)) {
                String lineStringText = getLineStringText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("(%s)", lineStringText);
                continue;
            }

            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.CIRCULARSTRING)) {
                String circularStringText = getCircularStringText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("CIRCULARSTRING (%s)", circularStringText);
                continue;
            }

            throw new SQLException("Unsupported value: " + element + " for type: CompoundCurve");

        }
        return String.join(", ", stringElements);
    }

    protected static String getCurvePolygonText(Object[] elements, int numElements) throws SQLException {
        String[] stringElements = new String[numElements];
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);

            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.LINESTRING)) {
                String lineStringText = getLineStringText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("(%s)", lineStringText);
                continue;
            }

            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.CIRCULARSTRING)) {
                String circularStringText = getCircularStringText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("CIRCULARSTRING (%s)", circularStringText);
                continue;
            }

            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.COMPOUNDCURVE)) {
                String circularStringText = getCompoundCurveText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("COMPOUNDCURVE (%s)", circularStringText);
                continue;
            }

            throw new SQLException("Unsupported Value: " + element + " for type: Compound Curve");

        }
        return String.join(", ", stringElements);
    }

    protected static String getPolygonText(Object[] elements, int numElements) throws SQLException {
        String[] stringElements = new String[numElements];
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.LINESTRING)) {
                BArray elementArray = (BArray) element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);
                String lineStringText = getLineStringText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("(%s)", lineStringText);
                continue;
            }

            throw new SQLException("Unsupported Value: " + element + " for type: Polygon");
        }
        return String.join(", ", stringElements);
    }

    protected static String getMultiPointText(Object[] elements, int numElements) {
        String[] stringElements = new String[numElements];

        // Convert array of points into an array of strings
        for (int i = 0; i < numElements; i++) {
            Map<String, Object> pointValue = getRecordData(elements[i]);
            stringElements[i] = String.format("(%s)", getPointText(pointValue));
        }
        // Combine all points into a multi-point
        return String.join(", ", stringElements);
    }

    protected static String getMultiLineStringText(Object[] elements, int numElements) throws SQLException {
        String[] stringElements = new String[numElements];

        // Convert array of lines into an array of strings
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);
            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.LINESTRING)) {
                String lineStringText = getLineStringText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("(%s)", lineStringText);
                continue;
            }
            throw new SQLException("Unsupported Value: " + element + " for type: Compound Curve");
        }
        // Combine all lines into a multi-line
        return String.join(", ", stringElements);
    }

    protected static String getMultiPolygonText(Object[] elements, int numElements) throws SQLException {
        String[] stringElements = new String[numElements];

        // Convert array of polygons into an array of strings
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);
            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.POLYGON)) {
                String polygonText = getPolygonText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("(%s)", polygonText);
                continue;
            }
            throw new SQLException("Unsupported Value: " + element + " for type: MultiPolygon");
        }
        // Combine all polygons into a multi-polygon
        return String.join(", ", stringElements);
    }

}
