-- models/staging/olist/stg_olist__sellers.sql

select
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
from {{ source('olist', 'sellers') }}