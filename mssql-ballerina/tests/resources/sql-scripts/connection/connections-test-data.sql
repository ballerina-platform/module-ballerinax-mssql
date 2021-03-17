CREATE DATABASE CONNECT_DB;
GO

USE CONNECT_DB;
GO

DROP TABLE IF EXISTS Customers;

CREATE TABLE Customers(
          customerId INT NOT NULL IDENTITY PRIMARY KEY,
          firstName  VARCHAR(300),
          lastName  VARCHAR(300),
          registrationID INTEGER,
          creditLimit FLOAT,
          country  VARCHAR(300),
);

INSERT INTO Customers (firstName,lastName,registrationID,creditLimit,country)
                VALUES ('Peter', 'Stuart', 1, 5000.75, 'USA');

GO
