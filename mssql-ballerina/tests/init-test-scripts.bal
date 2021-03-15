import ballerina/io;
import ballerina/sql;

public function initTestScripts() {
    _ = createDatabases();
    // _ = initPool();
    _ = connectionInitDb();
}

public function createDatabases() {
     _ = createQuery(`DROP DATABASE IF EXISTS CONNECT_DB`);
     _ = createQuery(`CREATE DATABASE CONNECT_DB`);
    // _ = createQuery(`DROP DATABASE IF EXISTS POOL_DB_1`);
    // _ = createQuery(`CREATE DATABASE POOL_DB_1`);
    // _ = createQuery(`DROP DATABASE IF EXISTS POOL_DB_2`);
    // _ = createQuery(`CREATE DATABASE POOL_DB_2`);
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


public function createQuery(sql:ParameterizedQuery query) {

    Client|sql:Error mssqlClient = new(user="sa",password="Raji2098");

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
            io:println("Client close1 fail\n",e__);
        }
        else{
            io:println("Client close 1 pass");
        }
    }

}

public function executeQuery(string database, sql:ParameterizedQuery query) {

    Client|sql:Error mssqlClient = new(user="sa",password="Raji2098", database = database);

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
            io:println("Client close1 fail\n",e__);
        }
        else{
            io:println("Client close 1 pass");
        }
    }

}