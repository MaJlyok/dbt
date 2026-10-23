with source as (
    select * from {{ source('transactions_source', 'transactions') }}
),

normalized as (
    select
        transaction_time,
        toDate(transaction_time) as tx_date,
        {{ dbt_date.day_of_week('transaction_time') }} as tx_day_of_week,
        trim(merch) as merch,
        cast(lower(trim(cat_id)) as LowCardinality(String)) as cat_id,
        toFloat64(amount) as amount,
        trim(name_1) as name_1,
        trim(name_2) as name_2,
        cast(upper(trim(gender)) as LowCardinality(String)) as gender,
        cast(upper(trim(us_state)) as LowCardinality(String)) as us_state,
        toFloat64(lat) as lat,
        toFloat64(lon) as lon,
        toFloat64(merchant_lat) as merchant_lat,
        toFloat64(merchant_lon) as merchant_lon,
        toUInt8(target) as is_fraud
    from source
)

select
    transaction_time,
    tx_date,
    tx_day_of_week,
    merch,
    cat_id,
    amount,
    cast({{ amount_bucket('amount') }} as LowCardinality(String)) as amount_bucket,
    name_1,
    name_2,
    {{ dbt_utils.generate_surrogate_key(['name_1', 'name_2']) }} as customer_id,
    gender,
    us_state,
    lat,
    lon,
    merchant_lat,
    merchant_lon,
    is_fraud
from normalized
