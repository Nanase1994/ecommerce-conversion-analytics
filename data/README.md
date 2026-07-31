# Data access

The raw session-level export is not committed because it is approximately
52 MB. It can be regenerated from Google's public GA4 obfuscated e-commerce
sample by running `sql/01_build_session_table.sql` in BigQuery.

Expected repository file location:

```text
data/session_level_ecommerce.csv.gz
```

The notebooks also accept an uncompressed `session_level_ecommerce.csv` in the
repository root or the `data/` directory. Pandas detects gzip compression from
the `.gz` suffix automatically.

Expected grain: one row per unique GA4 session.

Required model columns:

```text
session_id, session_date, converted, day_of_week, is_weekend,
traffic_source, traffic_medium, device_category, operating_system, country
```

The reviewed dataset contains 310,014 rows, no duplicate session IDs, no
missing values across the exported 30 columns, and dates from 2020-11-16
through 2021-01-31.

