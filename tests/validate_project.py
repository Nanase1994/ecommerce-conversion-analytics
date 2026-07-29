import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

metrics = json.loads(
    (ROOT / "artifacts" / "model_metrics.json").read_text(encoding="utf-8")
)
dashboard = json.loads(
    (ROOT / "dashboard" / "dashboard_source.json").read_text(encoding="utf-8")
)
notebook = json.loads(
    (ROOT / "Ecommerce_Conversion_Analytics_Integrated.ipynb").read_text(
        encoding="utf-8"
    )
)

assert metrics["selected_by_pr_auc"] == "hashed_logistic_regression"
assert metrics["feature_contract"]["status"] == "passed"
assert metrics["data"]["test_rows"] == 81527
assert metrics["data"]["test_purchases"] == 912
assert 1.9 < metrics["models"]["hashed_logistic_regression"]["lift_top_10pct"] < 2.1

safe = set(metrics["feature_contract"]["safe_features"])
prohibited = set(metrics["feature_contract"]["prohibited_columns_present_but_excluded"])
assert safe.isdisjoint(prohibited)
assert "purchase_events" in prohibited
assert "revenue" in prohibited

assert dashboard["snapshot"]["status"] == "ready"
assert len(dashboard["snapshot"]["datasets"]) == 8
assert notebook["nbformat"] == 4
assert len(notebook["cells"]) == 34

print("Portfolio validation passed.")
