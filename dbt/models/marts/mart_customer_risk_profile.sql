{{ config(
    engine='MergeTree()',
    order_by=['customer_id']
) }}

with transactions as (
    select
        customer_id
        , name_1
        , name_2
        , amount
        , is_fraud
        , tx_date
    from {{ ref('stg_transactions') }}
),

by_customer as (
    select
        customer_id
        , any(name_1) as name_1
        , any(name_2) as name_2
        , count() as txn_count
        , sum(is_fraud) as fraud_count
        , 100.0 * sum(is_fraud) / count() as fraud_rate
        , sum(amount) as total_amount
        , avg(amount) as avg_check
        , min(tx_date) as first_tx_date
        , max(tx_date) as last_tx_date
    from transactions
    group by customer_id
)

select
    customer_id
    , name_1
    , name_2
    , txn_count
    , fraud_count
    , fraud_rate
    , total_amount
    , avg_check
    , first_tx_date
    , last_tx_date
    , cast(
        multiIf(
            fraud_rate >= 10 or fraud_count >= 3, 'HIGH',
            fraud_count >= 1, 'MEDIUM',
            'LOW'
        ) as LowCardinality(String)
    ) as risk_segment
from by_customer
