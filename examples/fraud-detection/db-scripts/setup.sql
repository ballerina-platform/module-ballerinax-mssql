CREATE DATABASE finance_db;
USE finance_db;

-- Transactions table
CREATE TABLE transactions (
    tx_id INT Identity(1, 1) PRIMARY KEY,
    user_id INT,
    amount DECIMAL(10,2),
    status VARCHAR(50),
    created_at DATETIME
);

-- Sample data
INSERT INTO transactions (user_id, amount, status, created_at) VALUES
(10, 9000.00, 'COMPLETED', '2025-04-01 08:00:00'),
(11, 12000.00, 'COMPLETED', '2025-04-01 08:10:00'), -- this one should trigger fraud logic
(12, 4500.00, 'PENDING',   '2025-04-01 08:30:00');

-- Enable CDC
EXEC sys.sp_cdc_enable_db;
EXEC sys.sp_cdc_enable_table 
@source_schema = 'dbo', 
@source_name = 'transactions', 
@role_name = NULL;

-- Verify CDC is enabled
SELECT name, is_cdc_enabled FROM sys.databases WHERE name = 'finance_db';
