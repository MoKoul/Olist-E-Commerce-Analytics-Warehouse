-- models/staging/olist/stg_olist__geolocation.sql

select
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state
from {{ source('olist', 'geolocation') }}