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
import ballerinax/cdc;

# Represents the data query modes for SQL Server CDC.
public enum DataQueryMode {
    FUNCTION = "function",
    DIRECT = "direct"
}

# Represents the source struct version for SQL Server connector.
public enum SourceStructVersion {
    V1 = "v1",
    V2 = "v2"
}

# Represents the MSSQL Point type parameter in the `sql:ParameterizedQuery`.
#
# + x - The x coordinate of the point
# + y - The y coordinate of the point
public type Point record {
    decimal x;
    decimal y;
};

# Represents an element (LineString or Circular String) of a MSSQL Compound Curve type.
#
public type CompoundCurveElement LineStringValue | CircularStringValue;

# Represents the MSSQL circular arc ring (LineString, Circular String or Compound Curve) type.
#
public type CircularArcRing LineStringValue | CircularStringValue | CompoundCurveValue;

# Represents an element of an MSSQL Geometry Collection type.
#
public type GeometryCollectionElement PointValue | LineStringValue | CircularStringValue | CompoundCurveValue |
                                      PolygonValue | CurvePolygonValue | MultiPointValue | MultiLineStringValue |
                                      MultiPolygonValue;

# Represents the MSSQL Point type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class PointValue {
    *sql:TypedValue;
    public Point|string? value;
    public int? srid = ();
    
    public isolated function init(Point|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL MultiPoint type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class MultiPointValue {
    *sql:TypedValue;
    public Point[]|string? value;
    public int? srid = ();

    public isolated function init(Point[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL LineString type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class LineStringValue {
    *sql:TypedValue;
    public Point[]|string? value;
    public int? srid = ();

    public isolated function init(Point[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL MultiLineString type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class MultiLineStringValue {
    *sql:TypedValue;
    public LineStringValue[]|string? value;
    public int? srid = ();

    public isolated function init(LineStringValue[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL CircularString type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class CircularStringValue {
    *sql:TypedValue;
    public Point[]|string? value;
    public int? srid = ();

    public isolated function init(Point[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL CompoundCurve type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class CompoundCurveValue {
    *sql:TypedValue;
    public CompoundCurveElement[]|string? value;
    public int? srid = ();

    public isolated function init(CompoundCurveElement[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL Polygon type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class PolygonValue {
    *sql:TypedValue;
    public LineStringValue[]|string? value;
    public int? srid = ();

    public isolated function init(LineStringValue[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL MultiPolygon type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class MultiPolygonValue {
    *sql:TypedValue;
    public PolygonValue[]|string? value;
    public int? srid = ();

    public isolated function init(PolygonValue[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL CurvePolygon type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class CurvePolygonValue {
    *sql:TypedValue;
    public CircularArcRing[]|string? value;
    public int? srid = ();

    public isolated function init(CircularArcRing[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL GeometryCollection type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
# + srid - The spatial reference ID of the instance
public distinct class GeometryCollectionValue {
    *sql:TypedValue;
    public GeometryCollectionElement[]|string? value;
    public int? srid = ();

    public isolated function init(GeometryCollectionElement[]|string? value = (), int? srid = ()) {
        self.value = value;
        self.srid = srid;
    }
}

# Represents the MSSQL Money type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
public distinct class MoneyValue {
    *sql:TypedValue;
    public decimal|float|string? value;

    public isolated function init(decimal|float|string? value = ()) {
        self.value = value;
    }  
}

# Represents the MSSQL Smallmoney type parameter in the `sql:ParameterizedQuery`.
#
# + value - Value of the parameter
public distinct class SmallMoneyValue {
    *sql:TypedValue;
    public decimal|float|string? value;

    public isolated function init(decimal|float|string? value = ()) {
        self.value = value;
    }  
}

# Represents SQL Server-specific advanced configuration options.
#
# + databaseEncrypt - Whether to encrypt the connection to SQL Server
# + databaseSslTruststore - Path to the truststore file for SSL connections
# + databaseSslTruststorePassword - Password for the truststore file
# + dataQueryMode - Mode for querying CDC data (function or direct)
# + streamingDelayMs - Delay in milliseconds before starting streaming after snapshot
# + streamingFetchSize - Number of rows to fetch per database round-trip during streaming
# + maxIterationTransactions - Maximum number of transactions to process per iteration
# + sourceStructVersion - Version of the source struct (v1 or v2)
# + incrementalSnapshotOptionRecompile - Whether to use OPTION(RECOMPILE) for incremental snapshot queries
public type MsSqlAdvancedConfiguration record {|
    boolean databaseEncrypt = false;
    string databaseSslTruststore?;
    string databaseSslTruststorePassword?;
    DataQueryMode dataQueryMode = FUNCTION;
    int streamingDelayMs = 0;
    int streamingFetchSize = 10000;
    int maxIterationTransactions = 500;
    SourceStructVersion sourceStructVersion = V2;
    boolean incrementalSnapshotOptionRecompile = false;
|};

# Represents relational database common configuration options.
# These properties are applicable to all relational databases (MySQL, PostgreSQL, SQL Server).
#
# + schemaIncludeList - List of schemas to include (comma-separated regular expressions)
# + schemaExcludeList - List of schemas to exclude (comma-separated regular expressions)
# + messageKeyColumns - Custom message key columns (format: schemaName.tableName:keyColumn1,keyColumn2)
public type RelationalCommonConfiguration record {|
    string|string[] schemaIncludeList?;
    string|string[] schemaExcludeList?;
    string|string[] messageKeyColumns?;
|};

# SQL Server CDC listener configuration including database connection, storage, and CDC options.
#
# + database - SQL Server database connection and capture settings
# + engineName - Unique name for the CDC engine instance
# + internalSchemaStorage - Schema history storage backend (file, Kafka, memory, JDBC, Redis, S3, Azure Blob, RocketMQ)
# + offsetStorage - Offset storage backend for tracking connector progress (file, Kafka, memory, JDBC, Redis)
# + options - SQL Server-specific CDC options including snapshot, heartbeat, signals, and data type handling
public type MsSqlListenerConfiguration record {|
    MsSqlDatabaseConnection database;
    *cdc:ListenerConfiguration;
    MssqlOptions options = {};
|};

# SQL Server-specific CDC options for configuring snapshot behavior and data type handling.
#
# + extendedSnapshot - Extended snapshot configuration with SQL Server-specific lock timeout and query settings
# + dataTypeConfig - Data type handling configuration including schema change tracking
public type MssqlOptions record {|
    *cdc:Options;
    ExtendedSnapshotConfiguration extendedSnapshot?;
    DataTypeConfiguration dataTypeConfig?;
|};

# Represents the extended snapshot configuration for the SQL Server CDC listener.
# 
# + lockTimeout - Lock acquisition timeout in seconds
public type ExtendedSnapshotConfiguration record {|
    *cdc:RelationalExtendedSnapshotConfiguration;
    decimal lockTimeout = 10;
|};

# Represents the configuration for the MSSQL CDC database connection.
#
# + connectorClass - The class name of the MSSQL connector implementation to use
# + hostname - The hostname of the MSSQL server
# + port - The port number of the MSSQL server
# + databaseInstance - The name of the database instance
# + databaseNames - A list of database names to capture changes from
# + includedSchemas - A list of regular expressions matching fully-qualified schema identifiers to capture changes from
# + excludedSchemas - A list of regular expressions matching fully-qualified schema identifiers to exclude from change capture
# + tasksMax - The maximum number of tasks to create for this connector. If the `databaseNames` contains more than one element, you can increase the value of this property to a number less than or equal to the number of elements in the list
# + mssqlAdvancedConfig - SQL Server-specific advanced configuration options
# + relationalCommonConfig - Relational database common configuration options (applicable to MySQL, PostgreSQL, SQL Server)
public type MsSqlDatabaseConnection record {|
    *cdc:DatabaseConnection;
    string connectorClass = "io.debezium.connector.sqlserver.SqlServerConnector";
    string hostname = "localhost";
    int port = 1433;
    string databaseInstance?;
    string|string[] databaseNames;
    string|string[] includedSchemas?;
    string|string[] excludedSchemas?;
    int tasksMax = 1;
    MsSqlAdvancedConfiguration mssqlAdvancedConfig?;
    RelationalCommonConfiguration relationalCommonConfig?;
|};

# Represents data type handling configuration.
#
# + includeSchemaChanges - Whether to include schema change events
public type DataTypeConfiguration record {|
    *cdc:DataTypeConfiguration;
    boolean includeSchemaChanges = true;
|};
