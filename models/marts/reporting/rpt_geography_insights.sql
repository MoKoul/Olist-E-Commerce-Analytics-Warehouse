-- models/marts/reporting/rpt_geography_insights.sql

-- Sales, orders and customer by state and city

{{
    config(
        materialized = 'view',
        alias = 'rpt_geography_insights',
        schema = 'reporting'
    )
}}

select
    customer_state,
    customer_city,

    count(distinct customer_sk)                as total_customers,
    sum(order_item_count)                      as total_items_sold,
    count(order_sk)                            as total_orders,
    round(sum(order_subtotal_amount), 2)       as total_sales,
    round(sum(order_subtotal_amount) * 1.0 
                    / nullif(count(order_sk), 0), 2)      as aov     -- AOV average order value

from {{ ref('fct_orders') }}
group by customer_state, customer_city
order by total_sales desc 