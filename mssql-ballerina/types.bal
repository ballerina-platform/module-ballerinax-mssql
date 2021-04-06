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

// import ballerina/jballerina.java;
// import ballerina/sql;

## Represents Point MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class PointValue {
    public Point | string? value;

    public function init(Point | string? value = ()) {
        self.value =value;
    }
}

## Represents LineString MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class LineStringValue {
    public LineString | string? value;

    public function init(LineString | string? value = ()) {
        self.value =value;
    }
}

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

public type Point record {
    decimal x;
    decimal y;
};

public type LineString record {
    decimal x1;
    decimal y1;
    decimal x2;
    decimal y2;
};
