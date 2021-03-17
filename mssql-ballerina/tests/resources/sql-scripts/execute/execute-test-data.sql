CREATE DATABASE EXECUTE_DB;

USE EXECUTE_DB;

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

CREATE TABLE StringTypes (
      id INT PRIMARY KEY,
      varchar_type VARCHAR(255),
      char_type CHAR(4),
      text_type TEXT,
      nchar_type NCHAR(4),
      nvarchar_type NVARCHAR(10)
);

INSERT INTO StringTypes (id, varchar_type) VALUES (1, 'test data');

GO;
