-- models/marts/reporting/rpt_monthly_sales_by_category.sql

-- Monthly sales by product category (English names)
-- Grain: one row per category per month
-- total_items = actual units sold (each item row in fct_order_items = 1 unit)

{{ config(
    materialized = 'view',
    alias = 'rpt_monthly_sales_by_category',
    schema = 'reporting'
) }}

select
    order_purchase_ym                                                      as order_YearMonth,
    coalesce(p.product_category_name_english, 'Unknown'  )                 as category_english,
    count(distinct oi.order_sk)                                            as total_orders,
    count(oi.order_item_sk)                                                as total_items,                                   
    round(sum(oi.item_price) , 2)                                           as total_sales,
    round(sum(oi.item_price) * 1.0 
                / nullif(count(distinct oi.order_sk), 0), 2)               as aov      -- AOV average order value by category
from {{ref('fct_order_items')}} oi
left join {{ref('dim_product')}} p
  on  oi.product_sk = p.product_sk
group by order_YearMonth, category_english
order by order_YearMonth desc, total_sales desc 

