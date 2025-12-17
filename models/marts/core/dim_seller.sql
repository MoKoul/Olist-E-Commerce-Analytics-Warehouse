   
-- models/marts/core/dim_seller.sql

-- Dimension: one row per unique seller
-- Enriched with approximate lat/lng and cleaned city/state from geolocation table

with
  geo as(
  select
    geolocation_zip_code_prefix,
    any_value(geolocation_lat) as geolocation_lat,
    any_value(geolocation_lng) as geolocation_lng,
    any_value(geolocation_city) as city,    
    any_value(geolocation_state) as state  
  from
    {{ ref('stg_olist__geolocation') }}
  group by
    geolocation_zip_code_prefix )
select distinct
  {{ dbt_utils.generate_surrogate_key(['s.seller_id']) }} as seller_sk,
  s.seller_id,
  s.seller_zip_code_prefix,
  coalesce(s.seller_city, g.city) as seller_city,
  coalesce(s.seller_state, g.state) as seller_state,
  g.geolocation_lat,
  g.geolocation_lng
from
  {{ ref('stg_olist__sellers') }} as s
left join
  geo g
on
  g.geolocation_zip_code_prefix = s.seller_zip_code_prefix

