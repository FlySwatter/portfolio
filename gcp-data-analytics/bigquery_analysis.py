#Export GOOGLE_APPLICATION_CREDENTIALS
import pandas as pd
from google.cloud import bigquery
import matplotlib.pyplot as plt

client = bigquery.Client()  

# Public dataset: samples.natality (exists in BigQuery public data)
QUERY = '''
SELECT year, COUNT(1) as births
FROM `bigquery-public-data.samples.natality`
WHERE year BETWEEN 2000 AND 2004
GROUP BY year
ORDER BY year
'''

df = client.query(QUERY).to_dataframe()
print(df)

df.to_csv("births_by_year.csv", index=False)

plt.figure()
plt.plot(df["year"], df["births"], marker="o")
plt.title("Births by Year (2000-2004)")
plt.xlabel("Year")
plt.ylabel("Births")
plt.savefig("births_by_year.png", dpi=150)
print("Saved births_by_year.csv and births_by_year.png")
