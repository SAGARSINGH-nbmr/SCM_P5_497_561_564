"""
=====================================================================
 P5 - Centralized Monitoring | SupplyNex Pvt Ltd
 UE23CS342BA1: Supply Chain Management [SCME] — Jan-May 2026
 ML Module: Demand Forecasting using ARIMA
=====================================================================
 Description:
   Trains an ARIMA model on historical demand data (from sample DB),
   forecasts demand for the next 6 months per product-warehouse pair,
   evaluates accuracy (MAE, RMSE), and generates plots + a CSV export
   of forecasted values ready to INSERT into DEMAND_FORECAST table.

 Requirements:
   pip install pandas numpy matplotlib statsmodels scikit-learn

 Usage:
   python p5_scm_arima_forecast.py
=====================================================================
"""

import warnings
warnings.filterwarnings("ignore")

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.gridspec import GridSpec
from statsmodels.tsa.arima.model import ARIMA
from statsmodels.tsa.stattools import adfuller
from sklearn.metrics import mean_absolute_error, mean_squared_error
from datetime import datetime, date
import itertools

# ─────────────────────────────────────────────
# 1.  HISTORICAL DATA  (mirrors your SQL dataset)
#     DEMAND_FORECAST table — actual_units per
#     product per warehouse, Jan-2025 to Apr-2026
# ─────────────────────────────────────────────

RAW_DATA = {
    "Laptop Pro X (Electronics)": {
        "dates": pd.date_range("2025-01-01", periods=16, freq="MS"),
        "actual": [120, 135, 128, 140, 155, 148, 162, 170, 165, 178, 190, 200, 210, 215, 220, 225],
    },
    "Steel Sheets (Raw Materials)": {
        "dates": pd.date_range("2025-01-01", periods=16, freq="MS"),
        "actual": [300, 310, 295, 320, 330, 315, 340, 350, 345, 360, 370, 380, 390, 385, 395, 400],
    },
    "Copper Wire (Raw Materials)": {
        "dates": pd.date_range("2025-01-01", periods=16, freq="MS"),
        "actual": [200, 195, 210, 205, 215, 220, 210, 225, 230, 240, 235, 245, 250, 255, 248, 260],
    },
    "Rice 5kg Pack (FMCG)": {
        "dates": pd.date_range("2025-01-01", periods=16, freq="MS"),
        "actual": [500, 480, 510, 520, 530, 515, 540, 550, 545, 560, 570, 590, 600, 610, 605, 620],
    },
    "Cardboard Box (Packaging)": {
        "dates": pd.date_range("2025-01-01", periods=16, freq="MS"),
        "actual": [150, 145, 160, 155, 165, 158, 170, 175, 168, 180, 185, 190, 195, 200, 198, 205],
    },
}

FORECAST_HORIZON = 6   # months ahead to predict
TRAIN_SIZE       = 13  # months used to train  (leaves 3 for validation)


# ─────────────────────────────────────────────
# 2.  HELPER FUNCTIONS
# ─────────────────────────────────────────────

def adf_test(series, product_name):
    """Augmented Dickey-Fuller stationarity test."""
    result = adfuller(series.dropna())
    print(f"  ADF Statistic : {result[0]:.4f}")
    print(f"  p-value       : {result[1]:.4f}")
    print(f"  Stationary    : {'YES ✓' if result[1] < 0.05 else 'NO — differencing needed'}")


def find_best_arima(series, max_p=3, max_d=2, max_q=3):
    """
    Grid search over (p,d,q) — picks lowest AIC.
    Kept small for fast runtime in a student project.
    """
    best_aic   = np.inf
    best_order = (1, 1, 1)
    for p, d, q in itertools.product(range(max_p+1), range(max_d+1), range(max_q+1)):
        if p == 0 and q == 0:
            continue
        try:
            mdl = ARIMA(series, order=(p, d, q)).fit()
            if mdl.aic < best_aic:
                best_aic   = mdl.aic
                best_order = (p, d, q)
        except Exception:
            continue
    return best_order, best_aic


def evaluate_forecast(actual, predicted):
    """Returns MAE, RMSE, MAPE."""
    actual    = np.array(actual)
    predicted = np.array(predicted)
    mae   = mean_absolute_error(actual, predicted)
    rmse  = np.sqrt(mean_squared_error(actual, predicted))
    mape  = np.mean(np.abs((actual - predicted) / actual)) * 100
    return mae, rmse, mape


# ─────────────────────────────────────────────
# 3.  MAIN PIPELINE — train, validate, forecast
# ─────────────────────────────────────────────

results_summary = []   # for final CSV / SQL export
all_product_data = {}  # for plotting

print("=" * 65)
print("  P5 SUPPLYNEX — ARIMA DEMAND FORECASTING")
print("  Course: UE23CS342BA1  |  Team: SupplyNex")
print("=" * 65)

for product, data in RAW_DATA.items():
    print(f"\n{'─'*55}")
    print(f"  Product : {product}")
    print(f"{'─'*55}")

    series      = pd.Series(data["actual"], index=data["dates"])
    train_series = series.iloc[:TRAIN_SIZE]
    val_series   = series.iloc[TRAIN_SIZE:]

    # ── 3a. Stationarity check ──────────────────
    print("\n  [ADF Stationarity Test on Training Data]")
    adf_test(train_series, product)

    # ── 3b. Auto ARIMA order selection ──────────
    print("\n  [Grid Search — Best ARIMA(p,d,q)]")
    best_order, best_aic = find_best_arima(train_series)
    print(f"  Best order : ARIMA{best_order}  |  AIC = {best_aic:.2f}")

    # ── 3c. Train model ──────────────────────────
    model = ARIMA(train_series, order=best_order).fit()

    # ── 3d. Validate on held-out months ──────────
    val_pred = model.forecast(steps=len(val_series))
    mae, rmse, mape = evaluate_forecast(val_series.values, val_pred.values)
    print(f"\n  [Validation — {len(val_series)} months held out]")
    print(f"  MAE  = {mae:.2f} units")
    print(f"  RMSE = {rmse:.2f} units")
    print(f"  MAPE = {mape:.2f}%")

    # ── 3e. Refit on FULL data & forecast ────────
    full_model    = ARIMA(series, order=best_order).fit()
    forecast_vals = full_model.forecast(steps=FORECAST_HORIZON)
    forecast_idx  = pd.date_range(
        series.index[-1] + pd.DateOffset(months=1),
        periods=FORECAST_HORIZON, freq="MS"
    )
    forecast_series = pd.Series(forecast_vals.values, index=forecast_idx)

    # Confidence intervals (95%)
    forecast_ci = full_model.get_forecast(steps=FORECAST_HORIZON).conf_int(alpha=0.05)

    print(f"\n  [6-Month Demand Forecast]")
    for dt, val in zip(forecast_idx, forecast_vals):
        print(f"  {dt.strftime('%b %Y')} → {int(round(val))} units")

    # ── 3f. Collect for plots & export ───────────
    all_product_data[product] = {
        "series":         series,
        "val_series":     val_series,
        "val_pred":       val_pred,
        "forecast":       forecast_series,
        "ci":             forecast_ci,
        "order":          best_order,
        "mae":            mae,
        "rmse":           rmse,
        "mape":           mape,
    }

    for dt, val in zip(forecast_idx, forecast_vals):
        results_summary.append({
            "product_name":     product,
            "forecast_month":   dt.strftime("%Y-%m-01"),
            "forecasted_units": int(round(val)),
            "model_used":       f"ARIMA{best_order}",
            "mape_pct":         round(mape, 2),
        })


# ─────────────────────────────────────────────
# 4.  EXPORT RESULTS → CSV + SQL INSERT snippet
# ─────────────────────────────────────────────

df_export = pd.DataFrame(results_summary)
df_export.to_csv("p5_arima_forecast_output.csv", index=False)

print("\n\n" + "=" * 65)
print("  EXPORT COMPLETE → p5_arima_forecast_output.csv")
print("=" * 65)
print(df_export.to_string(index=False))

# SQL INSERT snippet (ready to paste into your .sql file)
print("\n\n-- ── SQL INSERT for DEMAND_FORECAST table ──────────────────")
print("-- Paste these rows after your existing INSERT statements\n")
for i, row in df_export.iterrows():
    pid_map = {
        "Laptop Pro X (Electronics)": 1,
        "Steel Sheets (Raw Materials)": 4,
        "Copper Wire (Raw Materials)": 6,
        "Rice 5kg Pack (FMCG)": 8,
        "Cardboard Box (Packaging)": 11,
    }
    wid_map = {
        "Laptop Pro X (Electronics)": 1,
        "Steel Sheets (Raw Materials)": 3,
        "Copper Wire (Raw Materials)": 3,
        "Rice 5kg Pack (FMCG)": 5,
        "Cardboard Box (Packaging)": 7,
    }
    pid = pid_map.get(row["product_name"], 1)
    wid = wid_map.get(row["product_name"], 1)
    print(
        f"INSERT INTO DEMAND_FORECAST (product_id, warehouse_id, forecast_month, "
        f"forecasted_units, actual_units, model_used) VALUES "
        f"({pid}, {wid}, '{row['forecast_month']}', {row['forecasted_units']}, NULL, "
        f"'{row['model_used']}');"
    )


# ─────────────────────────────────────────────
# 5.  PLOTS — one figure per product
#     + one summary accuracy bar chart
# ─────────────────────────────────────────────

COLORS = {
    "actual":   "#1D9E75",
    "val":      "#EF9F27",
    "forecast": "#7F77DD",
    "ci":       "#C5C2F0",
    "grid":     "#E8E8E8",
}

fig = plt.figure(figsize=(20, 22))
fig.patch.set_facecolor("#FAFAFA")
gs  = GridSpec(3, 2, figure=fig, hspace=0.45, wspace=0.35)

axes = [fig.add_subplot(gs[r, c]) for r, c in [(0,0),(0,1),(1,0),(1,1),(2,0)]]
ax_acc = fig.add_subplot(gs[2, 1])

fig.suptitle(
    "SupplyNex — ARIMA Demand Forecasting | P5 Centralized Monitoring\n"
    "UE23CS342BA1: Supply Chain Management for Engineers",
    fontsize=14, fontweight="bold", color="#1A1A2E", y=0.98
)

for ax, (product, d) in zip(axes, all_product_data.items()):
    series   = d["series"]
    forecast = d["forecast"]
    ci       = d["ci"]
    val_s    = d["val_series"]
    val_p    = d["val_pred"]

    # Historical
    ax.plot(series.index, series.values,
            color=COLORS["actual"], linewidth=2, marker="o", markersize=4,
            label="Actual demand", zorder=3)

    # Validation overlay
    ax.plot(val_s.index, val_p.values,
            color=COLORS["val"], linewidth=1.8, linestyle="--", marker="s", markersize=4,
            label=f"Validation (MAPE {d['mape']:.1f}%)", zorder=4)

    # Forecast
    ax.plot(forecast.index, forecast.values,
            color=COLORS["forecast"], linewidth=2.2, linestyle="--", marker="D", markersize=5,
            label="Forecast (ARIMA)", zorder=3)

    # 95% CI shading
    ax.fill_between(
        forecast.index,
        ci.iloc[:, 0], ci.iloc[:, 1],
        color=COLORS["ci"], alpha=0.45, label="95% CI"
    )

    # Vertical divider — train/forecast boundary
    ax.axvline(series.index[-1], color="#AAAAAA", linestyle=":", linewidth=1)
    ax.text(series.index[-1], ax.get_ylim()[0],
            " forecast →", fontsize=8, color="#888888", va="bottom")

    ax.set_title(product, fontsize=10, fontweight="bold", color="#1A1A2E", pad=8)
    ax.set_ylabel("Units", fontsize=9)
    ax.xaxis.set_major_formatter(mdates.DateFormatter("%b'%y"))
    ax.xaxis.set_major_locator(mdates.MonthLocator(interval=3))
    plt.setp(ax.xaxis.get_majorticklabels(), rotation=30, ha="right", fontsize=8)
    ax.tick_params(axis="y", labelsize=8)
    ax.set_facecolor("#FFFFFF")
    ax.grid(color=COLORS["grid"], linewidth=0.7)
    ax.legend(fontsize=7.5, loc="upper left", framealpha=0.8)
    ax.spines[["top","right"]].set_visible(False)

# ── Accuracy summary bar chart ───────────────
products_short = [p.split("(")[0].strip() for p in all_product_data]
mape_vals      = [d["mape"] for d in all_product_data.values()]
bar_colors     = ["#1D9E75" if m < 10 else "#EF9F27" if m < 15 else "#E24B4A"
                  for m in mape_vals]

bars = ax_acc.barh(products_short, mape_vals, color=bar_colors, edgecolor="white",
                   height=0.55, zorder=3)
ax_acc.axvline(10, color="#E24B4A", linestyle="--", linewidth=1, label="10% threshold")
for bar, val in zip(bars, mape_vals):
    ax_acc.text(val + 0.2, bar.get_y() + bar.get_height()/2,
                f"{val:.1f}%", va="center", fontsize=9, color="#1A1A2E")

ax_acc.set_xlabel("MAPE (%)", fontsize=9)
ax_acc.set_title("Model Accuracy — MAPE by Product\n(green < 10% = good)", fontsize=10,
                 fontweight="bold", color="#1A1A2E", pad=8)
ax_acc.set_facecolor("#FFFFFF")
ax_acc.grid(axis="x", color=COLORS["grid"], linewidth=0.7)
ax_acc.spines[["top","right"]].set_visible(False)
ax_acc.tick_params(labelsize=8)
ax_acc.legend(fontsize=8)

plt.savefig("p5_arima_forecast_plots.png", dpi=150, bbox_inches="tight",
            facecolor="#FAFAFA")
plt.show()
print("\n  Plot saved → p5_arima_forecast_plots.png")
print("  Done ✓")