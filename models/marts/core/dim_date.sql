 -- models/marts/core/dim_date.sql
 
-- Date dimension covering Olist data range (2016-09-01 to 2018-12-31)
-- Includes descriptive fields for easy analysis: month_name, day_name, is_weekend, etc.
-- Grain: one row per day

with date_spine as (
    select 
        date_day
    from unnest(
        generate_date_array('2016-09-01', '2018-12-31', interval 1 day)
    ) as date_day
)

select
    format_date('%Y%m%d', date_day)                   as date_key,          -- 20180904
    date_day                                          as full_date,         -- DATE type: 2018-09-04 

    -- Add new integer column for Date as YearMonth to be used instead of date in partitioning
    extract(year from date_day)*100 + extract(month from date_day) as order_purchase_ym,

    extract(year from date_day)                       as year,
    extract(quarter from date_day)                    as quarter,
    extract(month from date_day)                      as month_number,
    format_date('%B', date_day)                       as month_name,
    format_date('%A', date_day)                       as day_name,
    extract(DAYOFWEEK from date_day)                  as day_of_week,       -- 1=Sunday, 7=Saturday
    extract(day from date_day)                        as day_of_month,
    case when extract(DAYOFWEEK from date_day) in (1,7) then true else false end as is_weekend,
    --case when date_day = current_date() then true else false end               as is_today
from date_spine
order by date_day