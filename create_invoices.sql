-- General Steps in the Query:
--    1. Create Tables: Two tables are created: INVOICE to store details of supplier's invoices,
--       and SUPPLIER to store supplier information.
--    2. Insert Suppliers: A set of supplier names is inserted into the SUPPLIER table using
--       a WITH clause and a row_number function to generate unique supplier_id values.
--    3. Insert Invoices: A set of invoices is inserted into the INVOICE table,
--       linking them to the suppliers by their supplier_id, and calculating
--       the due date based on the current date and the specified number of months from now.

USE memory.default;

-- Create a table to store invoice information.
CREATE TABLE INVOICE (
    supplier_id TINYINT,
    -- There is a typo in the instruction, it should be invoice_amount,
    -- but I used invoice_ammount to be consistent with the README file.
    invoice_ammount DECIMAL(8, 2),
    due_date DATE
);

-- Create a table to store supplier information.
CREATE TABLE SUPPLIER (
    supplier_id TINYINT,
    name VARCHAR
);

-- Insert data into the SUPPLIER table.
INSERT INTO SUPPLIER (supplier_id, name)
WITH
    -- Temporary dataset to define suppliers and their invoice details.
    suppliers(company_name, amount, months_from_now) AS (
        VALUES
            ('Party Animals',6000,3),
            ('Catering Plus',2000,2),
            ('Catering Plus',1500,3),
            ('Dave''s Discos',500,1),
            ('Entertainment tonight',6000,3),
            ('Ice Ice Baby',4000,6)
) SELECT
    -- Generate unique supplier_id using row_number, ID should be ordered by the company name.
    row_number() OVER (ORDER BY company_name),
    company_name
-- Select distinct company names to avoid duplicates.
FROM (SELECT DISTINCT company_name FROM suppliers);

-- Insert data into the INVOICE table.
INSERT INTO INVOICE (supplier_id, invoice_ammount, due_date)
WITH
-- Temporary dataset to define suppliers, amounts, and due dates.
    suppliers(company_name, amount, months_from_now) AS (
        VALUES
            ('Party Animals',6000,3),
            ('Catering Plus',2000,2),
            ('Catering Plus',1500,3),
            -- Double single quotes are used to escape single quote in Trino.
            ('Dave''s Discos',500,1),
            ('Entertainment tonight',6000,3),
            ('Ice Ice Baby',4000,6)
)
-- Select supplier_id, invoice_ammount, and due_date for insertion into the INVOICE table
SELECT
    SUPPLIER.supplier_id,
    amount,
    -- Calculate due date by adding the specified months to the current date.
    -- By last_day_of_month function calculate the last day of the month.
    last_day_of_month(date_add('month', months_from_now, current_date))
FROM suppliers
LEFT JOIN SUPPLIER ON suppliers.company_name = SUPPLIER.name;
