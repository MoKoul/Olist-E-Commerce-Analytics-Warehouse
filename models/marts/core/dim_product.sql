
-- models/marts/core/dim_product.sql

-- Dimension: one row per product
-- Enriched with English category name from translation table


with translation as (
  select
    product_category_name,
    product_category_name_english
  from {{ ref('stg_olist__category_translation') }} 
)
  select distinct
    {{ dbt_utils.generate_surrogate_key(['p.product_id']) }} as product_sk,
    p.product_id,
    coalesce(t.product_category_name_english,'unknown') as product_category_name_english,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    coalesce(p.product_category_name, t.product_category_name, 'unknown') as product_category_name_portuguese
from
   {{ ref('stg_olist__products') }}  as p
left join
  translation as t
on
  p.product_category_name = t.product_category_name

  