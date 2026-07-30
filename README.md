# Walmart Sales Statistical Analysis

## Project Overview
This project analyzes historical sales data from 45 Walmart stores (2010–2012) to answer five business questions using SQL-based data preparation and Python-based statistical testing.

**Business Questions:**
1. When are sales lowest, and by how much do holidays/markdowns lift sales?
2. Do markdowns actually work, and which ones are worth running?
3. Should markdowns be concentrated in low-sales weeks to smooth demand, or do they only work near holidays?
4. Which store types/sizes are most resilient or most volatile, and where should attention focus?
5. How much do external economic conditions (CPI, unemployment, fuel price) explain sales fluctuations, independent of holidays/markdowns?

**Data sources:** `sales.csv` (Store, Dept, Date, Weekly_Sales, IsHoliday), `stores.csv` (Store, Type, Size), `features.csv` (Store, Date, Temperature, Fuel_Price, MarkDown1-5, CPI, Unemployment).

**Pipeline:** SQL (data validation, joins, aggregation) → Python (pandas, statsmodels, scipy: t-tests, Mann-Whitney U, two-way ANOVA, Tukey HSD, multiple regression).

---

## Data Quality Notes

**Markdown tracking gap:** MarkDown1-5 are only populated from November 2011 onward. Pre-November-2011 NULLs represent "not yet tracked," not "confirmed zero markdown." All markdown-specific tests were restricted to the post-November-2011 window to avoid conflating these two populations.

**Negative sales values:** 1,285 rows have Weekly_Sales below zero, likely reflecting returns exceeding sales in a given week. Flagged during SQL validation; retained in analysis as legitimate business activity rather than treated as data errors.

---

## Business Question 1: Does the holiday season drive a real sales lift?
Holiday weeks show a statistically significant sales lift confirmed by both parametric and non-parametric tests (t-test p=0.008; Mann-Whitney U p=0.026), with a mean lift of ~$81,631 and median lift of ~$62,327 per store.

## Business Question 2: Do markdowns increase sales during non-holiday weeks?
Restricted to the post-November-2011 tracking period: MarkDown4 (+116.1%), MarkDown3 (+57.2%), and MarkDown2 (+33.1%) show strong, highly significant lifts (p<0.0001). MarkDown1 is inconclusive (+14.6%, t-test p=0.080, Mann-Whitney U p=0.046); MarkDown5 is not significant (-2.1%, p=0.079).

## Business Question 3: Does markdown effectiveness depend on holiday timing?
Interaction regression on MarkDown4 shows no significant interaction with holiday status (p=0.809) — MarkDown4 delivers a consistent lift regardless of holiday timing, supporting its use as a holiday-independent demand-smoothing tool.

## Business Question 4: Do store type and size affect sales, and does markdown effectiveness vary by store type?
- Store type: ANOVA/Kruskal-Wallis confirm significant differences (p<0.001); Tukey HSD shows Type A > Type B (~$553K) > Type C (~$904K gap from A).
- Volatility: Type B is most volatile relative to size (CV=0.496); Type C is most stable (CV=0.245) despite lowest sales.
- Store size correlation: strong positive relationship with sales (Pearson r=0.810, Spearman rho=0.837).
- Markdown x store type interaction: significant for MarkDown2, MarkDown3, MarkDown4 (all p<0.0001 in Type A/B; p<0.05 in Type C for MD3/MD4); not significant for MarkDown1 or MarkDown5.

| Store Type | MD1 | MD2 | MD3 | MD4 | MD5 |
|---|---|---|---|---|---|
| A | +12.4% | +24.0% | +83.4% | +161.7% | -1.9% |
| B | +0.2% | +0.9% | +16.2% | +12.3% | +0.2% |
| C | +0.7% | +0.3% | +7.3% | -9.0% | -1.7% |

MarkDown4 delivers by far the strongest effect, concentrated almost entirely in Type A, and turns negative in Type C.

## Business Question 5: How much do economic conditions explain sales, independent of holidays and markdowns?
A standardized multiple regression (R²=0.757) shows store size is the dominant driver (standardized coef=0.508), ~8x more influential than holiday timing (0.065). CPI (-0.047) and unemployment (-0.017) have small but significant negative effects; temperature and fuel price show no significant relationship.

---

## Strategic Recommendations
1. Prioritize MarkDown4 in Type A stores (+161.7% lift); use MarkDown3 as the primary lever in Type B (+16.2%) and Type C (+7.3%).
2. Discontinue MarkDown4 in Type C stores, since it produces a statistically significant negative effect (-9.0%, p<0.001).
3. Deprioritize MarkDown1 and MarkDown5, since neither shows reliable, differentiated effects.
4. Treat MarkDown4 as a holiday-independent, year-round demand-smoothing tool.
5. Use store size as the primary sales forecasting driver ahead of macroeconomic indicators.

---

## Known Limitations
- Negative sales rows (returns > sales) were retained without further adjustment; sensitivity analysis excluding these rows has not yet been performed.
- MarkDown1 remains statistically inconclusive due to a small inactive-period sample size (n=59) post-November-2011.
