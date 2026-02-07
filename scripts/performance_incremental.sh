#!/bin/bash
set -e

echo "=== Olist dbt Incremental vs Full Refresh Benchmark ==="
echo "Date:       $(date '+%Y-%m-%d %H:%M:%S')"
echo "Branch:     $(git branch --show-current)"
echo "=================================================================="
echo ""

echo "1. Dependencies"
time dbt deps

echo ""
echo "2. Initial Load (Full Refresh - builds everything)"
time dbt run --full-refresh --select dim_customer dim_product dim_seller fct_order_items fct_orders

echo ""
echo "3. Incremental Run (processes only recent/overlapping data)"
time dbt run --select fct_order_items fct_orders

echo ""
echo "4. Reporting Views"
time dbt run --select rpt_daily_sales rpt_geography_insights rpt_monthly_sales_by_category

echo ""
echo "5. Tests"
time dbt test

echo ""
echo "=== Done ==="
echo "Focus on MiB processed in the logs — that's the real cost saving."
echo "Time differences are small/noisy due to tiny dataset + merge overhead."