-- Order-level summary: models/marts/sales/fct_orders.sql  
 
-- fct_orders: Order-grain fact table
--
-- Grain: One row per order (order_id / order_sk)
-- Purpose: Provides order-level metrics and summary flags for sales reporting and analysis.
--
-- Built by aggregating from fct_order_items (item-grain fact) and enriching with dim_customer.
--
-- Key business logic:
-- • Freight/shipping cost: Uses MAX() to de-duplicate (source duplicates order shipping across all items)
-- • Payment and review metrics: Carried forward from pre-aggregated values in fct_order_items
-- • Delivery performance: Includes is_delivered, is_late flags, and days_to_deliver
-- • Gross order value: item subtotal + shipping
-- • Sales attribution: counts_as_sale flag excludes canceled/incomplete orders


select
    -- Keys (from item fact)
    oi.order_sk,               -- This is order level not order-item level
    oi.customer_sk,
    oi.date_key,

    -- Customer geography (enriched)
    c.customer_state,
    c.customer_city,

    -- Order timestamps and status
    oi.order_status,
    oi.order_purchase_timestamp,
    oi.order_approved_timestamp,
    oi.order_delivered_carrier_timestamp,
    oi.order_delivered_customer_timestamp,
    oi.order_estimated_delivery_timestamp,

    -- Delivery flags
    oi.order_delivered_customer_timestamp is not null                                     as is_delivered,
    oi.order_delivered_customer_timestamp > oi.order_estimated_delivery_timestamp         as is_late,
    date_diff(oi.order_delivered_customer_timestamp, oi.order_purchase_timestamp, day)    as days_to_deliver,

    -- Measures
    count(*)                                                                 as order_item_count,
    sum(oi.item_price)                                                       as order_subtotal_amount,
    max(oi.order_shipping_cost_amount)                                       as order_shipping_cost_amount,
    sum(oi.item_price) + max(oi.order_shipping_cost_amount)                  as gross_order_value,
    max(oi.customer_paid_amount)                                             as customer_paid_amount,  
    max(oi.payment_installments_count)                                       as payment_installments_count,
    max(oi.order_review_score_avg)                                           as order_review_score_avg,

    -- Business flags
    countif(oi.order_status = 'canceled') > 0                                as was_canceled,
    countif(oi.order_status in ('delivered', 'shipped', 'invoiced')) > 0     as counts_as_sale

from {{ ref('fct_order_items') }} oi
left join {{ ref('dim_customer') }} c
        on oi.customer_sk = c.customer_sk
group by all   