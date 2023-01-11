# Change Log
This file contains all the notable changes done to the Ballerina oracledb package through the releases.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added
- [To Support Metadata Client for MS SQL] (https://github.com/ballerina-platform/ballerina-standard-library/issues/3825)

### Changed
- [Remove SQL_901 diagnostic hint](https://github.com/ballerina-platform/ballerina-standard-library/issues/3609)
- [Enable non-Hikari logs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3763)

## [1.6.1] - 2022-12-01

### Changed
- [Updated API Docs on `mssql.driver` usages](https://github.com/ballerina-platform/ballerina-standard-library/issues/3710)

## [1.6.0] - 2022-11-29

### Added
- [Support for XA transaction](https://github.com/ballerina-platform/ballerina-standard-library/issues/3598)

### Changed
- [Updated API docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/3463)

## [1.5.0] - 2022-09-08

### Changed
- [Change default username for client initialization to `sa`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2397)

## [1.4.1] - 2022-06-27

### Changed
- [Fix NullPointerException when retrieving record with default value](https://github.com/ballerina-platform/ballerina-standard-library/issues/2985)

## [1.4.0] - 2022-05-20

### Added
- [Improve DB columns to Ballerina record Mapping through Annotation](https://github.com/ballerina-platform/ballerina-standard-library/issues/2652)

### Changed
- [Improve API documentation to reflect query usages](https://github.com/ballerina-platform/ballerina-standard-library/issues/2524)
- [Fixed compiler plugin validation for `time` module constructs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2893)
- [Fix incorrect code snippet in SQL api docs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2931)

## [1.3.0] - 2022-01-29

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:ConnectionPool` and `mssql:Options`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.1] - 2022-02-03

### Changed
- [Fix Compiler plugin crash when variable is passed for `sql:ConnectionPool` and `mssql:Options`](https://github.com/ballerina-platform/ballerina-standard-library/issues/2536)

## [1.2.0] - 2021-12-13

### Added
- [Add tooling support](https://github.com/ballerina-platform/ballerina-standard-library/issues/2282)

## [1.1.0] - 2021-11-20

### Changed
- [Change queryRow return type to anydata](https://github.com/ballerina-platform/ballerina-standard-library/issues/2390)

## [1.0.0] - 2021-10-09

### Added
- [Add completion type as nil in SQL query return stream type](https://github.com/ballerina-platform/ballerina-standard-library/issues/1654)
- Basic CRUD functionalities with an MSSQL database.
- Insert functionality for DB specific data types.
- Procedure calls with input and output parameters
- Support for MSSQL Geometry data types 
- [Add support for queryRow](https://github.com/ballerina-platform/ballerina-standard-library/issues/1604)

### Changed
- [Remove support for string parameter in SQL APIs](https://github.com/ballerina-platform/ballerina-standard-library/issues/2010)
