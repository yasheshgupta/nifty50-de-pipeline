# Nifty 50 Stock Market Data Pipeline

A production-style data engineering pipeline built on **Databricks + PySpark + Delta Lake**
using the Medallion Architecture (Bronze → Silver → Gold).

## Project Goal
Ingest, clean, and transform NSE Nifty 50 historical stock data into analytics-ready Delta tables.

## Stack
- PySpark
- Databricks Community Edition
- Delta Lake
- Python 3.x
- GitHub (version control)

## Architecture
Bronze → Raw ingestion from CSV
Silver → Cleaned, typed, deduplicated data
Gold   → Aggregated metrics: daily returns, moving averages, volatility

## Dataset
[Nifty 50 Stock Market Data](https://www.kaggle.com/datasets/debashis74017/nifty-50-minute-data) — Kaggle

## Author
Yashesh Gupta | https://in.linkedin.com/in/yashesh-gupta-515a0417b | Data Engineering Portfolio Project