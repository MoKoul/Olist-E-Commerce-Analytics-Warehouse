-- models/staging/olist/stg_olist__order_payments.sql

select
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
from {{ source('olist', 'order_payments') }}