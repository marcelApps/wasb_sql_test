--General Steps in the Query:
--    1. Create Table: The query begins with the creation of a new table called EXPENSE that stores expense details for employees.
--       This includes the employee_id who made the expense, the unit_price of the item, and the quantity of units.
--    2. Insert Data into Table: Then the query inserts several rows of data into the EXPENSE table,
--       representing the expenses incurred by various employees.

USE memory.default;

-- Create a table to store expense details for employees.
CREATE TABLE EXPENSE (
    employee_id TINYINT,
    unit_price DECIMAL(8, 2),
    quantity TINYINT
);

-- Insert data into the EXPENSE table.
INSERT INTO EXPENSE
    (employee_id, unit_price, quantity)
VALUES
    (3,6.50,14),
    (3,11.00,20),
    (3,22.00,18),
    (3,13.00,75),
    (9,300,1),
    (4,40.00,9),
    (2,17.50,4);
