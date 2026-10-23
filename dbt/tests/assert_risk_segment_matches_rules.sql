select
    customer_id
    , fraud_count
    , fraud_rate
    , risk_segment
from {{ ref('mart_customer_risk_profile') }}
where
    (risk_segment = 'LOW' and fraud_count > 0)
    or (risk_segment = 'MEDIUM' and (fraud_count = 0 or fraud_rate >= 10 or fraud_count >= 3))
    or (risk_segment = 'HIGH' and fraud_rate < 10 and fraud_count < 3)
