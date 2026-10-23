{{ config(
    engine='MergeTree()',
    order_by=['us_state']
) }}

with transactions as (
    select
        us_state
        , amount
        , is_fraud
        , customer_id
        , merch
    from {{ ref('stg_transactions') }}
),

by_state as (
    select
        us_state
        , count() as txn_count
        , sum(is_fraud) as fraud_count
        , 100.0 * sum(is_fraud) / count() as fraud_rate
        , sum(amount) as total_amount
        , sumIf(amount, is_fraud = 1) as fraud_amount
        , uniqExact(customer_id) as customer_count
        , uniqExact(merch) as merchant_count
    from transactions
    group by us_state
)

select
    by_state.us_state
    , s.state_name
    , by_state.txn_count
    , by_state.fraud_count
    , by_state.fraud_rate
    , by_state.total_amount
    , by_state.fraud_amount
    , by_state.customer_count
    , by_state.merchant_count
from by_state
left join {{ ref('us_states') }} s
    on by_state.us_state = s.state_code
