-- models/staging/olist/stg_olist__orders.sql

select
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    o.order_status,
    o.order_purchase_timestamp           as order_purchase_timestamp,
    o.order_approved_at                  as order_approved_timestamp,
    o.order_delivered_carrier_date       as order_delivered_carrier_timestamp,
    o.order_delivered_customer_date      as order_delivered_customer_timestamp,
    o.order_estimated_delivery_date      as order_estimated_delivery_timestamp
from {{ source('olist', 'orders') }}  o
left join {{ source('olist', 'customers') }} as c on o.customer_id = c.customer_id