
-- models/staging/olist/stg_olist__order_items.sql

select
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date      as shipping_limit_timestamp,
    price,
    freight_value
from {{ source('olist', 'order_items') }}