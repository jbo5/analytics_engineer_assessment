WITH weekly_sales AS (
    SELECT
        DATE_TRUNC('week', transaction_date::date)::date AS week_start,
        c.reporting_group_company_level,
        p.product_group,
        p.product_line,
        p.sub_product_line,
        ls.response_channel,
        ls.response_channel_category,
        SUM(s.settled_count) AS total_settled_count,
        SUM(s.settled_sales_production) AS total_sales_production
    FROM {{ source('model_landing', 'sales') }} s
    LEFT JOIN {{ source('model_landing', 'products') }} p
        ON s.plan_code = p.plan_code
    LEFT JOIN {{ source('model_landing', 'clubs') }} c
        ON s.club_code = c.club_code
        AND s.state_of_issue = c.state
    LEFT JOIN {{ ref('stg_lead_sources') }} ls
        ON s.lead_source_code = ls.lead_source_code
    GROUP BY
        DATE_TRUNC('week', transaction_date::date)::date,
        c.reporting_group_company_level,
        p.product_group,
        p.product_line,
        p.sub_product_line,
        ls.response_channel,
        ls.response_channel_category
)
SELECT *
FROM weekly_sales
