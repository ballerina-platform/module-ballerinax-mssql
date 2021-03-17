import ballerina/io;
import ballerina/sql;

public function initTestScripts() {
    _ = createDatabases();
    _ = basicExcuteInitDB();
    _ = initPool();
    _ = connectionInitDb();
    _ = executeParamsInitDB();
    _ = simpleQueryInitDB();
}

public function createDatabases() {
    _ = createQuery(`DROP DATABASE IF EXISTS CONNECT_DB`);
    _ = createQuery(`CREATE DATABASE CONNECT_DB`);
    _ = createQuery(`DROP DATABASE IF EXISTS POOL_DB_1`);
    _ = createQuery(`CREATE DATABASE POOL_DB_1`);
    _ = createQuery(`DROP DATABASE IF EXISTS POOL_DB_2`);
    _ = createQuery(`CREATE DATABASE POOL_DB_2`);
    _ = createQuery(`DROP DATABASE IF EXISTS EXECUTE_DB`);
    _ = createQuery(`CREATE DATABASE EXECUTE_DB`);
    _ = createQuery(`DROP DATABASE IF EXISTS EXECUTE_PARAMS_DB`);
    _ = createQuery(`CREATE DATABASE EXECUTE_PARAMS_DB`);
    _ = createQuery(`DROP DATABASE IF EXISTS SIMPLE_PARAMS_QUERY_DB`);
    _ = createQuery(`CREATE DATABASE SIMPLE_PARAMS_QUERY_DB`);
}

public function connectionInitDb() {
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

            DROP DATABASE IF EXISTS SSL_CONNECT_DB;
            CREATE DATABASE SSL_CONNECT_DB;
        
        `;
        _ = executeQuery("connect_db", q2);
}

function initPool() {
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

public function basicExcuteInitDB() {

    sql:ParameterizedQuery q5 = `
            DROP TABLE IF EXISTS ExactNumericTypes;

            CREATE TABLE ExactNumericTypes (
                id INT NOT NULL IDENTITY PRIMARY KEY,
                smallint_type SMALLINT,
                int_type INT,
                tinyint_type TINYINT,
                bigint_type BIGINT,
                decimal_type DECIMAL,
                numeric_type NUMERIC,
                real_type REAL,
                float_type FLOAT
            );

            INSERT INTO ExactNumericTypes (int_type) VALUES (10);

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
            
        `;

    _ = executeQuery("execute_db", q5);

}

public function executeParamsInitDB() {
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
    Date_col  date, 
    DateTimeOffset_col  datetimeoffset,
    DateTime2_col datetime2, 
    SmallDateTime_col smalldatetime, 
    DateTime_col datetime,
    Time_col time
    );

    INSERT INTO DateandTime (row_id, Date_col, DateTimeOffset_col, DateTime2_col, SmallDateTime_col , DateTime_col, Time_col)
     VALUES (1, '2017-06-26', '2020-01-01 19:14:51', '1900-01-01 00:25:00.0021425', '2007-05-10 10:00:20', '2017-06-26 09:54:21.325', '09:46:22');

    DROP TABLE IF EXISTS StringTypes;
    
    CREATE TABLE StringTypes (
        raw_id INT PRIMARY KEY,
        varchar_type VARCHAR(255),
        char_type CHAR(4),
        text_type TEXT,
        nchar_type NCHAR(4),
        nvarchar_type NVARCHAR(10)
    );

    `;
    _ = executeQuery("execute_params_db", query);
}  

public function simpleQueryInitDB() {
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
    Date_col  date, 
    DateTimeOffset_col  datetimeoffset,
    DateTime2_col datetime2, 
    SmallDateTime_col smalldatetime, 
    DateTime_col datetime,
    Time_col time
    );

    INSERT INTO DateandTime (row_id, Date_col, DateTimeOffset_col, DateTime2_col, SmallDateTime_col , DateTime_col, Time_col)
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

    INSERT INTO StringTypes (row_id, varchar_type, char_type, text_type, nchar_type, nvarchar_type) VALUES (1,'str1','str2','assume a long text','str4','str5');

    `;
    _ = executeQuery("simple_params_query_db", query);
}  


public function createQuery(sql:ParameterizedQuery query) {

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

public function executeQuery(string database, sql:ParameterizedQuery query) {

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
