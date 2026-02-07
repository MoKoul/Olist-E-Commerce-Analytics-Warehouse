-- models/staging/olist/stg_olist__orders.sql

{{
    config(
        materialized = 'table',
        partition_by = {
            "field": "order_purchase_date",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by = ["order_status"]
    )
}}



select
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,

    -- Order Date for partitioning
    cast(o.order_purchase_timestamp as date)                    as order_purchase_date,

    o.order_purchase_timestamp           as order_purchase_timestamp,
    o.order_approved_at                  as order_approved_timestamp,
    o.order_delivered_carrier_date       as order_delivered_carrier_timestamp,
    o.order_delivered_customer_date      as order_delivered_customer_timestamp,
    o.order_estimated_delivery_date      as order_estimated_delivery_timestamp
from {{ source('olist', 'orders') }}  o
left join {{ source('olist', 'customers') }} as c on o.customer_id = c.customer_id