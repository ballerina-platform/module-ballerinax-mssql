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

import ballerina/io;
import ballerina/sql;

isolated function initTestScripts() {
    _ = initPool();
    _ = connectionInitDb();
    _ = basicExcuteInitDB();
    _ = executeParamsInitDB();
    _ = createBatchExecuteDB();
    _ = simpleQueryInitDB();
    _ = complexQueryInitDB();
    _ = proceduresInit();
    _ = sslConnectionInitDb();
}

isolated function connectionInitDb() {
        _ = createQuery(`DROP DATABASE IF EXISTS CONNECT_DB`);
        _ = createQuery(`CREATE DATABASE CONNECT_DB`);
}

isolated function initPool() {
    _ = createQuery(`DROP DATABASE IF EXISTS POOL_DB_1`);
    _ = createQuery(`CREATE DATABASE POOL_DB_1`);
    _ = createQuery(`DROP DATABASE IF EXISTS POOL_DB_2`);
    _ = createQuery(`CREATE DATABASE POOL_DB_2`);

    sql:ParameterizedQuery q2 = `
            DROP TABLE IF EXISTS Customers;

            CREATE TABLE Customers(
            customerId INT NOT NULL IDENTITY PRIMARY KEY,
            firstName  VARCHAR(300),
            lastName  VARCHAR(300),
            registrationID INT,
            creditLimit FLOAT,
            country  VARCHAR(300)
            );

            INSERT INTO Customers (firstName,lastName,registrationID,creditLimit,country)
            VALUES ('Peter', 'Stuart', 1, 5000.75, 'USA');

            INSERT INTO Customers (firstName,lastName,registrationID,creditLimit,country)
            VALUES ('Dan', 'Brown', 2, 10000, 'UK');
    
    `;
    _ = executeQuery("pool_db_1", q2);

    sql:ParameterizedQuery q3 = `
            DROP TABLE IF EXISTS Customers;

            CREATE TABLE Customers(
            customerId INT NOT NULL IDENTITY PRIMARY KEY,
            firstName  VARCHAR(300),
            lastName  VARCHAR(300),
            registrationID INT,
            creditLimit FLOAT,
            country  VARCHAR(300)
            );

            INSERT INTO Customers (firstName,lastName,registrationID,creditLimit,country)
            VALUES ('Peter', 'Stuart', 1, 5000.75, 'USA');

            INSERT INTO Customers (firstName,lastName,registrationID,creditLimit,country)
            VALUES ('Dan', 'Brown', 2, 10000, 'UK');
        
        `;

    _ = executeQuery("pool_db_2", q3);
}

isolated function basicExcuteInitDB() {
    _ = createQuery(`DROP DATABASE IF EXISTS EXECUTE_DB`);
    _ = createQuery(`CREATE DATABASE EXECUTE_DB`);

    sql:ParameterizedQuery q4 = `
            DROP TABLE IF EXISTS ExactNumericTypes;

            CREATE TABLE ExactNumericTypes (
                id INT NOT NULL IDENTITY PRIMARY KEY,
                smallint_type SMALLINT,
                int_type INT,
                tinyint_type TINYINT,
                bigint_type BIGINT,
                decimal_type DECIMAL,
                numeric_type NUMERIC,
            );

            DROP TABLE IF EXISTS StringTypes;

            CREATE TABLE StringTypes (
                id INT PRIMARY KEY,
                varchar_type VARCHAR(255),
                char_type CHAR(4),
                text_type TEXT,
                nchar_type NCHAR(4),
                nvarchar_type NVARCHAR(10)
            );

            INSERT INTO StringTypes (id, varchar_type) VALUES (1, 'test data');

            DROP TABLE IF EXISTS GeometricTypes;
        
            CREATE TABLE GeometricTypes (
                row_id INT PRIMARY KEY,
                point_type geometry,
                lineString_type geometry,
                geometry_type geometry,
                circularstring_type geometry,
                compoundcurve_type geometry,
                polygon_type geometry,
                curvepolygon_type geometry,
                multipolygon_type geometry,
                multilinestring_type geometry,
                multipoint_type geometry
            );

            DROP TABLE IF EXISTS MoneyTypes;
        
            CREATE TABLE MoneyTypes (
                row_id INT PRIMARY KEY,
                money_type money,
                smallmoney_type smallmoney 
            );
            
        `;

    _ = executeQuery("execute_db", q4);

}

isolated function executeParamsInitDB() {
    _ = createQuery(`DROP DATABASE IF EXISTS EXECUTE_PARAMS_DB`);
    _ = createQuery(`CREATE DATABASE EXECUTE_PARAMS_DB`);

    sql:ParameterizedQuery query = `
    
    DROP TABLE IF EXISTS ExactNumeric;

    CREATE TABLE ExactNumeric(
        row_id INT PRIMARY KEY,
        bigint_type  bigint,
        numeric_type  numeric(10,5), 
        bit_type  bit, 
        smallint_type smallint, 
        decimal_type decimal(5,2), 
        int_type int,
        tinyint_type tinyint
    );

    INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, smallint_type, decimal_type, int_type, tinyint_type)
    VALUES(1, 9223372036854775807, 12.12000, 1, 32767, 123.00, 2147483647, 255);

    DROP TABLE IF EXISTS ApproximateNumeric;

    CREATE TABLE ApproximateNumeric(
    row_id INT PRIMARY KEY,
    float_type float,  
    real_type real
    );

    INSERT INTO ApproximateNumeric (row_id, float_type, real_type) VALUES
    (1, 1.79E+308, -1.18E-38);

    DROP TABLE IF EXISTS DateandTime;

    CREATE TABLE DateandTime(
    row_id INT PRIMARY KEY,
    date_type  date, 
    dateTimeOffset_type  datetimeoffset,
    dateTime2_type datetime2, 
    smallDateTime_type smalldatetime, 
    dateTime_type datetime,
    time_type time
    );

    INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type , dateTime_type, time_type)
     VALUES (1, '2017-06-26', '2020-01-01 19:14:51', '1900-01-01 00:25:00.0021425', '2007-05-10 10:00:20', '2017-06-26 09:54:21.325', '09:46:22');

    DROP TABLE IF EXISTS StringTypes;
    
    CREATE TABLE StringTypes (
        row_id INT PRIMARY KEY,
        varchar_type VARCHAR(255),
        char_type CHAR(4),
        text_type TEXT,
        nchar_type NCHAR(4),
        nvarchar_type NVARCHAR(10)
    );

    DROP TABLE IF EXISTS GeometricTypes;
    
    CREATE TABLE GeometricTypes (
        row_id INT PRIMARY KEY,
        point_type geometry,
        lineString_type geometry,
        geometry_type geometry,
        circularstring_type geometry,
        compoundcurve_type geometry,
        polygon_type geometry,
        curvepolygon_type geometry,
        multipolygon_type geometry,
        multilinestring_type geometry,
        multipoint_type geometry
    );

    DROP TABLE IF EXISTS MoneyTypes;
        
    CREATE TABLE MoneyTypes (
        row_id INT PRIMARY KEY,
        money_type money,
        smallmoney_type smallmoney 
    );

    `;
    _ = executeQuery("execute_params_db", query);
}  

isolated function createBatchExecuteDB() {
    _ = createQuery(`DROP DATABASE IF EXISTS BATCH_EXECUTE_DB`);
    _ = createQuery(`CREATE DATABASE BATCH_EXECUTE_DB`);

    sql:ParameterizedQuery query = `
    
    DROP TABLE IF EXISTS ExactNumeric;

    CREATE TABLE ExactNumeric(
    row_id INT PRIMARY KEY,
    bigint_type  bigint,
    numeric_type  numeric(10,5), 
    bit_type  bit, 
    smallint_type smallint, 
    decimal_type decimal(5,2), 
    smallmoney_type smallmoney,
    int_type int,
    tinyint_type tinyint,
    money_type money
    );

    INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, smallint_type, decimal_type, smallmoney_type, int_type, tinyint_type, money_type)
    VALUES(1, 9223372036854775807, 12.12000, 1, 32767, 123.00, 214748.3647, 2147483647, 255, 922337203685477.2807);

    DROP TABLE IF EXISTS StringTypes;
    
    CREATE TABLE StringTypes (
        row_id INT PRIMARY KEY,
        varchar_type VARCHAR(255),
        char_type CHAR(4),
        text_type TEXT,
        nchar_type NCHAR(4),
        nvarchar_type NVARCHAR(10)
    );

    DROP TABLE IF EXISTS GeometricTypes;
    
    CREATE TABLE GeometricTypes (
        row_id INT PRIMARY KEY,
        point_type geometry, 
        lineString_type geometry,
        geometry_type geometry,
        circularstring_type geometry,
        compoundcurve_type geometry,
        polygon_type geometry,
        curvepolygon_type geometry,
        multipolygon_type geometry,
        multilinestring_type geometry,
        multipoint_type geometry
    );

    DROP TABLE IF EXISTS MoneyTypes;
        
    CREATE TABLE MoneyTypes (
        row_id INT PRIMARY KEY,
        money_type money,
        smallmoney_type smallmoney 
    );
    `;
    _ = executeQuery("batch_execute_db", query);
}

isolated function simpleQueryInitDB() {
    _ = createQuery(`DROP DATABASE IF EXISTS SIMPLE_PARAMS_QUERY_DB`);
    _ = createQuery(`CREATE DATABASE SIMPLE_PARAMS_QUERY_DB`);

    sql:ParameterizedQuery query = `
    
    DROP TABLE IF EXISTS ExactNumeric;

    CREATE TABLE ExactNumeric(
    row_id INT PRIMARY KEY,
    bigint_type  bigint,
    numeric_type  numeric(10,5), 
    bit_type  bit, 
    smallint_type smallint, 
    decimal_type decimal(5,2), 
    smallmoney_type smallmoney,
    int_type INT,
    tinyint_type tinyint,
    money_type money
    );

    INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, bit_type, smallint_type, decimal_type, smallmoney_type, int_type, tinyint_type, money_type)
    VALUES(1, 9223372036854775807, 12.12000, 1, 32767, 123.41, 214748.3647, 2147483647, 255, 922337203685477.2807);

    DROP TABLE IF EXISTS ApproximateNumeric;

    CREATE TABLE ApproximateNumeric(
    row_id INT PRIMARY KEY,
    float_type float,  
    real_type real
    );

    INSERT INTO ApproximateNumeric (row_id, float_type, real_type) VALUES
    (1, 1.79E+308, -1.18E-38);

    DROP TABLE IF EXISTS DateandTime;

    CREATE TABLE DateandTime(
    row_id INT PRIMARY KEY,
    date_type  date, 
    dateTimeOffset_type  datetimeoffset,
    dateTime2_type datetime2, 
    smallDateTime_type smalldatetime, 
    dateTime_type datetime,
    time_type time
    );

    INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type , dateTime_type, time_type)
     VALUES (1, '2017-06-26', '2020-01-01 19:14:51 +05:30', '1900-01-01 00:25:00.0021425', '2007-05-10 10:00:20', '2017-06-26 09:54:21.325', '09:46:22');

    DROP TABLE IF EXISTS StringTypes;
    
    CREATE TABLE StringTypes (
        row_id INT PRIMARY KEY,
        varchar_type VARCHAR(255),
        char_type CHAR(14),
        text_type TEXT,
        nchar_type NCHAR(4),
        nvarchar_type NVARCHAR(10)
    );

    INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type) VALUES (1,'This is a varchar','This is a char','This is a long text','str4','str5');

    DROP TABLE IF EXISTS GeometricTypes;
    
    CREATE TABLE GeometricTypes (
        row_id INT PRIMARY KEY,
        point_type geometry,
        pointCol AS point_type.STAsText(), 
        lineString_type geometry,
        lineCol AS lineString_type.STAsText(),
    );

    INSERT INTO GeometricTypes (row_id, point_type) VALUES (1,'POINT (4 6)');

    `;
    _ = executeQuery("simple_params_query_db", query);
}  

isolated function complexQueryInitDB() {
    _ = createQuery(`DROP DATABASE IF EXISTS COMPLEX_QUERY_DB`);
    _ = createQuery(`CREATE DATABASE COMPLEX_QUERY_DB`);

    sql:ParameterizedQuery query = `
    
    DROP TABLE IF EXISTS ExactNumeric;

    CREATE TABLE ExactNumeric(
    row_id INT PRIMARY KEY,
    bigint_type  bigint,
    numeric_type  numeric(10,5), 
    smallint_type smallint, 
    decimal_type decimal(5,2), 
    int_type INT,
    tinyint_type tinyint,
    );

    INSERT INTO ExactNumeric (row_id, bigint_type, numeric_type, smallint_type, decimal_type, int_type, tinyint_type)
    VALUES(1, 9223372036854775807, 12.12000, 32767, 123.41, 2147483647, 255);

    INSERT INTO ExactNumeric (row_id)
    VALUES(2);

    DROP TABLE IF EXISTS ApproximateNumeric;

    CREATE TABLE ApproximateNumeric(
    row_id INT PRIMARY KEY,
    float_type float,  
    real_type real
    );

    INSERT INTO ApproximateNumeric (row_id, float_type, real_type) VALUES
    (1, 1.79E+308, -1.18E-38);

    DROP TABLE IF EXISTS DateandTime;

    CREATE TABLE DateandTime(
    row_id INT PRIMARY KEY,
    date_type  date, 
    dateTimeOffset_type  datetimeoffset,
    dateTime2_type datetime2, 
    smallDateTime_type smalldatetime, 
    dateTime_type datetime,
    time_type time
    );

    INSERT INTO DateandTime (row_id, date_type, dateTimeOffset_type, dateTime2_type, smallDateTime_type , dateTime_type, time_type)
     VALUES (1, '2017-06-26', '2020-01-01 19:14:51 +05:30', '1900-01-01 00:25:00.0021425', '2007-05-10 10:00:20', '2017-06-26 09:54:21.325', '09:46:22');

    DROP TABLE IF EXISTS StringTypes;
    
    CREATE TABLE StringTypes (
        row_id INT PRIMARY KEY,
        varchar_type VARCHAR(255),
        char_type CHAR(14),
        text_type TEXT
    );

    INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type) VALUES (1,'This is a varchar','This is a char','This is a long text');

     INSERT INTO StringTypes (row_id) VALUES (3);

    DROP TABLE IF EXISTS MoneyTypes;
        
    CREATE TABLE MoneyTypes (
        row_id INT PRIMARY KEY,
        money_type money,
        smallmoney_type smallmoney 
    );
    `;
    _ = executeQuery("complex_query_db", query);
}  

isolated function proceduresInit(){
    _ = createQuery(`DROP DATABASE IF EXISTS PROCEDURES_DB`);
    _ = createQuery(`CREATE DATABASE PROCEDURES_DB`);

    sql:ParameterizedQuery query1 = `

    CREATE PROCEDURE StringProcedure   
    @row_id_in int,
    @char_in char(14),
    @varchar_in varchar(255),
    @text_in text    
    AS   
    SET NOCOUNT ON
    INSERT INTO
    StringTypes ([row_id], [char_type], [varchar_type], [text_type]) 
    VALUES(
    @row_id_in, @char_in, @varchar_in, @text_in
    )

    `;
    
    sql:ParameterizedQuery query2 = `

    CREATE PROCEDURE ExactNumericProcedure   
    @row_id_in int, 
    @smallint_in smallint, 
    @int_in int, 
    @bigint_in bigint, 
    @decimal_in decimal(5,2), 
    @numeric_in numeric(10,5), 
    @tinyint_in tinyint
    AS   
    SET NOCOUNT ON
    INSERT INTO
    ExactNumeric ([row_id], [smallint_type], [int_type], [bigint_type], [decimal_type], [numeric_type], [tinyint_type]) 
    VALUES(
    @row_id_in, @smallint_in, @int_in, @bigint_in, @decimal_in, @numeric_in, @tinyint_in
    )

    `;

    sql:ParameterizedQuery query3 = `

    CREATE PROCEDURE DateTimeProcedure
    @row_id_in int,
    @date_type_in  date, 
    @dateTimeOffset_type_in  datetimeoffset,
    @dateTime2_type_in datetime2, 
    @smallDateTime_type_in smalldatetime, 
    @dateTime_type_in datetime,
    @time_type_in time
    AS   
    SET NOCOUNT ON
    INSERT INTO
    DateandTime ([row_id], [date_type], [dateTimeOffset_type], [dateTime2_type], [smallDateTime_type], [dateTime_type], [time_type])
    VALUES(
    @row_id_in, @date_type_in, @dateTimeOffset_type_in, @dateTime2_type_in, @smallDateTime_type_in,
    @dateTime_type_in, @time_type_in
    )

    `;

    sql:ParameterizedQuery query4 = `

    CREATE PROCEDURE ApproximateNumericProcedure
    @row_id_in int,
    @float_type_in float,  
    @real_type_in real
    AS   
    SET NOCOUNT ON
    INSERT INTO 
    ApproximateNumeric ([row_id], [float_type], [real_type]) 
    VALUES(
    @row_id_in, @float_type_in, @real_type_in
    )

    `;

    sql:ParameterizedQuery query5 = `

    CREATE PROCEDURE MoneyProcedure
    @row_id_in int,
    @money_type_in money,
    @smallmoney_type_in smallmoney 
    AS   
    SET NOCOUNT ON
    INSERT INTO 
    MoneyTypes ([row_id], [money_type], [smallMoney_type]) 
    VALUES(
    @row_id_in, @money_type_in,  @smallmoney_type_in
    )
    
    `;

    sql:ParameterizedQuery query6 = `

    CREATE PROCEDURE ExactNumericOutProcedure
    (@row_id_in int,
    @smallint_out smallint OUTPUT, 
    @int_out int OUTPUT, 
    @bigint_out bigint OUTPUT, 
    @tinyint_out tinyint OUTPUT,
    @decimal_out decimal(5,2) OUTPUT, 
    @numeric_out numeric(10,5) OUTPUT)
    AS
    SET NOCOUNT ON
    SELECT
    @smallint_out, 
    @int_out, 
    @bigint_out, 
    @tinyint_out,
    @decimal_out, 
    @numeric_out
    FROM
      ExactNumeric
    WHERE
      ExactNumeric.row_id = @row_id_in
    `;

    _ = executeQuery("complex_query_db", query1);
    _ = executeQuery("complex_query_db", query2);
    _ = executeQuery("complex_query_db", query3);
    _ = executeQuery("complex_query_db", query4);
    _ = executeQuery("complex_query_db", query5);
    _ = executeQuery("complex_query_db", query6);
}

isolated function sslConnectionInitDb() {
        _ = createQuery(`DROP DATABASE IF EXISTS SSL_CONNECT_DB`);
        _ = createQuery(`CREATE DATABASE SSL_CONNECT_DB`);
}


isolated function createQuery(sql:ParameterizedQuery query) {

    Client|sql:Error mssqlClient = new(user="sa",password="Test123#");

    if(mssqlClient is sql:Error) {
        io:println("Client init failed\n",mssqlClient);
    }
    else{
        sql:ExecutionResult|sql:Error result__;
        sql:Error? e__;

        result__ = mssqlClient->execute(query);
        if(result__ is sql:Error) {
            io:println("Init Database drop failed\n",result__);
        }
        else{
            io:println("Init Database drop passed\n",result__);
        }
        e__ = mssqlClient.close();

        if(e__ is sql:Error) {
            io:println("Client close failed\n",e__);
        }
        else{
            io:println("Client closed");
        }
    }

}

isolated function executeQuery(string database, sql:ParameterizedQuery query) {

    Client|sql:Error mssqlClient = new(user="sa",password="Test123#", database = database);

    if(mssqlClient is sql:Error) {
        io:println("Client init failed\n",mssqlClient);
    }
    else{
        sql:ExecutionResult|sql:Error result__;
        sql:Error? e__;

        result__ = mssqlClient->execute(query);
        if(result__ is sql:Error) {
            io:println("Init Execute drop failed\n",result__);
        }
        else{
            io:println("Init Execute drop passed\n",result__);
        }
        e__ = mssqlClient.close();

        if(e__ is sql:Error) {
            io:println("Client close1 failed\n",e__);
        }
        else{
            io:println("Client closed");
        }
    }
}
