-- General Steps in the Query:
--    1. Set Database Context: The query starts by specifying the memory catalog and default schema.
--    2. First Query: It calculates the number of employees in the EMPLOYEE table.
--       It defines the limit mentioned in the point 4.b.
--    3. User-Defined Function: A custom function cut_array_on_repeat_with_repeated_element is defined. It processes an
--       array of employee IDs to detect and cut repetitions but leaves the first occurrence of the repeated element.
--    4. Recursive CTE: The employee_hierarchy recursive CTE builds a hierarchy of employees and their managers.
--        a. Anchor Query: Retrieves the initial employees and sets the base case for recursion.
--        b. Recursive Query: Finds managers for employees, recursively following the hierarchy until a limit is reached.
--    5. Final Select: The query generates an ordered list of employee hierarchies and applies the custom function to
--       highlight looping points in the hierarchy. The result is grouped by employee and sorted.

USE memory.default;

-- Define the limit mentioned in the point 4.b.
SELECT COUNT(e.employee_id) FROM EMPLOYEE e;

WITH
    -- Custom function to handle repeated elements in an array.
    FUNCTION cut_array_on_repeat_with_repeated_element(arr ARRAY(VARCHAR))
    RETURNS ARRAY(VARCHAR)
    RETURN reduce(
        arr,
        -- Initial empty array.
        CAST(ARRAY[] AS ARRAY(VARCHAR)),
        (acc, element) -> IF(
            -- Check if the element is already in the accumulator.
            contains(acc, element),
            -- Append element and a stop marker '_STOP_'.
            IF(contains(acc, '_STOP_'), acc, CONCAT(acc, ARRAY[element], ARRAY['_STOP_'])),
            -- Append the element if it's not a duplicate.
            CONCAT(acc, ARRAY[element])
        ),
        -- Remove the '_STOP_' marker in the final array.
        acc -> filter(acc, x -> x != '_STOP_')
    )
-- Define the recursive CTE that builds the employee hierarchy.
WITH
    RECURSIVE employee_hierarchy (e_id, x, employee_id,  manager_id) AS (
    -- Anchor employee.
    SELECT employee_id, 0, employee_id, manager_id
    FROM EMPLOYEE

    UNION ALL

    -- Recursive query: For each employee, find their manager and recursively follow the hierarchy.
    SELECT
        -- Keep the reference to the base employee.
        e_id,
        -- Increment the recursion level to track depth in the hierarchy.
        x + 1,
        -- Get the employee ID of the manager.
        e.employee_id,
        -- Get the manager ID of the manager (to continue recursion).
        e.manager_id
    FROM EMPLOYEE e
    JOIN employee_hierarchy eh ON e.employee_id = eh.manager_id
    -- Limit recursion depth to avoid infinite loops; the limit is set based on the expected number of employees.
    WHERE x <= 9
)
-- Final SELECT statement: Retrieve the employee hierarchy and format it.
SELECT
    emp_h.e_id AS employee_id,
    -- Concatenate the employee IDs in the hierarchy into a comma-separated string.
    array_join(
        -- Apply the custom function to cut the hierarchy at the point where it loops.
        cut_array_on_repeat_with_repeated_element(
            CAST(
                -- Aggregate the employee IDs while preserving the order
                -- of the hierarchy (by recursion depth `emp_h.x`).
                ARRAY_AGG(emp_h.employee_id ORDER BY emp_h.x) AS ARRAY(VARCHAR))
        ), ','
    ) AS employee_ids
FROM employee_hierarchy emp_h
-- Group by base employee ID to ensure each employee's hierarchy is processed separately.
GROUP BY emp_h.e_id
-- Sort the results by employee ID for consistency and clarity.
ORDER BY emp_h.e_id;
