-- models/marts/reporting/rpt_daily_sales.sql

-- Report daily sales  

{{config( materialized = 'view', 
          alias = 'rpt_daily_sales', 
          schema = 'reporting'
          )}}

select
    date(order_purchase_timestamp)                            as order_date,
    count( order_sk)                                          as total_orders,
    sum(order_item_count)                                     as total_items_sold,
    round(sum(order_subtotal_amount), 2)                      as total_sales,
    round(avg(order_subtotal_amount), 2)                      as aov,                   -- AOV: average order value
    count(case when is_delivered then 1 end)                  as delivered_orders_count,
    count(case when is_late then 1 end)                       as late_orders_count,
    round(count(case when is_late then 1 end) * 100.0 
          / nullif(count(case when is_delivered then 1 end), 0), 2) as late_delivery_pct, 
    round(avg(order_review_score_avg) , 2)                     as daily_review_score_avg
from {{ref('fct_orders')}}
group by order_date
order by order_date desc


