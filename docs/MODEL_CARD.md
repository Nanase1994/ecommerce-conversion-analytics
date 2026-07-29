# Model card: Session-start purchase propensity

## Intended use

Rank e-commerce sessions at session start so product teams can prioritize
helpful, low-friction experiences for controlled experimentation.

## Not intended for

- Individual price discrimination.
- Credit, employment, insurance, or eligibility decisions.
- Production targeting without privacy review and a randomized experiment.
- Claims about causal treatment impact.

## Target and observation unit

The observation unit is one unique GA4 session. `converted = 1` when the session
contains a purchase; otherwise it equals 0.

## Score-time feature contract

Only session-start context is eligible:

- Day of week and weekend flag.
- Traffic source and medium.
- Device category and operating system.
- Country.

Purchase, revenue, transaction, checkout, payment, page, product, cart, event
totals, engagement, and session duration are excluded. Although they exist in
the session-level export, they contain future behavior or directly reveal the
outcome.

## Training and evaluation

- Training: 2020-11-16 through 2021-01-10.
- Test: 2021-01-11 through 2021-01-31.
- Training sessions / purchases: 228,487 / 3,335.
- Test sessions / purchases: 81,527 / 912.
- Primary metric: PR-AUC.
- Secondary metrics: ROC-AUC, log loss, Brier score, lift, calibration, and
  recall at the highest-score 10% intervention capacity.

## Model results

| Model | PR-AUC | ROC-AUC | Log loss | Brier | Top-10% recall | Lift |
|---|---:|---:|---:|---:|---:|---:|
| Hashed logistic regression | 0.0171 | 0.5868 | 0.0609 | 0.01105 | 20.1% | 2.01× |
| Categorical Naive Bayes | 0.0168 | 0.5947 | 0.0631 | 0.01138 | 20.3% | 2.03× |

Hashed logistic regression is selected by PR-AUC. Performance is modest but
genuine: the highest-risk decile converts at about twice the holdout average.

## Known risks

- GA4 sample data are obfuscated and contain placeholder categories.
- Start-of-session context may reflect acquisition mix rather than product need.
- The test conversion rate is lower than the training rate (1.12% vs. 1.46%).
- Categorical mix and calibration may drift.
- High propensity is not incremental treatment response.

## Monitoring and deployment gate

Track input coverage, unseen-category rates, score distribution, conversion by
decile, PR-AUC, Brier score, and calibration. Deployment remains limited to a
controlled experiment until prospective stability, privacy review, and
incremental treatment value are demonstrated.
