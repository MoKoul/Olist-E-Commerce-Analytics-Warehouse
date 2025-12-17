# Olist E-Commerce Analytics Warehouse

**A dbt project transforming the public Olist Brazilian E-Commerce dataset into a clean, tested, Kimball-style star schema on Google BigQuery.**

[![dbt](https://img.shields.io/badge/dbt-1.10-orange)](https://docs.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-blue)](https://cloud.google.com/bigquery)
[![Looker Ready](https://img.shields.io/badge/Looker-Ready-green)]()

**Live Documentation**: [https://github.com/MoKoul/Olist-E-Commerce-Analytics-Warehouse](https://github.com/MoKoul/Olist-E-Commerce-Analytics-Warehouse)  
**Local Docs**: Run `dbt docs generate` → open `target/index.html`  
**Data Source**: [Olist Brazilian E-Commerce Public Dataset (Kaggle)](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Project Overview

This project demonstrates modern analytics engineering best practices using **dbt Core** on **Google BigQuery**.

It transforms raw CSV tables into a fully documented, tested, and BI-ready data warehouse with:
- Clean staging layer
- Core dimensions and facts (marts)
- Dedicated reporting views

The model handles real-world data challenges such as duplicated freight values, multiple `customer_id`s per person, and inconsistent geolocation data.


## Architecture


```text
BigQuery Project: olist-warehouse
├── raw_olist_data/                ← Raw untouched tables (CSV loads)
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



## Key Features & Best Practices

- **Staging**: Light cleaning, consistent naming, source freshness monitoring
- **Surrogate keys**: Deterministic hashes via `dbt_utils.generate_surrogate_key`
- **Freight handling**: Correctly uses `MAX()` to de-duplicate total order shipping cost
- **Customer deduplication**: Uses `customer_unique_id` as natural key
- **Geography enrichment**: Joins geolocation table for city/state/lat/lng
- **Comprehensive testing** (50+ tests, all passing):
  - PK uniqueness & not_null
  - Foreign key relationships
  - Accepted values (status, flags)
  - Business logic (gross value ≥ 0, item count ≥ 1)
- **Full documentation**: Model and column descriptions, interactive lineage graph
- **Layer separation**: Core marts as tables, reporting as views in dedicated schema

## Reporting Views (BI-Ready)

| View                          | Description |
|-------------------------------|-----------|
| `rpt_daily_sales`             | Daily orders, revenue, AOV, late delivery %, average review score |
| `rpt_geography_insights`      | Sales, orders, customers by state and city — ideal for maps |
| `rpt_monthly_sales_by_category` | Monthly revenue and units sold by product category (English names) |
