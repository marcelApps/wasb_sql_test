--General Steps in the Query:
--    1. Set Database Context: The query starts by selecting the memory database and the default schema to use.
--    2. Recursive CTE Definition: The WITH RECURSIVE clause defines a CTE that generates monthly payment schedules for invoices.
--        a. Anchor Query: This part fetches the initial invoice data.
--        b. Recursive Query: This part calculates subsequent monthly payments, recursively reducing the balance until the final payment.
--    3. Final Select and Aggregation: The main query selects and aggregates the monthly payment amounts and outstanding
--       balances for each supplier, grouped by the supplier and payment month.

USE memory.default;

WITH
    RECURSIVE invoices_per_month (s_id, s_name, next_month, instalment_amount, balance_outstanding, instalments_to_end) AS (
    -- Anchor parent invoice.
    SELECT
        inv.supplier_id,
        sup.name,
        -- Set the last day of the current month as the first payment date.
        last_day_of_month(current_date),
        -- Calculate the monthly instalment amount: the total invoice amount divided by the number of instalments,
        -- which means months diff between current month and the invoice's due date + 1 (add current month).
        CAST(inv.invoice_ammount/(date_diff('month', last_day_of_month(current_date), inv.due_date) + 1)AS DECIMAL(8, 2)) AS instalment_amount,
        -- Calculate the initial outstanding balance by subtracting the first instalment from the total invoice amount.
        CAST(inv.invoice_ammount AS DECIMAL(8, 2)) - inv.invoice_ammount/(date_diff('month', last_day_of_month(current_date), inv.due_date) + 1) AS balance_outstanding,
        -- Calculate the total number of instalments left until the due date.
        date_diff('month', last_day_of_month(current_date), inv.due_date) as instalments_to_end
    FROM INVOICE inv
    -- Join the supplier table to get the supplier's name.
    JOIN SUPPLIER sup ON sup.supplier_id = inv.supplier_id

    UNION ALL

    -- Recursive query: Generate the subsequent instalments for each invoice.
    SELECT
        ipm.s_id,
        ipm.s_name,
        -- Calculate the next payment date by moving to the last day of the next month.
        last_day_of_month(ipm.next_month + interval '1' month),
        CASE
            -- For the final instalment, the payment is the remaining balance.
            WHEN instalments_to_end = 1 THEN CAST(ipm.balance_outstanding AS DECIMAL(8, 2))
            -- Otherwise, it's the same monthly instalment amount.
            ELSE ipm.instalment_amount
        END AS instalment_amount,
        -- Calculate the updated balance for the next month.
        CASE
            -- If this is the final payment, the outstanding balance becomes 0.
            WHEN ipm.instalments_to_end = 1 THEN CAST(0 AS DECIMAL(8, 2))
            -- Otherwise, reduce the outstanding balance by the instalment amount.
            ELSE CAST(ipm.balance_outstanding - ipm.instalment_amount AS DECIMAL(8, 2))
        END AS balance_outstanding,
        -- Decrement the number of instalments remaining.
        ipm.instalments_to_end - 1 AS instalments_to_end
    FROM invoices_per_month ipm
    -- Continue the recursion as long as there are any instalments left.
    WHERE instalments_to_end > 0
)
-- Final SELECT statement: Retrieve and aggregate the payment schedule.
SELECT
    ipm.s_id AS SUPPLIER_ID,
    ipm.s_name AS SUPPLIER_NAME,
    -- Sum up the payments due in that month.
    sum(ipm.instalment_amount) AS PAYMENT_AMOUNT,
    -- Sum up the remaining balance in that month.
    sum(ipm.balance_outstanding) AS BALANCE_OUTSTANDING,
    ipm.next_month AS PAYMENT_DATE
FROM invoices_per_month ipm
-- Group by supplier and payment date to aggregate payments by month and supplier.
GROUP BY ipm.s_id, ipm.s_name, ipm.next_month
-- Order the results by supplier ID and payment date in ascending order.
ORDER BY SUPPLIER_ID, PAYMENT_DATE;
