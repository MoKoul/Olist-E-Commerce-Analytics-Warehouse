-- models/staging/olist/stg_olist__order_reviews.sql

select
    review_id,
    order_id,
    review_score,
    review_creation_date         as review_creation_timestamp,
    review_answer_timestamp      
    review_comment_title,
    review_comment_message
from {{ source('olist', 'order_reviews') }}