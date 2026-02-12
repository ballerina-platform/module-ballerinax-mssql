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

isolated function populateMsSqlAdvancedConfiguration(MsSqlAdvancedConfiguration? config, map<string> configMap) {
    if config is () {
        return;
    }

    configMap[MSSQL_DATABASE_ENCRYPT] = config.databaseEncrypt.toString();

    if config.databaseSslTruststore !is () {
        configMap[DATABASE_SSL_TRUSTSTORE] = config.databaseSslTruststore ?: "";
    }

    if config.databaseSslTruststorePassword !is () {
        configMap[DATABASE_SSL_TRUSTSTORE_PASSWORD] = config.databaseSslTruststorePassword ?: "";
    }

    configMap[DATA_QUERY_MODE] = config.dataQueryMode.toString();
    configMap[STREAMING_DELAY_MS] = config.streamingDelayMs.toString();
    configMap[STREAMING_FETCH_SIZE] = config.streamingFetchSize.toString();
    configMap[MAX_ITERATION_TRANSACTIONS] = config.maxIterationTransactions.toString();
    configMap[SOURCE_STRUCT_VERSION] = config.sourceStructVersion.toString();
    configMap[INCREMENTAL_SNAPSHOT_OPTION_RECOMPILE] = config.incrementalSnapshotOptionRecompile.toString();
}

isolated function populateRelationalCommonConfiguration(RelationalCommonConfiguration? config, map<string> configMap) {
    if config is () {
        return;
    }

    // Note: schemaIncludeList and schemaExcludeList are already handled by populateSchemaConfigurations
    // from the top-level includedSchemas/excludedSchemas fields for backward compatibility

    if config.messageKeyColumns !is () {
        string|string[] keyColumns = config.messageKeyColumns ?: "";
        configMap[MESSAGE_KEY_COLUMNS] = keyColumns is string ? keyColumns : string:'join(";", ...keyColumns);
    }
}

isolated function populateMsSqlConfigurations(MsSqlDatabaseConnection connection, map<string> configMap) {
    if connection.databaseInstance !is () {
        configMap[MSSQL_DATABASE_INSTANCE] = connection.databaseInstance ?: "";
    }

    string|string[] databaseNames = connection.databaseNames;
    configMap[MSSQL_DATABASE_NAMES] = databaseNames is string ? databaseNames : string:'join(",", ...databaseNames);

    populateSchemaConfigurations(connection, configMap);

    // Set default encryption to false if no advanced config provided
    if connection.secure is () && connection.mssqlAdvancedConfig is () {
        configMap[MSSQL_DATABASE_ENCRYPT] = "false";
    }

    // Populate SQL Server-specific advanced configuration
    populateMsSqlAdvancedConfiguration(connection.mssqlAdvancedConfig, configMap);

    // Populate relational-common configuration
    populateRelationalCommonConfiguration(connection.relationalCommonConfig, configMap);
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
    cdc:populateOptions(options, configMap);

    // Populate MSSQL-specific extended snapshot configuration
    ExtendedSnapshotConfiguration? extendedSnapshot = options.extendedSnapshot;
    if extendedSnapshot is ExtendedSnapshotConfiguration {
        cdc:populateRelationalExtendedSnapshotConfiguration(extendedSnapshot, configMap);
        populateMsSqlExtendedSnapshotConfiguration(extendedSnapshot, configMap);
    }

    // Populate MSSQL-specific data type configuration
    DataTypeConfiguration? dataTypeConfig = options.dataTypeConfig;
    if dataTypeConfig is DataTypeConfiguration {
        cdc:populateDataTypeConfiguration(dataTypeConfig, configMap);
        configMap[INCLUDE_SCHEMA_CHANGES] = dataTypeConfig.includeSchemaChanges.toString();
    }
}

// Populates MSSQL-specific extended snapshot properties
isolated function populateMsSqlExtendedSnapshotConfiguration(ExtendedSnapshotConfiguration config, map<string> configMap) {
    configMap[SNAPSHOT_LOCK_TIMEOUT_MS] = getMillisecondValueOf(config.lockTimeout);
}

isolated function getMillisecondValueOf(decimal value) returns string {
    string milliSecondVal = (value * 1000).toBalString();
    return milliSecondVal.substring(0, milliSecondVal.indexOf(".") ?: milliSecondVal.length());
}
