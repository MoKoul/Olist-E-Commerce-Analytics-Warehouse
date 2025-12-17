-- models/staging/olist/stg_olist__category_translation.sql

select
    string_field_0 as  product_category_name,
    string_field_1 as product_category_name_english
from {{ source('olist', 'product_category_translation') }}