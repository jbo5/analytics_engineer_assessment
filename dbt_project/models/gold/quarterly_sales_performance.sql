/*WITH quarterly_sales AS (
    SELECT
        DATE_TRUNC('quarter', transaction_date::date)::date AS quarter_start,
        p.product_line,
        SUM(s.settled_count) AS total_settled_count,
        SUM(s.settled_sales_production) AS total_sales_production
    FROM {{ source('model_landing', 'sales') }} s
    LEFT JOIN {{ source('model_landing', 'products') }} p
        ON s.plan_code = p.plan_code
    GROUP BY 1, 2
),
average_sales AS (
    SELECT
        q.product_line,
        AVG(q.total_sales_production) AS avg_quarterly_sales
    FROM quarterly_sales q
    GROUP BY q.product_line
),
rolling_4q_avg AS (
    SELECT
        q.product_line,
        q.quarter_start,
        AVG(q.total_sales_production) OVER (
            PARTITION BY q.product_line
            ORDER BY q.quarter_start
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS rolling_4q_sales_avg
    FROM quarterly_sales q
),
final_calculations AS (
    SELECT
        q.product_line,
        q.quarter_start,
        q.total_settled_count,
        q.total_sales_production,
        r.rolling_4q_sales_avg,
        a.avg_quarterly_sales,
        (q.total_sales_production - LAG(q.total_sales_production) OVER (
            PARTITION BY q.product_line
            ORDER BY q.quarter_start
        )) / NULLIF(LAG(q.total_sales_production) OVER (
            PARTITION BY q.product_line
            ORDER BY q.quarter_start
        ), 0) * 100 AS qoq_growth_percentage
    FROM quarterly_sales q
    LEFT JOIN rolling_4q_avg r
        ON q.product_line = r.product_line
        AND q.quarter_start = r.quarter_start
    LEFT JOIN average_sales a
        ON q.product_line = a.product_line
)
SELECT *
FROM final_calculations
ORDER BY product_line, quarter_start
*/

WITH all_quarters AS (
    -- Generate a list of all quarters in the range of sales data
    SELECT DISTINCT
        DATE_TRUNC('quarter', transaction_date::date)::date AS quarter_start
    FROM {{ source('model_landing', 'sales') }}
),
all_product_lines AS (
    -- Get a distinct list of product lines
    SELECT DISTINCT
        product_line
    FROM {{ source('model_landing', 'products') }}
),
quarter_product_combinations AS (
    -- Create all combinations of quarters and product lines
    SELECT
        q.quarter_start,
        p.product_line
    FROM all_quarters q
    CROSS JOIN all_product_lines p
),
quarterly_sales AS (
    -- Join the combinations with sales data to include all quarters and product lines
    SELECT
        qp.quarter_start,
        qp.product_line,
        COALESCE(SUM(s.settled_count), 0) AS total_settled_count,
        COALESCE(SUM(s.settled_sales_production), 0) AS total_sales_production
    FROM quarter_product_combinations qp
    LEFT JOIN {{ source('model_landing', 'sales') }} s
        ON DATE_TRUNC('quarter', s.transaction_date::date) = qp.quarter_start
    LEFT JOIN {{ source('model_landing', 'products') }} p
        ON s.plan_code = p.plan_code
       AND p.product_line = qp.product_line
    GROUP BY 1, 2
),
average_sales AS (
    -- Calculate the average quarterly sales per product line
    SELECT
        q.product_line,
        AVG(q.total_sales_production) AS avg_quarterly_sales
    FROM quarterly_sales q
    GROUP BY q.product_line
),
rolling_4q_avg AS (
    -- Calculate the rolling 4-quarter average sales per product line
    SELECT
        q.product_line,
        q.quarter_start,
        AVG(q.total_sales_production) OVER (
            PARTITION BY q.product_line
            ORDER BY q.quarter_start
            ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
        ) AS rolling_4q_sales_avg
    FROM quarterly_sales q
),
final_calculations AS (
    -- Final calculations, including QoQ growth and other metrics
    SELECT
        q.product_line,
        q.quarter_start,
        q.total_settled_count,
        q.total_sales_production,
        r.rolling_4q_sales_avg,
        a.avg_quarterly_sales,
        (q.total_sales_production - LAG(q.total_sales_production) OVER (
            PARTITION BY q.product_line
            ORDER BY q.quarter_start
        )) / NULLIF(LAG(q.total_sales_production) OVER (
            PARTITION BY q.product_line
            ORDER BY q.quarter_start
        ), 0) * 100 AS qoq_growth_percentage
    FROM quarterly_sales q
    LEFT JOIN rolling_4q_avg r
        ON q.product_line = r.product_line
        AND q.quarter_start = r.quarter_start
    LEFT JOIN average_sales a
        ON q.product_line = a.product_line
)
SELECT *
FROM final_calculations
ORDER BY product_line, quarter_start

