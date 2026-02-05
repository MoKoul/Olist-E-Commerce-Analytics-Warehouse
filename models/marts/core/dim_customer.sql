
-- models/marts/core/dim_customer.sql
--
-- Dimension table: one row per unique customer (customer_unique_id)
-- 
-- Handles:
--   Messy geolocation data → one representative lat/lng per zip code prefix
--   Missing/inconsistent city/state in customers → enriched from geolocation

{{
  config(
    materialized = 'table',
    cluster_by = ["customer_state"]
  )

}}


with customers as (
    select
        customer_unique_id,          
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        row_number() over (partition by customer_unique_id order by customer_zip_code_prefix, customer_city) as rn

    from {{ ref('stg_olist__customers') }}
),

geo as (
    select
        geolocation_zip_code_prefix,
        any_value(geolocation_lat)  as geolocation_lat,
        any_value(geolocation_lng)  as geolocation_lng,
        any_value(geolocation_city) as city,
        any_value(geolocation_state) as state
    from {{ ref('stg_olist__geolocation') }}
    group by 1
)

select
    {{ dbt_utils.generate_surrogate_key(['c.customer_unique_id']) }} as customer_sk,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    coalesce(c.customer_city, g.city)  as customer_city,
    coalesce(c.customer_state, g.state) as customer_state,
    g.geolocation_lat,
    g.geolocation_lng
from customers c
left join geo g
    on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
where c.rn = 1            