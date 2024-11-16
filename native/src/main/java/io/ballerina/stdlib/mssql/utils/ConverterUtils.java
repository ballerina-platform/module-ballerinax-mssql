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

package io.ballerina.stdlib.mssql.utils;

import com.microsoft.sqlserver.jdbc.Geometry;
import io.ballerina.runtime.api.types.TypeTags;
import io.ballerina.runtime.api.utils.TypeUtils;
import io.ballerina.runtime.api.values.BArray;
import io.ballerina.runtime.api.values.BDecimal;
import io.ballerina.runtime.api.values.BObject;
import io.ballerina.runtime.api.values.BString;
import io.ballerina.stdlib.mssql.Constants;
import io.ballerina.stdlib.sql.exception.DataError;
import io.ballerina.stdlib.sql.exception.TypeMismatchError;

import java.sql.SQLException;
import java.util.Map;

/**
 * This class implements the utils methods for the MSSQL Datatypes.
 *
 * @since 0.1.0
 */
public class ConverterUtils {
    public static Geometry convertPoint(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (TypeUtils.getType(value).getTag() == TypeTags.RECORD_TYPE_TAG) {
            Map<String, Object> pointValue = ConversionHelperUtils.getRecordData(value);
            String pointText = ConversionHelperUtils.getPointText(pointValue);
            wkt = String.format("POINT (%s)", pointText);
        } else {
            throw new TypeMismatchError("Point", value.getClass().getSimpleName(),
                    "record{}");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertLineString(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String lineStringText = ConversionHelperUtils.getLineStringText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("LINESTRING (%s)", lineStringText);
        } else {
            throw new TypeMismatchError("LineString", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertCircularString(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String circularStringText = ConversionHelperUtils.getCircularStringText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("CIRCULARSTRING (%s)", circularStringText);
        } else {
            throw new TypeMismatchError("Circular String", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertCompoundCurve(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String compoundCurveText = ConversionHelperUtils.getCompoundCurveText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("COMPOUNDCURVE (%s)", compoundCurveText);
        } else {
            throw new TypeMismatchError("Compound Curve", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertPolygon(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String polygonText = ConversionHelperUtils.getPolygonText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("POLYGON (%s)", polygonText);
        } else {
            throw new TypeMismatchError("Polygon", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertCurvePolygon(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String curvePolygonText = ConversionHelperUtils.getCurvePolygonText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("CURVEPOLYGON (%s)", curvePolygonText);
        } else {
            throw new TypeMismatchError("CurvePolygon", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertMultiPoint(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String multiPointText = ConversionHelperUtils.getMultiPointText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("MULTIPOINT (%s)", String.join(", ", multiPointText));
        } else {
            throw new TypeMismatchError("LineString", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertMultiLineString(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String multiLineStringText = ConversionHelperUtils.getMultiLineStringText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("MULTILINESTRING (%s)", multiLineStringText);
        } else {
            throw new TypeMismatchError("LineString", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertMultiPolygon(Object value, Object srid) throws DataError, SQLException {
        String wkt;
        if (value instanceof BString) {
            wkt = value.toString();
        } else if (value instanceof BArray) {
            String multiPolygonTest = ConversionHelperUtils.getMultiPolygonText(((BArray) value).getValues(),
                    ((BArray) value).size());
            wkt = String.format("MULTIPOLYGON (%s)", multiPolygonTest);
        } else {
            throw new TypeMismatchError("MultiPolygon", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Geometry convertGeometryString(Object value, Object srid) throws DataError, SQLException {
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
                Object elementValue = element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);

                if (elementValue instanceof BString) {
                    stringElements[i] = elementValue.toString();
                    continue;
                }

                if (element.getClass().getName().contains("$" + Constants.CustomTypeNames.POINT)) {
                    Map<String, Object> pointValue = ConversionHelperUtils.getRecordData(
                            element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE));
                    String pointText = ConversionHelperUtils.getPointText(pointValue);
                    stringElements[i] = String.format("POINT (%s)", pointText);
                    continue;
                }

                BArray elementArray = (BArray) element.get(io.ballerina.stdlib.sql.Constants.TypedValueFields.VALUE);
                Object[] arrayValues = elementArray.getValues();
                int arraySize = elementArray.size();

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.LINESTRING)) {
                    String lineStringText = ConversionHelperUtils.getLineStringText(arrayValues, arraySize);
                    stringElements[i] = String.format("LINESTRING (%s)", lineStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.CIRCULARSTRING)) {
                    String circularStringText = ConversionHelperUtils.getCircularStringText(arrayValues, arraySize);
                    stringElements[i] = String.format("CIRCULARSTRING (%s)", circularStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.COMPOUNDCURVE)) {
                    String circularStringText = ConversionHelperUtils.getCompoundCurveText(arrayValues, arraySize);
                    stringElements[i] = String.format("COMPOUNDCURVE (%s)", circularStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.POLYGON)) {
                    String polygonText = ConversionHelperUtils.getPolygonText(arrayValues, arraySize);
                    stringElements[i] = String.format("POLYGON (%s)", polygonText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.CURVEPOLYGON)) {
                    String curvePolygonText = ConversionHelperUtils.getCurvePolygonText(arrayValues, arraySize);
                    stringElements[i] = String.format("CURVEPOLYGON (%s)", curvePolygonText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.MULTIPOINT)) {
                    String multiPointText = ConversionHelperUtils.getMultiPointText(arrayValues, arraySize);
                    stringElements[i] = String.format("MULTIPOINT (%s)", multiPointText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.MULTILINESTRING)) {
                    String multiLineStringText = ConversionHelperUtils.getMultiLineStringText(arrayValues, arraySize);
                    stringElements[i] = String.format("MULTILINESTRING (%s)", multiLineStringText);
                    continue;
                }

                if (element.getClass().getName().endsWith("$" + Constants.CustomTypeNames.MULTIPOLYGON)) {
                    String multiPolygonText = ConversionHelperUtils.getMultiPolygonText(arrayValues, arraySize);
                    stringElements[i] = String.format("MULTIPOLYGON (%s)", multiPolygonText);
                    continue;
                }

                throw new TypeMismatchError("GeometryCollection", value.getClass().getSimpleName(),
                        new String[]{"string", Constants.CustomTypeNames.POINT, Constants.CustomTypeNames.LINESTRING,
                                Constants.CustomTypeNames.CIRCULARSTRING, Constants.CustomTypeNames.COMPOUNDCURVE,
                                Constants.CustomTypeNames.POLYGON, Constants.CustomTypeNames.CURVEPOLYGON,
                                Constants.CustomTypeNames.MULTIPOINT, Constants.CustomTypeNames.MULTILINESTRING,
                                Constants.CustomTypeNames.MULTIPOLYGON});
            }
            // Combine all elements into a geometry collection
            wkt = String.format("GEOMETRYCOLLECTION (%s)", String.join(", ", stringElements));
        } else {
            throw new TypeMismatchError("GeometryCollection", value.getClass().getSimpleName(),
                    "Array");
        }

        int sridInt = 0;
        if (srid != null) {
            sridInt = ((Long) srid).intValue();
        }

        return Geometry.STGeomFromText(wkt, sridInt);
    }

    public static Object convertMoney(Object value) throws DataError {
        Object money;
        if (value instanceof BString) {
            money = value.toString();
        } else if (value instanceof BDecimal) {
            money = ((BDecimal) value).decimalValue().doubleValue();
        } else if (value instanceof Double) {
            money = value;
        } else {
            throw new TypeMismatchError("Money", value.getClass().getSimpleName(),
                    new String[]{"string", "decimal", "double"});
        }
        return money;
    }

}
