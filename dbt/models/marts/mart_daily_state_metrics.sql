{{ config(
    engine='MergeTree()',
    order_by=['us_state', 'tx_date']
) }}

with transactions as (
    select
        tx_date,
        us_state,
        amount,
        amount_bucket
    from {{ ref('stg_transactions') }}
)

select
    tx_date
    , us_state
    , count() as txn_count
    , sum(amount) as total_amount
    , avg(amount) as avg_check
    , quantile(0.95)(amount) as p95_amount
from transactions
group by
    tx_date,
    us_state
