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

# MsSQL Geometric Data types.

## Represents Point MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class PointValue {
    public Point | string? value;
    public isolated function init(Point | string? value = ()) {
        self.value =value;
    }
}

## Represents LineString MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class LineStringValue {
    public LineString | string? value;
    public isolated function init(LineString | string? value = ()) {
        self.value =value;
    }
}

## Represents CircularString MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class CircularStringValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents CompoundCurve MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class CompoundCurveValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents Polygon MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class PolygonValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents MultiPolygon MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class MultiPolygonValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents CurvePolygon MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class CurvePolygonValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents MultiLineString MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class MultiLineStringValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents MultiPoint MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class MultiPointValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

## Represents GeometryCollection MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class GeometryCollectionValue {
    public string? value;
    public isolated function init(string? value = ()) {
        self.value =value;
    }
}

# MsSQL Money Data types.

# Represents Money MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class MoneyValue {
    public decimal|float|string? value;
    public isolated function init(decimal|float|string? value = ()) {
        self.value = value;
    }  
}

# Represents Smallmoney MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class SmallMoneyValue {
    public decimal|float|string? value;
    public isolated function init(decimal|float|string? value = ()) {
        self.value = value;
    }  
}

# Represents Point Datatype in MsSQL.
#
# + x - The x Cordinate of the Point
# + y - The y Cordinate of the Point
public type Point record {
    decimal x;
    decimal y;
};

# Represents LineString Datatype in MsSQL.
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
