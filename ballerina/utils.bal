// Copyright (c) 2025, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerinax/cdc;

const string SCHEMA_INCLUDE_LIST = "schema.include.list";
const string SCHEMA_EXCLUDE_LIST = "schema.exclude.list";

const string MSSQL_DATABASE_NAMES = "database.names";
const string MSSQL_DATABASE_INSTANCE = "database.instance";
const string MSSQL_DATABASE_ENCRYPT = "database.encrypt";

// SQL Server-specific advanced configuration properties
const string DATABASE_SSL_TRUSTSTORE = "database.ssl.truststore";
const string DATABASE_SSL_TRUSTSTORE_PASSWORD = "database.ssl.truststore.password";
const string DATA_QUERY_MODE = "data.query.mode";
const string STREAMING_DELAY_MS = "streaming.delay.ms";
const string STREAMING_FETCH_SIZE = "streaming.fetch.size";
const string MAX_ITERATION_TRANSACTIONS = "max.iteration.transactions";
const string SOURCE_STRUCT_VERSION = "source.struct.version";
const string INCREMENTAL_SNAPSHOT_OPTION_RECOMPILE = "incremental.snapshot.option.recompile";

// Relational-common configuration properties (applicable to MySQL, PostgreSQL, SQL Server)
const string MESSAGE_KEY_COLUMNS = "message.key.columns";

// Populates SQL Server connection configuration
isolated function populateConnectionConfiguration(ConnectionConfiguration config, map<string> configMap) {
    configMap[MSSQL_DATABASE_ENCRYPT] = config.encrypt.toString();

    string? sslTruststore = config.sslTruststore;
    if sslTruststore !is () {
        configMap[DATABASE_SSL_TRUSTSTORE] = sslTruststore;
    }

    string? sslTruststorePassword = config.sslTruststorePassword;
    if sslTruststorePassword !is () {
        configMap[DATABASE_SSL_TRUSTSTORE_PASSWORD] = sslTruststorePassword;
    }
}

// Populates SQL Server streaming configuration
isolated function populateStreamingConfiguration(StreamingConfiguration config, map<string> configMap) {
    configMap[DATA_QUERY_MODE] = config.dataQueryMode.toString();
    configMap[STREAMING_DELAY_MS] = config.streamingDelayMs.toString();
    configMap[STREAMING_FETCH_SIZE] = config.streamingFetchSize.toString();
    configMap[MAX_ITERATION_TRANSACTIONS] = config.maxIterationTransactions.toString();
}

// Populates SQL Server schema configuration
isolated function populateSchemaConfiguration(SchemaConfiguration config, map<string> configMap) {
    configMap[SOURCE_STRUCT_VERSION] = config.sourceStructVersion.toString();
}

isolated function populateMsSqlConfigurations(MsSqlDatabaseConnection connection, map<string> configMap) {
    string? databaseInstance = connection.databaseInstance;
    if databaseInstance !is () {
        configMap[MSSQL_DATABASE_INSTANCE] = databaseInstance;
    }

    string|string[] databaseNames = connection.databaseNames;
    configMap[MSSQL_DATABASE_NAMES] = databaseNames is string ? databaseNames : string:'join(",", ...databaseNames);

    populateSchemaConfigurations(connection, configMap);

    // Populate SQL Server connection configuration
    populateConnectionConfiguration(connection.connectionConfig, configMap);

    // Populate SQL Server streaming configuration
    populateStreamingConfiguration(connection.streamingConfig, configMap);

    // Populate SQL Server schema configuration
    populateSchemaConfiguration(connection.schemaConfig, configMap);
}

// Populates schema inclusion/exclusion configurations
isolated function populateSchemaConfigurations(MsSqlDatabaseConnection connection, map<string> configMap) {
    string|string[]? includedSchemas = connection.includedSchemas;
    if includedSchemas !is () {
        configMap[SCHEMA_INCLUDE_LIST] = includedSchemas is string ? includedSchemas : string:'join(",", ...includedSchemas);
    }

    string|string[]? excludedSchemas = connection.excludedSchemas;
    if excludedSchemas !is () {
        configMap[SCHEMA_EXCLUDE_LIST] = excludedSchemas is string ? excludedSchemas : string:'join(",", ...excludedSchemas);
    }
}

const string SNAPSHOT_LOCK_TIMEOUT_MS = "snapshot.lock.timeout.ms";
const string INCLUDE_SCHEMA_CHANGES = "include.schema.changes";

// Populates MSSQL-specific options
isolated function populateMsSqlOptions(MssqlOptions options, map<string> configMap) {
    // Populate common options from cdc module
    cdc:populateOptions(options, configMap, typeof options);

    // Populate MSSQL-specific extended snapshot configuration
    ExtendedSnapshotConfiguration? extendedSnapshot = options.extendedSnapshot;
    if extendedSnapshot is ExtendedSnapshotConfiguration {
        cdc:populateRelationalExtendedSnapshotConfiguration(extendedSnapshot, configMap);
        populateMsSqlExtendedSnapshotConfiguration(extendedSnapshot, configMap);
    }

    // Populate MSSQL-specific data type configuration
    DataTypeConfiguration? dataTypeConfig = options.dataTypeConfig;
    if dataTypeConfig is DataTypeConfiguration {
        populateDataTypeConfiguration(dataTypeConfig, configMap);
    }
}

// Populates MSSQL-specific data type configuration
isolated function populateDataTypeConfiguration(DataTypeConfiguration config, map<string> configMap) {
    // Populate generic data type options
    cdc:populateDataTypeConfiguration(config, configMap);

    // Populate MSSQL-specific data type options
    configMap[INCLUDE_SCHEMA_CHANGES] = config.includeSchemaChanges.toString();
}

// Populates MSSQL-specific extended snapshot properties
isolated function populateMsSqlExtendedSnapshotConfiguration(ExtendedSnapshotConfiguration config, map<string> configMap) {
    configMap[SNAPSHOT_LOCK_TIMEOUT_MS] = getMillisecondValueOf(config.lockTimeout);
    configMap[INCREMENTAL_SNAPSHOT_OPTION_RECOMPILE] = config.incrementalSnapshotOptionRecompile.toString();
}

isolated function getMillisecondValueOf(decimal value) returns string {
    string milliSecondVal = (value * 1000).toBalString();
    return milliSecondVal.substring(0, milliSecondVal.indexOf(".") ?: milliSecondVal.length());
}
