# GCP Data Analytics with BigQuery + Pandas

Queries a public BigQuery dataset, performs simple analysis with Pandas, and saves a summary CSV and chart.

## Setup
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service_account.json
python bigquery_analysis.py
```

The notebook `bigquery_analysis.ipynb` mirrors the script for interactive exploration.
