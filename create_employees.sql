-- General Steps in the Query:
--    1. Create Table: The query begins by creating a new table called EMPLOYEE that stores employee details
--       such as their employee_id, first_name, last_name, job_title, and manager_id.
--    2. Insert Data into Table: Next, the query inserts several rows of data into the EMPLOYEE table.
--       Each row represents an employee and includes information about their job title and manager.

USE memory.default;

-- Create a table to store employee details.
CREATE TABLE EMPLOYEE (
    employee_id TINYINT,
    first_name VARCHAR,
    last_name VARCHAR,
    job_title VARCHAR,
    manager_id TINYINT
);

-- Insert data into the EMPLOYEE table.
INSERT INTO EMPLOYEE
    (employee_id, first_name, last_name, job_title, manager_id)
VALUES
    (1,'Ian','James','CEO',4),
    (2,'Umberto','Torrielli','CSO',1),
    (3,'Alex','Jacobson','MD EMEA',2),
    (4,'Darren','Poynton','CFO',2),
    (5,'Tim','Beard','MD APAC',2),
    (6,'Gemma','Dodd','COS',1),
    (7,'Lisa','Platten','CHR',6),
    (8,'Stefano','Camisaca','GM Activation',2),
    (9,'Andrea','Ghibaudi','MD NAM',2);
