# Session-level ML data dictionary

| Field | Role | Definition | Used by deployable model? |
|---|---|---|---|
| `session_id` | Key | Unique session identifier | No |
| `session_date` | Split | Session date used for chronological validation | No |
| `converted` | Label | Session contains a purchase | Target only |
| `day_of_week` | Feature | Day number supplied in the export | Yes |
| `is_weekend` | Feature | Weekend indicator | Yes |
| `traffic_source` | Feature | Session acquisition source | Yes |
| `traffic_medium` | Feature | Session acquisition medium | Yes |
| `device_category` | Feature | Desktop, mobile, or tablet | Yes |
| `operating_system` | Feature | Operating system category | Yes |
| `country` | Feature | Obfuscated geographic country | Yes |
| `page_views`, `product_views` | Descriptive | Full-session browsing behavior | No—future behavior |
| `add_to_cart_events` | Descriptive | Full-session cart events | No—future behavior |
| `checkout_events`, `shipping_events`, `payment_events` | Descriptive | Full-session checkout behavior | No—target-adjacent |
| `purchase_events`, `transaction_count`, `revenue` | Outcome | Purchase results | No—direct leakage |
| `total_events`, `distinct_event_types` | Descriptive | Full-session event totals | No—future information |
| `session_duration_seconds`, `engagement_time_seconds` | Descriptive | Full-session duration and engagement | No—future information |

The leakage audit in `src/train_model.ipynb` enforces the seven-feature
score-time contract before model training.

The tables and models under `experiments/` use a different first-five-minute
feature contract and are not part of the primary research-paper model.

