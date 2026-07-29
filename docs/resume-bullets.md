# Resume-ready project description

## One-line project

Built an end-to-end GA4 e-commerce analytics and purchase-propensity ML system
using BigQuery SQL, Python, chronological validation, and an interactive
monitoring dashboard.

## Resume bullets

- Analyzed 3.6M GA4 events across 310K sessions to diagnose a six-stage
  e-commerce funnel, identifying 244K lost sessions before product discovery
  and prioritizing high-impact product experiments.
- Engineered a leakage-safe purchase-propensity pipeline with deterministic
  categorical hashing, chronological holdout validation, rare-event metrics,
  lift analysis, and probability calibration.
- Achieved 2.01× conversion lift in the highest-scored session decile, capturing
  20.1% of future purchases within 10% of sessions while excluding all
  post-session behavioral and revenue variables.
- Delivered a decision dashboard, BigQuery ML alternative, model card,
  monitoring plan, and randomized-experiment framework to separate prediction
  from incremental causal impact.

## Interview talking points

1. Why chronological validation is more realistic than a random split.
2. Why 98.6% accuracy is operationally useless for a 1.37% purchase rate.
3. How post-session variables create target leakage.
4. Why PR-AUC, lift, Brier score, and calibration answer different questions.
5. Why a propensity score must be validated with a randomized intervention.
