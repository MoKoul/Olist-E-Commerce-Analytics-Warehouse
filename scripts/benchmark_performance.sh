#!/bin/bash

echo "=== Olist dbt Performance Benchmark ==="
echo "Date: $(date)"
echo "Branch: $(git branch --show-current)"
echo "========================================="
echo ""

echo "1. Running dbt deps..."
time dbt deps 2>&1

echo ""
echo "2. Running full refresh on core models..."
time dbt run --full-refresh --select fct_orders fct_order_items dim_customer dim_product dim_seller 2>&1

echo ""
echo "3. Running reporting views..."
time dbt run --select rpt_daily_sales rpt_geography_insights rpt_monthly_sales_by_category 2>&1

echo ""
echo "4. Running tests..."
time dbt test 2>&1

echo ""
echo "Note: For BigQuery bytes processed and estimated costs,"
echo "      check the BigQuery console → Jobs tab (last 10-30 min)"
echo "========================================="