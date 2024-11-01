-- this is an example dbt model that shows the total sales and avg sales by reporting group company
{{
  config(
    materialized = 'table',
    alias = 'example',
    schema = 'gold'
  )
}}

WITH company_sales AS (
  SELECT
    reporting_group_company_level,
    SUM(s.settled_sales_production)                                         AS total_sales,
    AVG(s.settled_sales_production)                                         AS avg_sales_per_transaction
  FROM
    {{ ref('sales') }} s
    JOIN {{ ref('clubs') }} c
      ON s.club_code = c.club_code
      AND s.state_of_issue = c.state
  GROUP BY 1
)

SELECT
  company_sales.*,
  NOW()                                                                 AS last_refreshed_at
FROM company_sales