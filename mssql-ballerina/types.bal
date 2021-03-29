// import ballerina/jballerina.java;
// import ballerina/sql;

## Represents Point MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class PointValue {
    public PointRecordType | string? value;

    public function init(PointRecordType | string? value = ()) {
        self.value =value;
    }
}

## Represents LineString MsSQL Field
#
# + value - Value of parameter passed into the SQL statement
public class LineStringValue {
    public LineStringRecordType | string? value;

    public function init(LineStringRecordType | string? value = ()) {
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

public type PointRecordType record {
    decimal x;
    decimal y;
};

public type LineStringRecordType record {
    decimal x1;
    decimal y1;
    decimal x2;
    decimal y2;
};
