-- General Steps in the Query:
--    1. Main Query: The query retrieves employee information, such as employee name, manager name, and the total expensed amount,
--       by joining data from the EMPLOYEE table and expense table.
--    2. Employee Name Construction: The employee’s and manager’s full names are generated using the CONCAT function.
--    3. Left Join on Manager: A LEFT JOIN is performed to associate each employee with their manager.
--       If a manager doesn't exist, the query still includes the employee.
--    4. Join with Expense Data: A subquery calculates the total expenses per employee and filters employees
--       with total expenses greater than 1000. The main query joins this result with the employee data.
--    5. Final Output: The results are ordered by the total expensed amount in descending order.

USE memory.default;

SELECT
    -- Concatenate first and last name to get the full name of the employee.
    e.employee_id, CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    -- Get the manager's employee_id and concatenate their first and last name to get the full name of the manager.
    e.manager_id,  CONCAT(e_m.first_name, ' ', e_m.last_name) AS manager_name,
    -- Display the total amount expensed by the employee, calculated in the subquery below.
    e_exp.total AS total_expensed_amount
FROM EMPLOYEE e
-- LEFT JOIN: Get the manager’s details for each employee. If the employee has no manager, this still includes the employee.
LEFT JOIN EMPLOYEE e_m ON e.manager_id = e_m.employee_id
-- Subquery: Join with employees who have expensed more than 1000 in total.
JOIN
    (   -- Subquery that calculates total expenses per employee.
        SELECT
            exp.employee_id,
            -- Calculate the total amount expensed by multiplying unit price and quantity, and summing the result.
            SUM(exp.unit_price*exp.quantity) AS total
        FROM expense exp
        -- Group by employee to aggregate their total expenses.
        GROUP BY exp.employee_id
        -- Filter: Include only employees who have expensed more than 1000 in total.
        HAVING SUM(exp.unit_price*exp.quantity) > 1000
    ) AS e_exp
    ON e_exp.employee_id = e.employee_id
    -- Order the results by the total expensed amount in descending order, so that employees with the highest expenses appear first.
ORDER BY total_expensed_amount DESC;
