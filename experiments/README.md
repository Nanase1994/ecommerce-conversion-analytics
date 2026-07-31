# Optional five-minute BigQuery ML extension

These SQL files are not used to reproduce the research-paper results.

The canonical paper model scores sessions using seven variables available at
session start and compares hashed logistic regression with categorical Naive
Bayes in the Python notebooks.

This optional extension changes the prediction timing by observing behavior
during the first five minutes of a session. It then trains BigQuery ML
logistic-regression and boosted-tree challengers. Results from this directory
must not be presented as the paper-model results.

