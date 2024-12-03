WITH product_sales_by_region AS (
    SELECT
        s.state_of_issue,
        p.plan_code,
        p.product_group,
        p.product_line,
        p.sub_product_line,
        SUM(s.settled_count) AS total_settled_count,
        SUM(s.settled_sales_production) AS total_sales_production
    FROM {{ source('model_landing', 'sales') }} s
    LEFT JOIN {{ source('model_landing', 'products') }} p
        ON s.plan_code = p.plan_code
    GROUP BY 1, 2, 3, 4, 5
),
ranked_products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY state_of_issue
            ORDER BY total_settled_count DESC
        ) AS product_rank
    FROM product_sales_by_region
)
SELECT *
FROM ranked_products
