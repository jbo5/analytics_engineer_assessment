# AAA Life Insurance Analytics Engineer Assessment

## Overview
This technical assessment evaluates your ability to work with dbt and solve real-world data engineering challenges. You'll be working with insurance sales data to create analytical models that provide business insights.

## Contact Information
For technical assistance, please contact:  
**Technical Lead:** JBickmeyer@aaalife.com

## Environment Setup

### Prerequisites
- Docker installed on your local machine
- SQL IDE (recommended: [DBeaver](https://dbeaver.io/))

### Installation Steps
1. Unzip the assessment project to your local machine
2. Open the project directory in your preferred text editor
3. From terminal, navigate to the project's root directory
4. Execute the following commands:
```bash
docker compose up -d --build
docker exec -it analytics_engineer_assessment-dbt-1 /bin/bash
```
5. Verify setup with `dbt debug`
6. Load seed data with `dbt seed`

### Database Configuration
The assessment uses a PostgreSQL database with the following credentials:

| Parameter | Value |
|-----------|-------|
| Database | dbt_db |
| Username | dbt_user |
| Password | dbt_password |
| Host | localhost |
| Port | 5432 |

## Technical Assessment

### Project Structure
Database Schema

### Requirements

**1. Data Quality: Lead Sources Deduplication**
- Create a dbt model `lead_sources` in the `staging` schema
- Remove duplicate records from the lead_sources landing table
- Ensure uniqueness at the `lead_source_code` grain
- Implement appropriate testing to maintain data integrity

**2. Sales Analysis: Weekly Trends**
- Create a dbt model `company_sales` in the `gold` schema
- Aggregate sales metrics by week:
  - `settled_count`
  - `settled_sales_production`
- Include key dimensions:
  - `reporting_group_company_level`
  - `product_group`
  - `product_line`
  - `sub_product_line`
  - `response_channel`
  - `response_channel_category`

**3. Regional Product Analysis**
- Design a model analyzing product popularity by region
- Key metrics:
  - Number of policies sold (`settled_count`)
  - Total sales amount (`settled_sales_production`)
  - Product popularity ranking by region
- Requirements:
  - Rank products within each `state_of_issue`
  - No tied rankings within regions
  - Most popular product receives rank 1

## Technical Notes
- The environment consists of two Docker containers:
  - dbt project container
  - PostgreSQL database container
- Seed data will be loaded into the `model_landing` schema
- All models should follow dbt best practices and include appropriate documentation