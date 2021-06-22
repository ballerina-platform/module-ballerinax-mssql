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
import io.ballerina.runtime.api.values.BObject;
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
    public static Geometry convertPoint(Object value, Object srid) throws ApplicationError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (TypeUtils.getType(value).getTag() == TypeTags.RECORD_TYPE_TAG) {
            Map<String, Object> pointValue = getRecordData(value);
            String pointText = getPointText(pointValue);
            wkt = String.format("POINT (%s)", pointText);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: Point");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertLineString(Object value, Object srid) throws SQLException, ApplicationError {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String lineStringText = getLineStringText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("LINESTRING (%s)", lineStringText);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: LineString");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertCircularString(Object value, Object srid) throws ApplicationError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String circularStringText = getCircularStringText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("CIRCULARSTRING (%s)", circularStringText);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: Circular String");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertCompoundCurve(Object value, Object srid) throws ApplicationError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String compoundCurveText = getCompoundCurveText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("COMPOUNDCURVE (%s)", compoundCurveText);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: Compound Curve");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertPolygon(Object value, Object srid) throws ApplicationError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String polygonText = getPolygonText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("POLYGON (%s)", polygonText);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: Polygon");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertCurvePolygon(Object value, Object srid) throws ApplicationError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String curvePolygonText = getCurvePolygonText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("CURVEPOLYGON (%s)", curvePolygonText);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: CurvePolygon");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertMultiPoint(Object value, Object srid) throws SQLException, ApplicationError {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String multiPointText = getMultiPointText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("MULTIPOINT (%s)", String.join(", ", multiPointText));
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: LineString");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertMultiLineString(Object value, Object srid) throws SQLException, ApplicationError {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String multiLineStringText = getMultiLineStringText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("MULTILINESTRING (%s)", multiLineStringText);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: LineString");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertMultiPolygon(Object value, Object srid) throws SQLException, ApplicationError {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String multiPolygonTest = getMultiPolygonText(((BArray) value).getValues(), ((BArray) value).size());
            wkt = String.format("MULTIPOLYGON (%s)", multiPolygonTest);
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: MultiPolygon");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertGeometryString(Object value, Object srid) throws SQLException, ApplicationError {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            int numPoints = ((BArray) value).size();
            Object[] elements = ((BArray) value).getValues();
            String[] stringElements = new String[numPoints];

            // Convert array of geometry instances into an array of strings
            for (int i = 0; i < numPoints; i++) {
                BObject element = (BObject) elements[i];

                if (element instanceof BString) {
                    stringElements[i] = element.toString();
                    continue;
                }

                if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.POINT)) {
                    Map<String, Object> pointValue = getRecordData(
                            element.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE));
                    String pointText = getPointText(pointValue);
                    stringElements[i] = String.format("POINT (%s)", pointText);
                    continue;
                }

                BArray elementArray = (BArray) element.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE);
                Object[] arrayValues = elementArray.getValues();
                int arraySize = elementArray.size();

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.LINESTRING)) {
                    String lineStringText = getLineStringText(arrayValues, arraySize);
                    stringElements[i] = String.format("LINESTRING (%s)", lineStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.CIRCULARSTRING)) {
                    String circularStringText = getCircularStringText(arrayValues, arraySize);
                    stringElements[i] = String.format("CIRCULARSTRING (%s)", circularStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.COMPOUNDCURVE)) {
                    String circularStringText = getCompoundCurveText(arrayValues, arraySize);
                    stringElements[i] = String.format("COMPOUNDCURVE (%s)", circularStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.POLYGON)) {
                    String polygonText = getPolygonText(arrayValues, arraySize);
                    stringElements[i] = String.format("POLYGON (%s)", polygonText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.CURVEPOLYGON)) {
                    String curvePolygonText = getCurvePolygonText(arrayValues, arraySize);
                    stringElements[i] = String.format("CURVEPOLYGON (%s)", curvePolygonText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.MULTIPOINT)) {
                    String multiPointText = getMultiPointText(arrayValues, arraySize);
                    stringElements[i] = String.format("MULTIPOINT (%s)", multiPointText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.MULTILINESTRING)) {
                    String multiLineStringText = getMultiLineStringText(arrayValues, arraySize);
                    stringElements[i] = String.format("MULTILINESTRING (%s)", multiLineStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.MULTIPOLYGON)) {
                    String multiPolygonText = getMultiPolygonText(arrayValues, arraySize);
                    stringElements[i] = String.format("MULTIPOLYGON (%s)", multiPolygonText);
                    continue;
                }

                throw new SQLException("Unsupported Value: " + value + " for type: GeometryCollection");
            }

            // Combine all elements into a geometry collection
            wkt = String.format("GEOMETRYCOLLECTION (%s)", String.join(", ", stringElements));
        } else {
            throw new SQLException("Unsupported Value: " + value + " for type: GeometryCollection");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
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

    protected static Object getArrayData(Field field, Object bValue) throws ApplicationError {
        Type elementType = ((ArrayType) field.getFieldType()).getElementType();
        if (elementType.getTag() == TypeTags.BYTE_TAG) {
            return ((BArray) bValue).getBytes();
        } else {
            throw new ApplicationError("unsupported data type for array specified for struct parameter");
        }
    }

    protected static String getPointText(Map<String, Object> pointValue) {
        double x = ((BDecimal) pointValue.get(Constants.Geometric.X)).decimalValue().doubleValue();
        double y = ((BDecimal) pointValue.get(Constants.Geometric.Y)).decimalValue().doubleValue();

        if (pointValue.get(Constants.Geometric.Z) != null && pointValue.get(Constants.Geometric.M) != null) {
            double z = ((BDecimal) pointValue.get(Constants.Geometric.Z)).decimalValue().doubleValue();
            double m = ((BDecimal) pointValue.get(Constants.Geometric.M)).decimalValue().doubleValue();
            return String.format("%f %f %f %f", x, y, z, m);
        } else {
            return String.format("%f %f", x, y);
        }
    }

    protected static String getLineStringText(Object[] points, int numPoints) throws ApplicationError {
        String[] pointStrings = new String[numPoints];

        // Convert array of points into an array of strings
        for (int i = 0; i < numPoints; i++) {
            Map<String, Object> pointValue = getRecordData(points[i]);
            pointStrings[i] = getPointText(pointValue);
        }
        // Combine all points into a line string
        return String.join(", ", pointStrings);
    }

    protected static String getCircularStringText(Object[] elements, int numElements)
            throws ApplicationError, SQLException {
        //Determine whether the value is an array of points, or an array of arc segments
        boolean isPointArray;
        Object element = elements[0];
        Map<String, Object> arrayElementValue = getRecordData(element);
        if (arrayElementValue.containsKey(Constants.Geometric.X) &&
                arrayElementValue.containsKey(Constants.Geometric.Y)) {
            isPointArray = true;
        } else if (arrayElementValue.containsKey(Constants.Geometric.START) &&
                arrayElementValue.containsKey(Constants.Geometric.END) &&
                arrayElementValue.containsKey(Constants.Geometric.CONTROL)) {
            isPointArray = false;
        } else {
            throw new SQLException("Unsupported value: " + element + " for type: CompoundCurve");
        }

        if (isPointArray) {
            String[] pointStrings = new String[numElements];
            //Convert array of points into an array of strings
            for (int i = 0; i < numElements; i++) {
                Map<String, Object> pointValue = getRecordData(elements[i]);
                pointStrings[i] = getPointText(pointValue);
            }
            // Combine all points into a line string
            return String.join(", ", pointStrings);
        } else {
            // Number of points = number of arc segments * 2 + 1
            String[] pointStrings = new String[(numElements * 2) + 1];
            Map<String, Object> prevEndPointValue = null;
            for (int i = 0; i < numElements; i++) {
                Map<String, Object> arcSegmentValue = getRecordData(elements[i]);
                Map<String, Object> startPointValue =
                        (Map<String, Object>) arcSegmentValue.get(Constants.Geometric.START);
                Map<String, Object> endPointValue =
                        (Map<String, Object>) arcSegmentValue.get(Constants.Geometric.END);
                Map<String, Object> controlPointValue =
                        (Map<String, Object>) arcSegmentValue.get(Constants.Geometric.CONTROL);

                // Check whether the start point value of the current arc segment is the same as the end point of
                // the previous arc segment.
                if (prevEndPointValue != null && !(startPointValue.equals(prevEndPointValue))) {
                    throw new ApplicationError(
                            "Start and end points of arc segments should be the same for a Circular String.");
                }

                pointStrings[i * 2] = getPointText(startPointValue);
                pointStrings[(i * 2) + 1] = getPointText(controlPointValue);

                prevEndPointValue = endPointValue;
            }

            // Add the end point of the final arc segment.
            pointStrings[numElements * 2] = getPointText(prevEndPointValue);
            return String.join(", ", pointStrings);
        }
    }

    protected static String getCompoundCurveText(Object[] elements, int numElements) 
            throws ApplicationError, SQLException {
        String[] stringElements = new String[numElements];
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE);

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

    protected static String getCurvePolygonText(Object[] elements, int numElements)
            throws ApplicationError, SQLException {
        String[] stringElements = new String[numElements];
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE);

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

    protected static String getPolygonText(Object[] elements, int numElements)
            throws ApplicationError, SQLException {
        String[] stringElements = new String[numElements];
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.LINESTRING)) {
                BArray elementArray = (BArray) element.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE);
                String lineStringText = getLineStringText(elementArray.getValues(), elementArray.size());
                stringElements[i] = String.format("(%s)", lineStringText);
                continue;
            }

            throw new SQLException("Unsupported Value: " + element + " for type: Polygon");
        }
        return String.join(", ", stringElements);
    }

    protected static String getMultiPointText(Object[] elements, int numElements)
            throws ApplicationError {
        String[] stringElements = new String[numElements];

        // Convert array of points into an array of strings
        for (int i = 0; i < numElements; i++) {
            Map<String, Object> pointValue = getRecordData(elements[i]);
            stringElements[i] = String.format("(%s)", getPointText(pointValue));
        }
        // Combine all points into a multi-point
        return String.join(", ", stringElements);
    }

    protected static String getMultiLineStringText(Object[] elements, int numElements)
            throws ApplicationError, SQLException {
        String[] stringElements = new String[numElements];

        // Convert array of lines into an array of strings
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE);
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

    protected static String getMultiPolygonText(Object[] elements, int numElements)
            throws ApplicationError, SQLException {
        String[] stringElements = new String[numElements];

        // Convert array of polygons into an array of strings
        for (int i = 0; i < numElements; i++) {
            BObject element = (BObject) elements[i];

            if (element instanceof BString) {
                stringElements[i] = element.toString();
                continue;
            }

            BArray elementArray = (BArray) element.get(org.ballerinalang.sql.Constants.TypedValueFields.VALUE);
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
