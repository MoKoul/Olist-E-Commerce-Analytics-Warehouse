
-- Order-item models/marts/sales/fct_order_items.sql

-- Fact table: Sales at order-item grain (one row per line item in an order)
-- 
-- Includes:
--   • item unit price & freight per order
--   • Aggregated payment value and installments (multiple payments per order possible)
--   • Average review score (multiple reviews per order possible)
--   • Key order timestamps and status
--   • Surrogate keys for all dimensions
--
-- Grain: order_id + order_item_id
-- Primary key: order_item_sk


with payments as (
    select
        order_id,
        sum(payment_value) as total_payment_value,      
        max(payment_installments) as max_installments
    from {{ ref('stg_olist__order_payments') }}
    group by 1
),

reviews as (
    select
        order_id,
        avg(review_score) as avg_review_score          
    from {{ ref('stg_olist__order_reviews') }}
    group by 1
)

select
    -- Primary key - grain of the fact-item table
    {{ dbt_utils.generate_surrogate_key(['oi.order_id', 'oi.order_item_id']) }} as order_item_sk,

    -- Foreign keys (point to dims)
    {{ dbt_utils.generate_surrogate_key(['oi.order_id'])}}                 as order_sk,
    {{ dbt_utils.generate_surrogate_key(['o.customer_unique_id']) }}      as customer_sk,
    {{ dbt_utils.generate_surrogate_key(['oi.seller_id']) }}              as seller_sk,
    {{ dbt_utils.generate_surrogate_key(['oi.product_id']) }}             as product_sk,
    format_date('%Y%m%d', date(o.order_purchase_timestamp))               as date_key,

    -- Measures
    oi.price                                                     as item_price,
    oi.freight_value                                             as order_shipping_cost_amount,
    coalesce(p.total_payment_value, 0)                           as customer_paid_amount,
    coalesce(p.max_installments, 0)                              as payment_installments_count,
    coalesce(r.avg_review_score, 0)                              as order_review_score_avg,

    -- Order status and timestamps
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_timestamp,
    o.order_delivered_carrier_timestamp,
    o.order_delivered_customer_timestamp,
    o.order_estimated_delivery_timestamp

from {{ ref('stg_olist__order_items') }} as oi
left join {{ ref('stg_olist__orders') }} as o          on oi.order_id = o.order_id
left join payments p                                   on oi.order_id = p.order_id
left join reviews r                                    on oi.order_id = r.order_id