CREATE TABLE vendors (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  contact_info TEXT
);

INSERT INTO vendors VALUES
(1, 'Samsung', 'contact@samsung.com'),
(2, 'Apple', 'contact@apple.com');

CREATE TABLE products (
  id INT PRIMARY KEY,
  name VARCHAR(255),
  price DECIMAL(10,2),
  description TEXT,
  vendor_id INT,
  FOREIGN KEY (vendor_id) REFERENCES vendors(id)
);

INSERT INTO products VALUES
(1001, 'Samsung Galaxy S24', 999.99, 'Flagship phone with AI camera', 1),
(1002, 'Apple iPhone 15 Pro', 1099.00, 'New titanium design', 2);

-- Enable CDC
EXEC sys.sp_cdc_enable_db;
EXEC sys.sp_cdc_enable_table 
@source_schema = 'dbo', 
@source_name = 'vendors', 
@role_name = NULL;

EXEC sys.sp_cdc_enable_table 
@source_schema = 'dbo', 
@source_name = 'products', 
@role_name = NULL;

-- Verify CDC is enabled
SELECT name, is_cdc_enabled FROM sys.databases WHERE name = 'store_db';