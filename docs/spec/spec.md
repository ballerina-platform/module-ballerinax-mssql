# Specification: Ballerina MSSQL Library

_Owners_: @niveathika @aashikam @shafreenAnfar  
_Reviewers_:  
_Created_: 2022/01/14  
_Updated_: 2026/11/26  
_Edition_: Swan Lake  

## Introduction

This is the specification for the MSSQL connector of the [Ballerina language](https://ballerina.io/), `ballerinax/mssql`, which provides a client for Microsoft SQL Server databases and a change data capture (CDC) listener for them.

This specification is the contract of the library. It defines the observable behaviour of the library: the configuration it accepts, how it connects to SQL Server, how it binds and converts values where it differs from the `ballerina/sql` library, the errors it returns, what it rejects at compile time, and the CDC listener. A behaviour of the implementation that differs from this specification is a bug in the implementation. A behaviour that this specification does not define is a gap in the specification, and is also reported as a bug. Signatures and per-symbol documentation are part of the [API documentation](https://central.ballerina.io/ballerinax/mssql/latest), and usage examples are part of [Ballerina by Example](https://ballerina.io/learn/by-example/). Neither is repeated here.

The client is a connector of the `ballerina/sql` library. The behaviour of its operations is specified by the [SQL library specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md), called the *core specification* in this document. This specification states only what the connector adds to the core specification and where it differs from it, as permitted by the core [connector contract](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#17-connector-contract). The behaviour of the CDC listener and its services is specified by the [CDC library specification](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md); this specification states the SQL Server-specific configuration.

The released versions of the specification can be found under the relevant GitHub tag. Changes to the specification follow the proposal process described in the [library development process](https://github.com/ballerina-platform/ballerina-library/blob/main/docs/library-development-process.md). If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-library/issues) or in the [Discord server](https://discord.gg/ballerinalang).

### Notation

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals. Sentences in the present tense that state behaviour are also normative. Examples, notes and the overview are informative. Behaviour marked _implementation-defined_ is chosen and documented by the implementation; behaviour marked _unspecified_ must not be relied on.

A reference of the form "core §n" refers to section n of the core specification. A core table row is identified by the value of its first cell, as described in core [§17.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#171-description). A reference of the form "CDC §n" refers to section n of the [CDC library specification](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md).

## Contents

- [1. Overview](#1-overview)
- [2. Terminology](#2-terminology)
- [3. Client](#3-client)
    - [3.1. Description](#31-description)
    - [3.2. Configuration](#32-configuration)
    - [3.3. Connection](#33-connection)
    - [3.4. Operations](#34-operations)
    - [3.5. Compile-time validation](#35-compile-time-validation)
    - [3.6. Errors](#36-errors)
- [4. Connection options](#4-connection-options)
    - [4.1. Description](#41-description)
    - [4.2. Configuration](#42-configuration)
    - [4.3. Driver properties](#43-driver-properties)
    - [4.4. XA data source](#44-xa-data-source)
    - [4.5. Compile-time validation](#45-compile-time-validation)
    - [4.6. Errors](#46-errors)
    - [4.7. Interactions](#47-interactions)
- [5. SSL/TLS](#5-ssltls)
    - [5.1. Description](#51-description)
    - [5.2. Configuration](#52-configuration)
    - [5.3. Behaviour](#53-behaviour)
    - [5.4. Errors](#54-errors)
- [6. Parameter binding](#6-parameter-binding)
    - [6.1. Description](#61-description)
    - [6.2. Binding of core values](#62-binding-of-core-values)
    - [6.3. Geometry values](#63-geometry-values)
    - [6.4. Money values](#64-money-values)
    - [6.5. Errors](#65-errors)
    - [6.6. Interactions](#66-interactions)
- [7. Execute and generated keys](#7-execute-and-generated-keys)
    - [7.1. Description](#71-description)
    - [7.2. Behaviour](#72-behaviour)
    - [7.3. Errors](#73-errors)
- [8. Stored procedure calls](#8-stored-procedure-calls)
    - [8.1. Description](#81-description)
    - [8.2. Behaviour](#82-behaviour)
    - [8.3. Errors](#83-errors)
- [9. Result mapping](#9-result-mapping)
    - [9.1. Description](#91-description)
    - [9.2. SQL Server types](#92-sql-server-types)
    - [9.3. Errors](#93-errors)
- [10. Observability](#10-observability)
    - [10.1. Description](#101-description)
    - [10.2. Metric tags](#102-metric-tags)
- [11. CDC listener](#11-cdc-listener)
    - [11.1. Description](#111-description)
    - [11.2. Configuration](#112-configuration)
    - [11.3. Behaviour](#113-behaviour)
    - [11.4. Errors](#114-errors)
    - [11.5. Interactions](#115-interactions)
- [12. Connector contract](#12-connector-contract)
    - [12.1. Description](#121-description)
    - [12.2. Obligations](#122-obligations)
    - [12.3. Override points](#123-override-points)
- [13. Security considerations](#13-security-considerations)
- [14. Planned changes](#14-planned-changes)
- [References](#references)

## 1. Overview

The library provides two public classes:

- `mssql:Client`, a client of the `ballerina/sql` library for SQL Server. It supports the `query`, `queryRow`, `execute`, `batchExecute` and `call` operations and the `close` method of `sql:Client`, connection pooling, transactions and pool metrics as specified by the core specification. The library adds the connection configuration of SQL Server, typed values for the SQL Server `geometry`, `money` and `smallmoney` types, and SQL Server-specific binding of `()` and exact numeric values.
- `mssql:CdcListener`, a listener of the `ballerinax/cdc` library that captures row changes of SQL Server tables through the Debezium SQL Server connector.

The library does not contain a JDBC driver. A program that uses the client provides the Microsoft JDBC Driver for SQL Server, for example by importing `ballerinax/mssql.driver`. A program that uses the listener provides the Debezium SQL Server connector, for example by importing `ballerinax/mssql.cdc.driver`.

## 2. Terminology

- **Core specification**: the [SQL library specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md).
- **Core library**: the `ballerina/sql` library, specified by the core specification. "The library" without qualification is `ballerinax/mssql`.
- **Driver**: the Microsoft JDBC Driver for SQL Server that the program provides. Behaviour described as *driver-defined* is determined by the driver version in use.
- **Connection URL**: the JDBC URL the client builds from its configuration ([§3.3](#33-connection)).
- **Driver property**: a connection property of the driver, set by the client as an entry of the driver options map of core [§4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation), step 7.
- **WKT**: the Well-Known Text representation of a geometry, such as `POINT (1 2)`.
- **Debezium property**: a configuration property of the Debezium engine or of the Debezium SQL Server connector, set by the CDC listener ([§11](#11-cdc-listener)).

## 3. Client

### 3.1. Description

`mssql:Client` is an isolated client class that includes `sql:Client`. Its initializer connects to a SQL Server database, and its operations behave as specified in the core specification, with the differences stated in this document.

### 3.2. Configuration

The initializer takes the following parameters, in this order. All of them have defaults.

| Parameter | Type | Default | Meaning |
|---|---|---|---|
| `host` | `string` | `"localhost"` | Host name or IP address of the server. |
| `user` | `string?` | `"sa"` | Login name. `()` means that no user is given to the driver. The default is the system administrator login of SQL Server ([§13](#13-security-considerations), rule 4). |
| `password` | `string?` | `()` | Password of `user`. `()` means that no password is given to the driver. |
| `database` | `string?` | `()` | Database to connect to. `()` and `""` mean that no database is requested, so the connection uses the default database of the login. |
| `port` | `int` | `1433` | TCP port of the server. A value greater than `0` is used as the port. `0` or a negative value means that no port is given, so the driver looks up the port of `instance` through the SQL Server Browser service. A value above `65535` makes the initializer return an `sql:ApplicationError` ([§3.3](#33-connection), rule 8). |
| `instance` | `string` | `""` | Name of a named instance. It is used only when no port is given; see rules 1 and 7 of [§3.3](#33-connection). |
| `options` | `mssql:Options?` | `()` | Connection options ([§4](#4-connection-options)). `()` is equivalent to an `mssql:Options` value with every optional field absent. |
| `connectionPool` | `sql:ConnectionPool?` | `()` | Pool configuration (core [§4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#4-connection-pool)). `()` means the global pool configuration (core [§4.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#45-global-pool-configuration)). |

### 3.3. Connection

The initializer performs the following steps, then creates the client as specified in core [§3.3.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#331-creation).

1. It builds the connection URL. The URL names the server `host` and the named instance `instance`; it names the port `port` when `port` is greater than `0`, and the database `database` when `database` is neither `()` nor `""`. The text of the URL is _implementation-defined_. When the URL has a port, the driver connects to that port and does not use the instance name.
2. The values of `host`, `instance` and `database` are inserted into the URL as given, without escaping, so they are trusted input: a value that contains characters with a meaning in the URL syntax, such as `;`, `=`, `\` or `:`, changes the URL and can set driver properties ([§13](#13-security-considerations), rule 3). When one of these values contains any of the characters `/`, `?`, `&`, `;`, `=`, `(`, `)`, `#` or `,`, the initializer logs a warning and continues with the URL as built.
3. The data source class is `com.microsoft.sqlserver.jdbc.SQLServerDataSource`, or the XA data source class of [§4.4](#44-xa-data-source) when `useXADatasource` is `true`.
4. `user` and `password` are given to the core library as the user and password of the client.
5. The pool configuration is `connectionPool`, or the value returned by `sql:getGlobalConnectionPool` when `connectionPool` is `()`.
6. When the driver is not available to the program, the data source class cannot be loaded and the initializer returns an `sql:ApplicationError` (core [§4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation), step 5).
7. When `instance` is not `""` and `port` is greater than `0`, the instance name has no effect (rule 1), and the initializer logs a warning. With `port` `0` or negative, the driver looks up the port of `instance`.
8. When `port` is greater than `65535`, the initializer returns an `sql:ApplicationError` without connecting.

The initializer does not validate the parameters of [§3.2](#32-configuration) itself. A value that the driver or the server rejects, such as a wrong password, a database that does not exist, or a host that cannot be reached, makes the initializer return the error specified in core [§4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors).

#### 3.3.1. Example: Connection URL

```ballerina
import ballerinax/mssql;

function connectNamed() returns mssql:Client|error {
    // Named instance, port resolved through the SQL Server Browser service.
    return new ("db.example.com", "app", "secret", "orders", port = 0, instance = "SQLEXPRESS");
}
```

The connection URL names the server `db.example.com`, the instance `SQLEXPRESS` and the database `orders`, and no port (rule 1); for example, `jdbc:sqlserver://db.example.com\SQLEXPRESS;database=orders`. With the default `port` of `1433`, the URL would also name the port `1433`, the driver would connect to port `1433` without using the instance name, and the initializer would log a warning (rule 7).

### 3.4. Operations

1. The `query`, `queryRow`, `execute`, `batchExecute`, `call` and `close` methods behave as specified in core [§3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-client) and [§8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#8-query) to [§13](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#13-transactions), with the differences specified in [§6](#6-parameter-binding) to [§9](#9-result-mapping).
2. `batchExecute` with an empty array returns an `sql:ApplicationError` without obtaining a connection, as core [§11.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#112-behaviour) rule 2 specifies; the library also checks the array itself before it delegates to the core library. The message of the error is _unspecified_.
3. The library provides no `sql:SchemaClient` (core [§14](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#14-metadata-retrieval)).

### 3.5. Compile-time validation

The library's compiler plugin checks literal values of the pool configuration given to a client, in addition to the checks of the `sql` compiler plugin (core [§4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation)). It checks the options of a client as specified in [§4.5](#45-compile-time-validation).

1. The plugin checks each implicit or explicit `new` expression whose type is `mssql:Client`, or a union that contains it. Its `connectionPool` argument is checked when it is given as a named argument, or as the eighth positional argument when the call has eight positional arguments and no named argument.
2. An argument or initializer is checked only when it is a mapping constructor. Each of its fields is checked when its value is a numeric literal, decimal or hexadecimal, optionally preceded by a unary operator; the check uses the value of the literal, whatever its form and magnitude.
3. Field values that are not literals, such as variable references, shorthand fields and spread fields, are not checked. The plugin does not check a module whose compilation already has errors.
4. The plugin never fails the build for a value that the language accepts, other than by reporting the diagnostics of the table below.

| Code | Field | Condition | Kind |
|---|---|---|---|
| `SQL_101` | `connectionPool.maxOpenConnections` | value less than `1` | error |
| `SQL_102` | `connectionPool.minIdleConnections` | value less than `0` | error |
| `SQL_103` | `connectionPool.maxConnectionLifeTime` | value less than `0`, or greater than `0` and less than `30` | error |

These conditions are those of core [§4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation). Diagnostic messages are _unspecified_.

### 3.6. Errors

| Condition | Error |
|---|---|
| The driver is not available | `sql:ApplicationError`, returned by the initializer |
| The server cannot be reached, the login fails, the database cannot be opened, or a TLS handshake fails | As specified in core [§4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors), returned by the initializer |
| `port` greater than `65535` | `sql:ApplicationError`, returned by the initializer |
| `batchExecute` with an empty array | `sql:ApplicationError`, returned |

Other errors are specified in the core specification and in [§4](#4-connection-options) to [§9](#9-result-mapping).

## 4. Connection options

### 4.1. Description

`mssql:Options` configures the connection to the server. The client converts it to driver properties and selects the data source class with it.

### 4.2. Configuration

`mssql:Options` is a closed record:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `secureSocket` | `mssql:SecureSocket` | absent | TLS configuration ([§5](#5-ssltls)). |
| `socketTimeout` | `decimal` | absent | Time in seconds that a read from or write to the server socket can block ([§4.3](#43-driver-properties)). |
| `queryTimeout` | `decimal` | absent | Time in seconds that the execution of a statement can take ([§4.3](#43-driver-properties)). |
| `loginTimeout` | `decimal` | absent | Deprecated since 1.20.0. Use `sql:ConnectionPool.connectionTimeout`. Login timeout of the driver in seconds; it has no effect on the establishment of a connection ([§4.3](#43-driver-properties), rule 5). |
| `useXADatasource` | `boolean` | `false` | When `true`, connections are created by the XA data source of the driver ([§4.4](#44-xa-data-source)). |
| `generatedKeysMode` | `sql:GeneratedKeysMode` | `sql:ALL_STATEMENTS` | The statements of `execute` for which generated keys are requested (core [§10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 7, [§7](#7-execute-and-generated-keys)). It sets no driver property and is not part of the pool key (core [§4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection) rule 7). |

### 4.3. Driver properties

1. The driver options map is built from `options` only, as specified in this section and in [§5.2](#52-configuration). Clients with equal `options` values have equal driver options maps, which is one of the conditions for sharing a pool ([§4.7](#47-interactions); core [§4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)).
2. A time field of `mssql:Options` that is absent, or whose value is not greater than `0`, sets no driver property, and the driver's default applies. When the value of a time field is negative, the initializer logs a warning.
3. `socketTimeout` sets the driver property `socketTimeout` to the value in milliseconds: the `decimal` value is converted to `float`, multiplied by `1000` and truncated towards zero. A result of `0` sets no driver property. When a read from the socket blocks for longer, the operation returns an `sql:DatabaseError`.
4. `queryTimeout` sets the driver's query timeout to `queryTimeout` seconds. How a fractional value is rounded to the whole seconds of the driver is _unspecified_. When a statement executes for longer, the driver cancels it and the operation returns an `sql:DatabaseError`. Every value greater than `0` is accepted, and `queryTimeout` does not configure the pool.
5. The establishment of a connection, including login, is bounded by the `connectionTimeout` of the pool configuration (core [§4.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#42-configuration)): the pool sets the login timeout of the data source from it, which replaces the value of `loginTimeout`. `loginTimeout` therefore has no effect.

> **Note:** A `loginTimeout` or `socketTimeout` literal less than `0`, and a `queryTimeout` literal less than `-1`, are rejected at compile time ([§4.5](#45-compile-time-validation)); every other value that is not greater than `0`, including a negative value that is not a literal and a `queryTimeout` of `-1`, is handled by rule 2.

### 4.4. XA data source

1. When `useXADatasource` is `true`, the data source class is `com.microsoft.sqlserver.jdbc.SQLServerXADataSource`, and a pool for it is created as specified in core [§4.8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#48-xa-data-sources), unless the client shares an existing pool ([§4.7](#47-interactions)).
2. With `useXADatasource`, transactions use two-phase commit as specified in core [§13](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#13-transactions), rule 10.

### 4.5. Compile-time validation

The compiler plugin checks the `options` argument of a `new` expression of [§3.5](#35-compile-time-validation) rule 1, given as a named argument, or as the seventh positional argument when the call has seven or eight positional arguments and no named argument. It also checks the initializer of a variable declaration, at module or function level, whose declared type is `mssql:Options` or a union that contains it. Rules 2 to 4 of [§3.5](#35-compile-time-validation) apply.

| Code | Field | Condition | Kind |
|---|---|---|---|
| `MSSQL_101` | `loginTimeout`, `socketTimeout` of `mssql:Options` | value less than `0` | error |
| `MSSQL_102` | `queryTimeout` of `mssql:Options` | value less than `-1` | error |

Diagnostic messages are _unspecified_.

#### 4.5.1. Example: Literal option values

```ballerina
import ballerinax/mssql;

function connect() returns error? {
    mssql:Client db = check new (options = {socketTimeout: 0, queryTimeout: -1}, connectionPool = {maxConnectionLifeTime: 30});
    check db.close();
}
```

The function compiles: `0` is accepted for `socketTimeout`, `-1` for `queryTimeout` and `30` for `maxConnectionLifeTime`. `socketTimeout: -1` would be reported as `MSSQL_101`, and `maxConnectionLifeTime: 10` as `SQL_103` ([§3.5](#35-compile-time-validation)).

### 4.6. Errors

| Condition | Error |
|---|---|
| A socket read times out, or a statement exceeds the query timeout | `sql:DatabaseError`, returned by the operation |

### 4.7. Interactions

- Clients share a pool only when their connection URLs, driver options maps, users, passwords and data source classes are equal (core [§4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)). Option values that set no driver property, such as an absent `socketTimeout` and a `socketTimeout` of `0`, give equal maps ([§4.3](#43-driver-properties), rule 1). `useXADatasource` is not part of the driver options map, but it selects the data source class ([§4.4](#44-xa-data-source)), so a client with `useXADatasource: true` and a client without it never share a pool.

## 5. SSL/TLS

### 5.1. Description

`mssql:SecureSocket` configures whether the connection to the server is encrypted and how the server certificate is validated.

### 5.2. Configuration

`mssql:SecureSocket` is a closed record:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `encrypt` | `boolean` | absent | `true` sets the driver property `encrypt` to `true`, so the connection uses TLS. When the field is `false` or absent, or `secureSocket` is absent, the driver property `encrypt` is `false`, so the client does not request TLS ([§5.3](#53-behaviour), rule 3). |
| `trustServerCertificate` | `boolean` | absent | `false` sets the driver property `trustServerCertificate` to `false`, so the driver validates the certificate of the server against the trust store. When `cert` is given, the driver property is also `false` ([§5.3](#53-behaviour), rule 5). Otherwise, when the field is `true` or absent, or `secureSocket` is absent, the driver property `trustServerCertificate` is `true`, so the certificate is not validated ([§5.3](#53-behaviour), rule 4). |
| `cert` | `crypto:TrustStore` | absent | Trust store for validating the server certificate: its `path` and `password` set the driver properties `trustStore` and `trustStorePassword`. When absent, the driver uses the default trust store of the JVM. When given, the driver property `trustServerCertificate` is `false`, so the certificate of the server is validated against this trust store ([§5.3](#53-behaviour), rule 5). |
| `key` | `crypto:KeyStore` | absent | Sets the driver properties `keyStoreAuthentication` to `JavaKeyStorePassword`, `keyStoreLocation` to its `path` and `keyStoreSecret` to its `password`. The driver uses this key store for the column master keys of Always Encrypted; no client certificate is presented during the TLS handshake. |

### 5.3. Behaviour

1. When the connection uses TLS and the certificate is validated, a certificate that cannot be validated makes the connection fail, and the initializer returns the error specified in core [§4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors).
2. Which key store formats can be loaded is driver-defined.
3. The client requests TLS only when it is configured: without `secureSocket`, or with `encrypt` absent or `false`, the driver property `encrypt` is `false`. Whether the server then enforces encryption is server-defined. This follows the Ballerina convention that the minimum configuration needs no TLS material, in the way that an `http:Client` uses TLS only for an `https` URL.
4. When `encrypt` is `true` and neither `trustServerCertificate` nor `cert` is given, the connection is encrypted but the server certificate is not validated, and the initializer logs a warning before it connects. Giving `trustServerCertificate: true` or a `cert` suppresses the warning.
5. When `cert` is given, the connector sets the driver property `trustServerCertificate` to `false`, so a connection that uses TLS validates the certificate of the server against `cert`.

### 5.4. Errors

| Condition | Error |
|---|---|
| A TLS handshake fails, or the server certificate cannot be validated, while the initializer creates the client | As specified in core [§4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors), returned by the initializer |

## 6. Parameter binding

### 6.1. Description

Parameters are bound as specified in core [§6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#6-parameter-binding), with the differences in this section. They apply to `query`, `queryRow`, `execute`, `batchExecute` and `call`.

### 6.2. Binding of core values

1. `()` is bound as SQL `NULL`, in place of the binding with the JDBC type `NULL` of core [§6.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#62-binding-procedure) rule 2.1 and of the `()` row of core [§6.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#63-basic-types). The value is accepted as `NULL` by every nullable column, whatever its type. The JDBC type with which it is bound is _unspecified_.
2. `sql:NumericValue` and `sql:DecimalValue` are bound as specified in core [§6.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#66-typed-values), with the following differences:
    1. A `decimal` value with `d` digits before the decimal point and a scale of `s` is bound with the scale `max(s, min(10, 38 - d))`, so a value of at most 38 significant digits is never rejected because of its scale. For example, `1.5` is bound with the scale `10`, and a value with 30 digits before the decimal point and a scale of `1` with the scale `8`.
    2. A `NaN` or infinite `float` results in an `sql:ApplicationError` (core [§6.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#66-typed-values) rule 3.3).
    3. `()` is bound as SQL `NULL` with the JDBC type `NUMERIC` for `sql:NumericValue` and `DECIMAL` for `sql:DecimalValue`, with a scale of `10`, in place of the *`()` bound as* cells of the `sql:NumericValue` and `sql:DecimalValue` rows of core [§6.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#66-typed-values).
3. Values of the following kinds are bound by the core rules, but the driver or the server does not accept them, so the operation returns an `sql:DatabaseError`: arrays and typed array values (core [§6.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#65-arrays) and [§6.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#67-typed-array-values)), `sql:StructValue`, `sql:RefValue`, `sql:RowValue`, and `xml` values.

> **Note:** `mssql:Point` is a record type, so a `mssql:Point` parameter is rejected with an `sql:DataError` (core [§6.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#62-binding-procedure) rule 2.4); a point is bound with `mssql:PointValue` ([§6.3](#63-geometry-values)).

#### 6.2.1. Example: Exact numeric values

```ballerina
import ballerina/sql;
import ballerinax/mssql;

function saveAmount(mssql:Client db, int id) returns sql:ExecutionResult|sql:Error {
    sql:DecimalValue amount = new (1.5d);
    sql:DecimalValue empty = new ();
    return db->execute(`UPDATE accounts SET balance = ${amount}, credit = ${empty} WHERE id = ${id}`);
}
```

`amount` is bound as the exact value `1.5` (core [§6.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#66-typed-values) rule 3.1; its scale follows rule 2.1); `empty` as `NULL` with the JDBC type `DECIMAL` (rule 2.3).

### 6.3. Geometry values

The classes in the following table are typed values of the library, which it binds as permitted by core [§6.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#62-binding-procedure) rule 2.3. Each one binds a value of the SQL Server `geometry` type. Each has a `value` field, whose accepted types are given in the table, and an `srid` field of type `int?`, the spatial reference identifier, whose default is `()`.

| Class | Accepted `value` | WKT built from a non-string `value` |
|---|---|---|
| `mssql:PointValue` | `mssql:Point`, `string`, `()` | `POINT (x y)` |
| `mssql:MultiPointValue` | `mssql:Point[]`, `string`, `()` | `MULTIPOINT ((x y), …)` |
| `mssql:LineStringValue` | `mssql:Point[]`, `string`, `()` | `LINESTRING (x y, …)` |
| `mssql:CircularStringValue` | `mssql:Point[]`, `string`, `()` | `CIRCULARSTRING (x y, …)` |
| `mssql:MultiLineStringValue` | `mssql:LineStringValue[]`, `string`, `()` | `MULTILINESTRING ((x y, …), …)` |
| `mssql:CompoundCurveValue` | `mssql:CompoundCurveElement[]`, `string`, `()` | `COMPOUNDCURVE (…)`: a `LineStringValue` element as `(x y, …)` and a `CircularStringValue` element as `CIRCULARSTRING (x y, …)` |
| `mssql:PolygonValue` | `mssql:LineStringValue[]`, `string`, `()` | `POLYGON ((x y, …), …)`, one ring per element |
| `mssql:CurvePolygonValue` | `mssql:CircularArcRing[]`, `string`, `()` | `CURVEPOLYGON (…)`: a `LineStringValue` ring as `(x y, …)`, a `CircularStringValue` ring as `CIRCULARSTRING (x y, …)` and a `CompoundCurveValue` ring as `COMPOUNDCURVE (…)` |
| `mssql:MultiPolygonValue` | `mssql:PolygonValue[]`, `string`, `()` | `MULTIPOLYGON (((x y, …), …), …)` |
| `mssql:GeometryCollectionValue` | `mssql:GeometryCollectionElement[]`, `string`, `()` | `GEOMETRYCOLLECTION (…)`, each element as its own WKT, separated by `, ` |

`mssql:Point` is an open record with the fields `x` and `y` of type `decimal`. `mssql:CompoundCurveElement` is `LineStringValue|CircularStringValue`, `mssql:CircularArcRing` is `LineStringValue|CircularStringValue|CompoundCurveValue`, and `mssql:GeometryCollectionElement` is the union of every class in the table except `GeometryCollectionValue`.

1. A `string` value is the WKT of the geometry and is passed to the driver unchanged.
2. A non-string value is converted to WKT as given in the table, with the elements in array order. Each coordinate is converted to the nearest 64-bit floating-point value and written in a form that does not depend on the locale of the JVM.
3. In a `GeometryCollectionValue`, an element whose `value` is a `string` contributes that string as its WKT. In the other classes, an element whose `value` is a `string` contributes that string unchanged, in place of the text the table gives for that element; for example, a `LineStringValue` ring of a `PolygonValue` whose `value` is `"(0 0, 0 1, 1 1, 0 0)"` contributes `(0 0, 0 1, 1 1, 0 0)`. The binding never panics.
4. An element whose `value` is `()` results in an `sql:DataError` that names the class of the element.
5. The geometry is created by the driver from the WKT and the SRID, and bound as `geometry`. The SRID is `srid`, or `0` when `srid` is `()`. A value of `srid` outside `0` to `999999`, the range SQL Server accepts for `geometry`, results in an `sql:DataError`, and the value is not bound.
6. WKT that does not describe a valid geometry results in an `sql:DatabaseError`.
7. A `value` of `()` binds SQL `NULL`.
8. A non-string `value` that is an empty array binds the empty geometry of the class: the keyword of the class in the table followed by `EMPTY`, such as `LINESTRING EMPTY` or `GEOMETRYCOLLECTION EMPTY`.

#### 6.3.1. Example: Geometry values

```ballerina
import ballerina/sql;
import ballerinax/mssql;

function addShapes(mssql:Client db) returns sql:Error? {
    mssql:PointValue site = new ({x: 6.5, y: 52.25}, 4326);
    mssql:PolygonValue area = new ([new mssql:LineStringValue([{x: 0, y: 0}, {x: 0, y: 1}, {x: 1, y: 1}, {x: 0, y: 0}])]);
    mssql:PointValue fromText = new ("POINT (1.5 2.5)");
    _ = check db->execute(`INSERT INTO shapes (site, area, other) VALUES (${site}, ${area}, ${fromText})`);
}
```

`site` is bound as `POINT (6.5 52.25)` with SRID `4326`, `area` as `POLYGON ((0 0, 0 1, 1 1, 0 0))` with SRID `0`, and `fromText` with its text unchanged (rules 1, 2 and 5).

### 6.4. Money values

`mssql:MoneyValue` and `mssql:SmallMoneyValue` are typed values for the SQL Server `money` and `smallmoney` types, which the library binds as permitted by core [§6.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#62-binding-procedure) rule 2.3. Their `value` field accepts `decimal`, `float`, `string` and `()`; the default is `()`.

1. A `decimal` is bound exactly.
2. A `float` is bound as a 64-bit floating-point number; a `NaN` or infinite `float` results in an `sql:DataError`, and the value is not bound.
3. A `string` is passed to the driver as a string, and the server converts it to the type of the target. A string that the server cannot convert results in an `sql:DatabaseError`.
4. `()` binds SQL `NULL`.
5. Whether the value fits the range of `money` or `smallmoney` is checked by the server, not by the library; a value out of range results in an `sql:DatabaseError`.

### 6.5. Errors

| Condition | Error |
|---|---|
| An array, typed array value, `sql:StructValue`, `sql:RefValue`, `sql:RowValue` or `xml` parameter | `sql:DatabaseError` |
| A `NaN` or infinite `float` in an `sql:NumericValue` | `sql:ApplicationError` |
| A geometry element whose `value` is `()`, an `srid` outside `0` to `999999`, or a non-finite money `float` | `sql:DataError` |
| WKT that does not describe a valid geometry, or a money string that the server cannot convert | `sql:DatabaseError` |

Messages are _unspecified_. Binding errors are returned, never raised as panics.

### 6.6. Interactions

- The rules of [§6.2](#62-binding-of-core-values) apply to every statement of a `batchExecute` call.
- The geometry and money classes cannot be the IN value of an `sql:InOutParameter` ([§8.2](#82-behaviour), rule 6).

## 7. Execute and generated keys

### 7.1. Description

The client requests generated keys for `execute`, except for DDL statements, and not for `batchExecute` (core [§10.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#102-execution-result)). The `generatedKeysMode` field of `mssql:Options` ([§4.2](#42-configuration)) selects the `sql:GeneratedKeysMode` of core [§10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 7; with `sql:INSERT_ONLY`, generated keys are requested only for the statements that rule names. This section states the consequences for SQL Server.

### 7.2. Behaviour

1. `lastInsertId` of the result of `execute` is the identity value the statement generated, as reported by the server for the scope of the statement. The server reports it as `numeric(38,0)`, which the driver reports as `DECIMAL`, so `lastInsertId` is a `string` such as `"1"` (core [§10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys), rule 2.2). For a statement that generates no identity value, such as an `UPDATE` or an `INSERT` into a table without an identity column, `lastInsertId` is `()`.
2. `lastInsertId` of every result of `batchExecute` is `()`.
3. For a statement whose first result is not an update count, such as `SET`, `DECLARE`, `PRINT`, `USE`, `WAITFOR`, or an `IF` statement whose executed branch affects no rows, `execute` returns an `sql:ExecutionResult` or an `sql:Error`, and never panics; which one is _unspecified_. A statement that produces a result set, such as a `SELECT`, results in an `sql:DatabaseError` (core [§10.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#105-errors)). When `generatedKeysMode` is `sql:INSERT_ONLY` ([§7.1](#71-description)), no generated keys are requested for these statements, and `execute` returns an `sql:ExecutionResult` whose `lastInsertId` is `()`.
4. A statement that core [§10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 1 recognises as DDL, such as `CREATE PROCEDURE`, `CREATE FUNCTION` or `CREATE TRIGGER`, is prepared without a generated-keys request, so its text reaches the server as given (core [§5.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#53-sql-text-construction)), and the body of a procedure, function, trigger or view it creates is the body in the statement.

#### 7.2.1. Example: Identity key

```ballerina
import ballerina/sql;
import ballerinax/mssql;

function addCustomer(mssql:Client db, string name) returns int|error {
    sql:ExecutionResult result = check db->execute(`INSERT INTO customers (name) VALUES (${name})`);
    string|int? id = result.lastInsertId;
    return id is string ? int:fromString(id) : error("no identity value");
}
```

For a table whose `id` column is `int IDENTITY`, the first insert gives `affectedRowCount` `1` and `lastInsertId` `"1"`, a `string` (rule 1).

### 7.3. Errors

| Condition | Error |
|---|---|
| `execute` of a statement that produces a result set | `sql:DatabaseError` |

Other errors are those of core [§10.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#105-errors).

## 8. Stored procedure calls

### 8.1. Description

`call` behaves as specified in core [§12](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#12-stored-procedure-calls). This section states the SQL Server-specific behaviour of results and parameters.

### 8.2. Behaviour

1. The call forms `{call name(...)}`, `EXEC name ...` and, for a scalar function, `{${ret} = call name(...)}` are accepted, where `ret` is an OUT parameter that receives the return value.
2. The results of a call are the results the procedure produces, in order: a statement of the procedure that affects rows produces an update count unless the procedure sets `NOCOUNT` on, and each `SELECT` that returns rows to the caller produces a result set. The first result decides whether `executionResult` or `queryResult` is set (core [§12.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#123-call-execution), step 6).
3. Reading an OUT or INOUT parameter with `get` closes the current result set of the call. Iterating the stream of that result set afterwards returns an `sql:DatabaseError`. Otherwise, OUT and INOUT parameters are read as specified in core [§12.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#126-reading-out-and-inout-parameters); reading them does not require reading the result sets first.
4. `sql:CursorOutParameter` is not supported: a call with such a parameter returns an `sql:DatabaseError`.
5. An `sql:InOutParameter` whose IN value is `()` is registered as `VARCHAR`, in place of the _unspecified_ registration of the `()` row of the INOUT table of core [§12.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#125-out-and-inout-parameter-registration), so its value can be read as `string` or `json` only (core [§12.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#127-out-parameter-type-mapping)); for example, an `int` procedure parameter set to `1` is read as `"1"`. `call` logs a warning for such a parameter. A typed value whose value is `()`, such as `new sql:IntegerValue()`, is registered with the SQL type of that typed value (core [§12.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#125-out-and-inout-parameter-registration)) and is read as that type.
6. An `sql:InOutParameter` whose IN value is a typed value of this library ([§6.3](#63-geometry-values), [§6.4](#64-money-values)) is not given a registration type, so the default of the *Other typed value* row of the INOUT table of core [§12.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#125-out-and-inout-parameter-registration) applies: `call` returns an `sql:DataError`. The library defines no OUT parameter classes.

> **Note:** Core OUT parameter classes are registered with the SQL types of core [§12.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#125-out-and-inout-parameter-registration), so `sql:DecimalOutParameter` (`DECIMAL`) reads a `money` or `smallmoney` OUT parameter, and `sql:TimestampWithTimezoneOutParameter` (`TIMESTAMP_WITH_TIMEZONE`) reads a `datetimeoffset` OUT parameter.

#### 8.2.1. Example: Result sets and OUT parameters

The procedure `orders_of` returns the rows of a customer with `SELECT` and sets its OUT parameter `@total`.

```ballerina
import ballerina/sql;
import ballerinax/mssql;

type Order record {| int id; |};

function ordersOf(mssql:Client db, int customer) returns [Order[], int]|error {
    sql:IntegerOutParameter total = new;
    sql:ProcedureCallResult result = check db->call(`{call orders_of(${customer}, ${total})}`, [Order]);
    Order[] orders = [];
    stream<record {}, sql:Error?>? rows = result.queryResult;
    if rows is stream<record {}, sql:Error?> {
        orders = check from record {} r in rows select check r.cloneWithType();
    }
    int count = check total.get();
    check result.close();
    return [orders, count];
}
```

The rows are read before `total`, because reading `total` first would close the result set (rule 3); `total` is read before `close` (core [§12.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#126-reading-out-and-inout-parameters)).

### 8.3. Errors

| Condition | Error |
|---|---|
| A call with an `sql:CursorOutParameter` | `sql:DatabaseError`, returned by `call` |
| An `sql:InOutParameter` whose IN value is a typed value of this library | `sql:DataError`, returned by `call` |
| Iterating a result set stream after an OUT or INOUT parameter of the call is read | `sql:DatabaseError`, from the stream |

## 9. Result mapping

### 9.1. Description

The library does not change result conversion: column values and OUT parameter values are converted as specified in core [§7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#7-result-mapping) and [§12.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#127-out-parameter-type-mapping), according to the JDBC type that the driver reports for each column.

### 9.2. SQL Server types

The JDBC type that the driver reports for a column is driver-defined, and selects the row of core [§7.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#76-column-conversion) and [§7.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#77-unmatched-columns) that applies. The following table is informative. It holds for the Microsoft JDBC Driver for SQL Server 12.8 (`mssql-jdbc` 12.8.2, provided by `ballerinax/mssql.driver` 1.7.1); another driver version can report other types:

| SQL Server type | JDBC type reported | Core §7.6 row |
|---|---|---|
| `tinyint`, `smallint`, `int`, `bigint` | `TINYINT`, `SMALLINT`, `INTEGER`, `BIGINT` | `TINYINT`, `SMALLINT`, `INTEGER`, `BIGINT` |
| `bit` | `BIT` | `BIT`, `BOOLEAN` |
| `real` | `REAL` | `REAL` |
| `float` | `DOUBLE` | `FLOAT`, `DOUBLE` |
| `decimal`, `money`, `smallmoney` | `DECIMAL` | `NUMERIC`, `DECIMAL` |
| `numeric` | `NUMERIC` | `NUMERIC`, `DECIMAL` |
| `char`, `varchar`, `text`, `uniqueidentifier` | `CHAR`, `VARCHAR`, `LONGVARCHAR`, `CHAR` | `CHAR`, `VARCHAR`, `LONGVARCHAR`, `NCHAR`, `NVARCHAR`, `LONGNVARCHAR` |
| `nchar`, `nvarchar`, `ntext`, `xml` | `NCHAR`, `NVARCHAR`, `LONGNVARCHAR`, `LONGNVARCHAR` | `CHAR`, `VARCHAR`, `LONGVARCHAR`, `NCHAR`, `NVARCHAR`, `LONGNVARCHAR` |
| `binary`, `rowversion`, `varbinary`, `hierarchyid`, `image` | `BINARY`, `BINARY`, `VARBINARY`, `VARBINARY`, `LONGVARBINARY` | `BINARY`, `VARBINARY`, `LONGVARBINARY` |
| `date` | `DATE` | `DATE` |
| `time` | `TIME` | `TIME` |
| `datetime2`, `datetime`, `smalldatetime` | `TIMESTAMP` | `TIMESTAMP` |
| `datetimeoffset` | vendor type `-155` | any other JDBC type |
| `geometry`, `geography` | vendor types `-157`, `-158` | any other JDBC type |
| `sql_variant` | vendor type `-156` | any other JDBC type |

1. An `xml` column is reported as `LONGNVARCHAR`, so it is read as `string` and cannot be read into `xml`.
2. A `datetimeoffset` value read as `string` has the driver's form `yyyy-mm-dd hh:mm:ss[.fffffff] ±hh:mm`.
3. A `geometry` or `geography` value read as `byte[]` is its serialized form, and read as `string` its hexadecimal digits.

#### 9.2.1. Example: Reading SQL Server types

```ballerina
import ballerinax/mssql;

type Payment record {|
    int id;
    decimal amount;
    string createdAt;
    byte[] location;
|};

function payment(mssql:Client db, int id) returns Payment|error {
    return db->queryRow(`SELECT id, amount, created_at AS createdAt, location FROM payments WHERE id = ${id}`);
}
```

For a `money` column `amount` with the value `5.1234`, a `datetimeoffset` column `created_at` and a `geometry` column `location`, the result has `amount` `5.1234d`, `createdAt` such as `"2021-02-03 10:20:30.1234567 +05:30"`, and `location` holding the serialized geometry ([§9.2](#92-sql-server-types), rules 2 and 3). Declaring `createdAt` as `time:Civil` would result in an `sql:UnsupportedTypeError` ([§9.3](#93-errors)).

### 9.3. Errors

The errors of result mapping are those of core [§7.8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#78-errors). A `datetimeoffset` column read into `time:Civil` results in an `sql:UnsupportedTypeError`, and into `time:Utc` in an `sql:TypeMismatchError`, because the driver reports it as a vendor type ([§9.2](#92-sql-server-types)).

## 10. Observability

### 10.1. Description

The pool metrics of core [§16](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#16-observability) apply. The client adds the metric tags of core [§16.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#164-tags) rule 3.

### 10.2. Metric tags

The client gives the following tags to the pool metrics:

| Tag | Value |
|---|---|
| `db_host` | `host`, as given. |
| `db_port` | `port` in decimal, as given, also when it is `0` or negative. |
| `db_name` | `database`. The tag is absent when `database` is `()` or `""`. |

The tags are set when the pool is created, so a client that shares an active pool (core [§4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)) reports the tags of that pool.

## 11. CDC listener

### 11.1. Description

`mssql:CdcListener` is an isolated listener class that includes `cdc:Listener`. It captures the row changes of SQL Server tables that have change data capture enabled and delivers them to `cdc:Service` services, as specified in [CDC §2.1](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#21-listener) and [CDC §2.2](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#22-service). This section specifies the SQL Server-specific configuration and how it is converted to Debezium properties.

### 11.2. Configuration

The initializer takes the fields of `mssql:MsSqlListenerConfiguration` as named arguments. `mssql:MsSqlListenerConfiguration` is a closed record that includes `cdc:ListenerConfiguration` (`engineName`, `internalSchemaStorage`, `offsetStorage` and `livenessInterval`, specified in [CDC §2.4](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#24-listener-configuration)) and has the following fields:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `database` | `mssql:MsSqlDatabaseConnection` | Required | Server connection and capture scope. |
| `options` | `mssql:MssqlOptions` | `{}` | Connector options. |

`mssql:MsSqlDatabaseConnection` includes `cdc:DatabaseConnection`. Each field sets the Debezium property given in the table. A list given as `string[]` is joined with `,`. Values are passed to Debezium without validation; the meaning of `0`, negative values and of conflicting include and exclude lists is that of the Debezium property, and a value Debezium rejects is reported as specified in [§11.4](#114-errors).

| Field | Type | Default | Debezium property and meaning |
|---|---|---|---|
| `connectorClass` | `string` | `"io.debezium.connector.sqlserver.SqlServerConnector"` | `connector.class` |
| `hostname` | `string` | `"localhost"` | `database.hostname` |
| `port` | `int` | `1433` | `database.port` |
| `username` | `string` | Required | `database.user` |
| `password` | `string` | Required | `database.password` |
| `connectTimeout` | `decimal` | absent | `connect.timeout.ms`, in milliseconds with the fraction discarded |
| `tasksMax` | `int` | `1` | `tasks.max` |
| `secure` | `cdc:SecureDatabaseConnection` | absent | The SSL properties of the CDC library. When present, `database.encrypt` is not set. When absent, `database.encrypt` is set to `false`, so the connector does not request TLS, following the convention of [§5.3](#53-behaviour) rule 3 ([§13](#13-security-considerations), rule 7). |
| `databaseInstance` | `string` | absent | `database.instance` |
| `databaseNames` | `string\|string[]` | Required | `database.names`: the databases to capture |
| `includedSchemas` | `string\|string[]` | absent | `schema.include.list`: regular expressions of schemas to capture |
| `excludedSchemas` | `string\|string[]` | absent | `schema.exclude.list` |
| `includedTables` | `string\|string[]` | absent | `table.include.list`: regular expressions of fully-qualified tables to capture |
| `excludedTables` | `string\|string[]` | absent | `table.exclude.list` |
| `includedColumns` | `string\|string[]` | absent | `column.include.list` |
| `excludedColumns` | `string\|string[]` | absent | `column.exclude.list` |
| `messageKeyColumns` | `cdc:MessageKeyColumns[]` | absent | `message.key.columns`, as converted by the CDC library |
| `streamingConfig` | `mssql:StreamingConfiguration` | absent | When present, sets the four properties of `mssql:StreamingConfiguration`; when absent, none of them is set. |

`mssql:MsSqlDatabaseConnection` accepts fields it does not declare, because `cdc:DatabaseConnection` is open; such fields set no Debezium property.

`mssql:StreamingConfiguration` is a closed record:

| Field | Type | Default | Debezium property |
|---|---|---|---|
| `dataQueryMode` | `mssql:DataQueryMode` | `FUNCTION` | `data.query.mode`: `function` or `direct` |
| `streamingDelayMs` | `int` | `0` | `streaming.delay.ms` |
| `streamingFetchSize` | `int` | `10000` | `streaming.fetch.size` |
| `maxIterationTransactions` | `int` | `500` | `max.iteration.transactions` |

`mssql:MssqlOptions` includes `cdc:Options` ([CDC §2.5](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#25-cdc-options)). Its `extendedSnapshot` and `heartbeatConfig` fields replace the fields of the same name of `cdc:Options` with the types `mssql:ExtendedSnapshotConfiguration` and `cdc:RelationalHeartbeatConfiguration`; `dataTypeConfig` is an additional field:

| Field | Type | Default | Meaning |
|---|---|---|---|
| `extendedSnapshot` | `mssql:ExtendedSnapshotConfiguration` | absent | When present, sets the properties of `cdc:RelationalExtendedSnapshotConfiguration` and those below. |
| `dataTypeConfig` | `mssql:DataTypeConfiguration` | absent | When present, sets the properties of `cdc:DataTypeConfiguration` and `include.schema.changes`. |
| `heartbeatConfig` | `cdc:RelationalHeartbeatConfiguration` | absent | Heartbeat properties of the CDC library. |

`mssql:ExtendedSnapshotConfiguration` includes `cdc:RelationalExtendedSnapshotConfiguration` and has the fields `lockTimeout` (`decimal`, default `10`, sets `snapshot.lock.timeout.ms` in milliseconds with the fraction discarded), `isolationMode` (`cdc:SnapshotIsolationMode`, absent, sets `snapshot.isolation.mode`) and `incrementalSnapshotOptionRecompile` (`boolean`, default `false`, sets `incremental.snapshot.option.recompile`).

`mssql:DataTypeConfiguration` includes `cdc:DataTypeConfiguration` and has the field `includeSchemaChanges` (`boolean`, default `true`), which sets `include.schema.changes`. When `dataTypeConfig` is absent, `include.schema.changes` is `false`; when it is given without `includeSchemaChanges`, `include.schema.changes` is `true`.

`mssql:SourceStructVersion` is deprecated since 1.20.0 and has no replacement. No configuration field accepts it, and it has no effect.

### 11.3. Behaviour

1. The initializer converts the configuration to Debezium properties: first the properties of the CDC library for `cdc:ListenerConfiguration`, `cdc:DatabaseConnection` and `cdc:Options`, then the properties of [§11.2](#112-configuration). The initializer does not connect to the server and does not fail.
2. A field of `options` that `mssql:MssqlOptions` does not declare is passed as the Debezium property of the same name when its value is a `string`, `int`, `boolean`, `decimal` or `float`. These fields are applied after the properties of rule 1, so each replaces a property of the same name set by rule 1, such as `database.encrypt` or `connector.class`, and the initializer logs a warning for each field that replaces such a property. A value of another type is logged as an error and ignored.
3. `attach`, `start`, `detach`, `gracefulStop` and `immediateStop` behave as specified in the CDC library specification. The `name` argument of `attach` is ignored.
4. `onRead` receives the rows of the initial snapshot, and `onCreate`, `onUpdate` and `onDelete` receive the inserts, updates and deletes captured after it, for the tables selected by `databaseNames` and the include and exclude lists. The `tableName` argument is the name of the table without its schema and database, for example `orders` for `dbo.orders`, so changes to tables of the same name in different schemas or databases are delivered with the same `tableName`.
5. Which changes are captured, and when, is determined by the change data capture configuration of the server and by the Debezium SQL Server connector.

#### 11.3.1. Example: Capturing a table

```ballerina
import ballerina/log;
import ballerinax/cdc;
import ballerinax/mssql;
import ballerinax/mssql.cdc.driver as _;

listener mssql:CdcListener orders = new (database = {
    hostname: "localhost",
    username: "cdc_user",
    password: "secret",
    databaseNames: "shop",
    includedTables: "dbo.orders"
});

service cdc:Service on orders {
    remote function onCreate(record {} after, string tableName) returns error? {
        log:printInfo("insert", 'table = tableName, row = after);
    }
}
```

The listener sets `database.names` to `shop` and `table.include.list` to `dbo.orders` ([§11.2](#112-configuration)); for a row inserted into `dbo.orders` after the initial snapshot, `onCreate` is called with the row and the table name `orders` ([CDC §2.2.4.2](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#2242-oncreate); [§11.3](#113-behaviour), rule 4).

### 11.4. Errors

The errors of the listener methods are those of the CDC library specification ([CDC §3](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#3-errors)). A failure of the server connection or of the Debezium connector, including change data capture not being enabled, is reported by `start` or by the CDC library as specified there.

### 11.5. Interactions

- The listener and `mssql:Client` share no configuration or connections.
- The Debezium SQL Server connector that the program provides MUST be compatible with the Debezium version of the CDC library in use. With an incompatible connector the behaviour is _unspecified_; an incompatibility that prevents the Debezium engine from starting makes `start` return a `cdc:Error`.

## 12. Connector contract

### 12.1. Description

This section states how the library meets the connector obligations of core [§17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations), and lists the override points of core [§17.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#174-override-points) that it uses.

### 12.2. Obligations

| Obligation | How it is met |
|---|---|
| 1 | `mssql:Client` includes `sql:Client`, and its operations and `close` delegate to the core library ([§3.4](#34-operations)). |
| 2 | The URL, user, password, data source class and pool configuration are given as specified in [§3.3](#33-connection), and the driver options map as specified in [§4.3](#43-driver-properties). |
| 3 | The global pool configuration is given when `connectionPool` is `()` ([§3.3](#33-connection), rule 5). |
| 4 | Generated keys are requested for `execute`, except for DDL statements, and not for `batchExecute`; `generatedKeysMode` `sql:INSERT_ONLY` limits them as in core [§10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 7 ([§7](#7-execute-and-generated-keys)). |
| 5 | The core library checks for an empty array of `batchExecute` (core [§11.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#112-behaviour), rule 2); the library also keeps its own check ([§3.4](#34-operations), rule 2). |
| 6 | The typed value classes of [§6.3](#63-geometry-values) and [§6.4](#64-money-values) have names that the core library does not use. The library defines no OUT or INOUT parameter classes. |
| 7 | The library provides no `sql:SchemaClient`. |
| 8 | The override points used are listed in [§12.3](#123-override-points). |

### 12.3. Override points

The library uses the override points of core [§17.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#174-override-points) as follows.

| Core §17.4 area | Used | Delta | Specified in |
|---|---|---|---|
| Binding of basic types, `time` values and arrays | No | The core rules apply; the driver or the server rejects arrays and `xml` values. | [§6.2](#62-binding-of-core-values) rule 3 |
| Binding of typed values | Yes | `sql:NumericValue` and `sql:DecimalValue`: scale of a `decimal` value, error type of a non-finite `float`, JDBC type of `()`. | [§6.2](#62-binding-of-core-values) rule 2 |
| Connector-defined typed values | Yes | Geometry and money classes; no INOUT registration type (core §12.5 row *Other typed value*). | [§6.3](#63-geometry-values), [§6.4](#64-money-values), [§8.2](#82-behaviour) rule 6 |
| Record parameters | No | | |
| Nil parameters | Yes | `()` is accepted as `NULL` by every nullable column, with an _unspecified_ JDBC type; an INOUT parameter with a `()` IN value is registered as `VARCHAR` (core §12.5 row `()`). | [§6.2](#62-binding-of-core-values) rule 1 (core §6.2 rule 2.1, §6.3 row `()`), [§8.2](#82-behaviour) rule 5 (core §12.5 row `()`) |
| OUT parameter registration | No | | |
| Result conversion | No | | [§9.1](#91-description) |
| OUT and INOUT values | No | | [§9.1](#91-description) |
| Result iteration | No | | |
| Pool properties | No | No pool property is derived from `options`. | [§4.3](#43-driver-properties) rule 4 |
| Metric tags | Yes | `db_host`, `db_port`, `db_name`. | [§10.2](#102-metric-tags) |
| Data source | Yes | `SQLServerDataSource`, or `SQLServerXADataSource` with `useXADatasource`. | [§3.3](#33-connection) rule 3, [§4.4](#44-xa-data-source) |

## 13. Security considerations

The security considerations of core [§18](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#18-security-considerations) apply. In addition:

1. A client requests TLS only when `encrypt` is `true` ([§5.3](#53-behaviour), rule 3). Without TLS, the data and the SQL text travel unencrypted unless the server enforces encryption. A client connection uses TLS and validates the server certificate when `encrypt` is `true` and either `cert` is given or `trustServerCertificate` is `false`; the certificate is then validated against `cert`, or against the default trust store of the JVM ([§5.3](#53-behaviour), rule 5). Without `cert`, and with `trustServerCertificate` `true` or absent, the connection is encrypted but the server is not authenticated; the initializer logs a warning when neither `trustServerCertificate` nor `cert` is given ([§5.3](#53-behaviour), rule 4).
2. `secureSocket.key` does not authenticate the client to the server; it configures the key store of Always Encrypted ([§5.2](#52-configuration)).
3. `host`, `instance` and `database` become part of the connection URL without escaping ([§3.3](#33-connection), rule 2). A value that contains URL syntax, such as `;` followed by a property assignment, sets driver properties, including those that control TLS and authentication. The library does not validate these values, so they are trusted input; it logs a warning for a value that contains URL syntax characters.
4. The default `user` is `sa`, the system administrator login of SQL Server. A program that omits `user` and gives the password of that login connects with the highest privilege of the server.
5. The password and the trust store and key store passwords are given to the driver as driver properties.
6. A statement runs until it completes unless a query timeout is configured ([§4.3](#43-driver-properties)); `socketTimeout` bounds each blocking socket read.
7. When `secure` is absent, the CDC listener sets `database.encrypt` to `false` ([§11.2](#112-configuration)), so its connection carries the credentials and every captured row in clear text unless the server enforces encryption. When `secure` is given, the SSL properties of the CDC library are set and `database.encrypt` is not set. An extra `options` field `database.encrypt` set to `"true"` requests encryption without `secure`, and the initializer logs a warning for it ([§11.3](#113-behaviour), rule 2). The listener's password is passed to the Debezium engine as a property. The default offset and schema history files are written under the relative directory `tmp` of the working directory of the program ([CDC §2.4](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md#24-listener-configuration)).

## 14. Planned changes

This section is informative. It lists behaviour changes planned for the next major version; the rest of this specification describes the current release.

| Change | Affected rule | Current behaviour | Planned behaviour | How to keep the current behaviour |
|---|---|---|---|---|
| Generated keys only for `INSERT` statements | [§4.2](#42-configuration), [§7.2](#72-behaviour) rule 3, [§12.2](#122-obligations) row 4 | `generatedKeysMode` defaults to `sql:ALL_STATEMENTS`: generated keys are requested for every `execute` statement except DDL. | `generatedKeysMode` defaults to `sql:INSERT_ONLY`: generated keys are requested only for the statements of core [§10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 7; for other statements `lastInsertId` is `()`. | Set `generatedKeysMode: sql:ALL_STATEMENTS`, or read the identity value with `SELECT SCOPE_IDENTITY()` through `query` after a statement that is not an `INSERT`. |
| URL syntax characters rejected | [§3.3](#33-connection) rule 2 | `host`, `instance` and `database` are inserted into the URL unescaped; the initializer logs a warning for URL syntax characters. | The initializer returns an `sql:ApplicationError` when `host`, `instance` or `database` contains any of `/`, `?`, `&`, `;`, `=`, `(`, `)`, `#` or `,`. | None; remove driver properties from these values. |
| Server certificate validated when `encrypt` is `true` | [§5.2](#52-configuration), [§5.3](#53-behaviour) rule 4 | With `encrypt: true`, no `cert` and `trustServerCertificate` absent, the connection is encrypted but the certificate is not validated; a warning is logged. | With `encrypt: true`, no `cert` and `trustServerCertificate` absent, the certificate is validated against the default trust store of the JVM. | Set `trustServerCertificate: true`. |
| `instance` honoured with the default port | [§3.3](#33-connection) rule 7, [§3.2](#32-configuration) | With `instance` set and the default `port`, the URL names port `1433` and the instance name has no effect; a warning is logged. | With `instance` set and `port` left at its default, the URL names no port, so the driver looks up the port of `instance`. | Leave `instance` out. |
| Negative timeouts rejected | [§4.3](#43-driver-properties) rule 2 | A negative `socketTimeout`, `queryTimeout` or `loginTimeout` sets no driver property; a warning is logged. | The initializer returns an `sql:ApplicationError` for a negative timeout. | Leave the field out, or set it to `0`. |
| Untyped `()` INOUT values rejected | [§8.2](#82-behaviour) rule 5 | An `sql:InOutParameter` whose IN value is `()` is registered as `VARCHAR`; a warning is logged. | `call` returns an `sql:ApplicationError` for such a parameter. | Give a typed value whose value is `()`, such as `new sql:IntegerValue()`. |
| Colliding CDC options rejected | [§11.3](#113-behaviour) rule 2 | An extra `options` field replaces the Debezium property of the same name set by a declared field; a warning is logged. | The initializer returns a `cdc:Error` for such a field. | Use the declared field, such as `secure` in place of `database.encrypt`. |
| `includeSchemaChanges` default | [§11.2](#112-configuration) | `include.schema.changes` is `false` without `dataTypeConfig` and `true` with it. | `include.schema.changes` is `false` unless `includeSchemaChanges` is `true`. | Set `includeSchemaChanges: true`. |
| `secureSocket.key` renamed | [§5.2](#52-configuration), [§13](#13-security-considerations) rule 2 | `key` configures the key store of Always Encrypted. | The field is renamed to a name that states its Always Encrypted purpose. | None; use the new name. |

## References

- [SQL library specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md)
- [CDC library specification](https://github.com/ballerina-platform/module-ballerinax-cdc/blob/main/docs/spec/spec.md)
- [Microsoft JDBC Driver for SQL Server: connection properties](https://learn.microsoft.com/en-us/sql/connect/jdbc/setting-the-connection-properties)
- [Microsoft JDBC Driver for SQL Server: building the connection URL](https://learn.microsoft.com/en-us/sql/connect/jdbc/building-the-connection-url)
- [Debezium connector for SQL Server](https://debezium.io/documentation/reference/stable/connectors/sqlserver.html)
- [OGC Simple Feature Access, Part 1: Well-Known Text](https://www.ogc.org/standard/sfa/)
- [RFC 2119: Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119)
- [RFC 8174: Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174)
