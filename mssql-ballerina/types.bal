// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;

# MSSQL Geometric Data types.

## Represents Point MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class PointValue {
    *sql:TypedValue;
    public Point | string? value;
    
    public isolated function init(Point | string? value = ()) {
        self.value =value;
    }
}

## Represents LineString MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class LineStringValue {
    *sql:TypedValue;
    public LineString | string? value;

    public isolated function init(LineString | string? value = ()) {
        self.value =value;
    }
}

## Represents CircularString MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class CircularStringValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents CompoundCurve MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class CompoundCurveValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents Polygon MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class PolygonValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents MultiPolygon MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class MultiPolygonValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents CurvePolygon MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class CurvePolygonValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents MultiLineString MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class MultiLineStringValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents MultiPoint MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class MultiPointValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents GeometryCollection MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class GeometryCollectionValue {
    *sql:TypedValue;
    public string? value;

    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

# MSSQL Money Data types.

# Represents Money MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class MoneyValue {
    *sql:TypedValue;
    public decimal|float|string? value;

    public isolated function init(decimal|float|string? value = ()) {
        self.value = value;
    }  
}

# Represents Smallmoney MSSQL Field
#
# + value - Value of parameter passed into the SQL statement
public distinct class SmallMoneyValue {
    *sql:TypedValue;
    public decimal|float|string? value;

    public isolated function init(decimal|float|string? value = ()) {
        self.value = value;
    }  
}

# Represents Point Datatype in MSSQL.
#
# + x - The x Cordinate of the Point
# + y - The y Cordinate of the Point
public type Point record {
    decimal x;
    decimal y;
};

# Represents LineString Datatype in MSSQL.
#
# + x1 - The x cordinate of the first point of the line segment
# + y1 - The y cordinate of the first point of the line segment
# + x2 - The x cordinate of the second point of the line segment
# + y2 - The y cordinate of the second point of the line segment
public type LineString record {
    decimal x1;
    decimal y1;
    decimal x2;
    decimal y2;
};
