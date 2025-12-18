# Olist E-Commerce Analytics Warehouse

**A dbt project transforming the public Olist Brazilian E-Commerce dataset into a clean, tested, Kimball-style star schema on Google BigQuery.**

[![dbt](https://img.shields.io/badge/dbt-1.10.15-orange)](https://docs.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-blue)](https://cloud.google.com/bigquery)
[![Looker Ready](https://img.shields.io/badge/Looker-Ready-green)](https://cloud.google.com/looker)

**Live Documentation**: Full interactive docs (lineage graph, models, tests):  
[https://mokoul.github.io/Olist-E-Commerce-Analytics-Warehouse/](https://mokoul.github.io/Olist-E-Commerce-Analytics-Warehouse/)    
**Local Docs**: Run `dbt docs generate` → open `target/index.html`  
**Data Source**: [Olist Brazilian E-Commerce Public Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Project Overview

This project demonstrates modern analytics engineering best practices using **dbt Core** on **Google BigQuery**.

It transforms raw CSV tables into a fully documented, tested, and BI-ready data warehouse with:
- Clean staging layer
- Core dimensions and facts (marts)
- Dedicated reporting views

The model handles data challenges such as cleaning and uploading data to BigQuery, duplicated freight values,  and inconsistent geolocation data.


## Architecture


```text
BigQuery Project: olist-warehouse
├── raw_olist_data/                ← Raw tables (CSV loads)
└── dwh_olist/                     ← All dbt-built models
│    ├── stg_olist__customers
│    ├── stg_olist__products
│    ├── stg_olist__orders
│    ├── stg_olist__sellers
│    ├── stg_olist__order_items
│    ├── stg_olist__geolocation
│    ├── stg_olist__order_payments
│    ├── stg_olist__order_reviews
│    ├── stg_olist__category_translation
│    ├── dim_customer
│    ├── dim_product
│    ├── dim_seller
│    ├── dim_date
│    ├── fct_order_items            ← Item-grain fact
│    ├── fct_orders                 ← Order-grain fact
└── dwh_olist_reporting/
     ├── rpt_daily_sales            ← Reporting views
     ├── rpt_geography_insights
     └── rpt_monthly_sales_by_category 
```  

## Data Preparation

Raw data often requires preprocessing for warehouse compatibility. This project includes:

- `notebooks/clean_order_reviews.ipynb`: A Jupyter notebook using Pandas to clean the `olist_order_reviews_dataset.csv`. It removes all special characters except for alphanumeric text, commas, and periods from comment fields (e.g., titles and messages) to prevent BigQuery import errors, converts timestamps to datetime, and exports a revised CSV.(`revised_olist_order_reviews_dataset.csv`) ready for  uploading in BigQuery.


## Key Features & Best Practices

- **Staging**: Light cleaning, consistent naming, source freshness monitoring
- **Surrogate keys**: Deterministic hashes via `dbt_utils.generate_surrogate_key`
- **Freight handling**: Correctly uses `MAX()` to de-duplicate order shipping cost

- **Geography enrichment**: Joins geolocation table for city/state/lat/lng
- **Comprehensive testing** (50+ tests, all passing):
  - Primary Key uniqueness & not_null
  - Foreign key relationships
  - Accepted values (status, flags)
  - Business logic (gross value ≥ 0, item count ≥ 1)
- **Full documentation**: Model and column descriptions, interactive lineage graph
- **Layer separation**: Core marts as tables, reporting as views in dedicated schema

![Lineage DAG](visualizations/Lineage_DAG.png)

## Reporting Views (BI-Ready)

| View                          | Description |
|-------------------------------|-----------|
| `rpt_daily_sales`             | Daily orders, revenue, Average Order Value (AOV), late delivery %, average review score |
| `rpt_geography_insights`      | Sales, orders, customers by state and city — ideal for maps |
| `rpt_monthly_sales_by_category` | Monthly revenue and units sold by product category (English names) |


## Looker Dashboard (Powered by this dbt project)

A sample executive sales dashboard built in Looker Studio, leveraging the reporting views (`rpt_*`) for insights like total sales, sales trends, category breakdowns, and geography.

![Olist Sales Dashboard 2016-2018](visualizations/dashboard_screenshot.png)

## License
This project is licensed under the MIT License.