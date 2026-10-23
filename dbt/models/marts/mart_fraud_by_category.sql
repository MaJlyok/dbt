{{ config(
    engine='MergeTree()',
    order_by=['cat_id']
) }}

with transactions as (
    select
        cat_id
        , amount
        , is_fraud
    from {{ ref('stg_transactions') }}
)

select
    cat_id
    , count() as txn_count
    , sum(is_fraud) as fraud_count
    , 100.0 * sum(is_fraud) / count() as fraud_rate
    , sum(amount) as total_amount
    , sumIf(amount, is_fraud = 1) as fraud_amount
from transactions
group by cat_id
