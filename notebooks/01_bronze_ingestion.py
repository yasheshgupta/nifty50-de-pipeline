# Databricks notebook source
# MAGIC %md
# MAGIC # Bronze Layer — Raw Ingestion
# MAGIC ## Pipeline: Nifty 50 + India VIX Minute Data
# MAGIC
# MAGIC - Source   : Kaggle (debashis74017/nifty-50-minute-data)
# MAGIC - Layer    : Bronze (raw, no transformations)
# MAGIC - Outputs  : 
# MAGIC     - bronze/nifty50_minute
# MAGIC     - bronze/nifty50_5minute
# MAGIC     - bronze/nifty50_day
# MAGIC     - bronze/india_vix_minute
# MAGIC     - bronze/india_vix_5minute
# MAGIC     - bronze/india_vix_day
# MAGIC - Author   : Yashesh Gupta
# MAGIC - Date     : 2026-06-03

# COMMAND ----------

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, DoubleType, LongType
from pyspark.sql.functions import col, to_timestamp, current_timestamp, lit
import os

# COMMAND ----------

# Always define schema explicitly in production
# Never use inferSchema=True on large data — it does a full scan

raw_schema = StructType([
    StructField("date",   StringType(),  True),  # keep as string in Bronze
    StructField("open",   DoubleType(),  True),
    StructField("high",   DoubleType(),  True),
    StructField("low",    DoubleType(),  True),
    StructField("close",  DoubleType(),  True),
    StructField("volume", LongType(),    True)
])

# COMMAND ----------

dbutils.fs.ls("/Volumes/workspace/default/nifty50_raw/")

# COMMAND ----------

# Update this path to where you uploaded the CSV in Databricks
BASE_PATH = "/Volumes/workspace/default/nifty50_raw/"

FILES = {
    "nifty50_minute"    : f"{BASE_PATH}/nifty50_minute.csv",
    "nifty50_5minute"   : f"{BASE_PATH}/nifty50_5minute.csv",
    "nifty50_day"       : f"{BASE_PATH}/nifty50_day.csv",
    "india_vix_minute"  : f"{BASE_PATH}/india_vix_minute.csv",
    "india_vix_5minute" : f"{BASE_PATH}/india_vix_5minute.csv",
    "india_vix_day"     : f"{BASE_PATH}/india_vix_day.csv",
}

# COMMAND ----------

def ingest_bronze(file_key, file_path, schema):
    """
    Reads a raw CSV and adds pipeline metadata columns.
    No transformations — Bronze is raw + metadata only.
    """
    print(f">>> Ingesting: {file_key}")
    
    df = spark.read.format("csv") \
        .option("header", True) \
        .option("nullValue", "") \
        .option("mode", "PERMISSIVE") \
        .schema(schema) \
        .load(file_path)
    
    # Add metadata columns
    df = df \
        .withColumn("_source_file",    lit(file_key)) \
        .withColumn("_ingested_at",    current_timestamp()) \
        .withColumn("_pipeline_layer", lit("bronze"))
    
    print(f"    Rows     : {df.count():,}")
    print(f"    Columns  : {df.columns}")
    print()
    
    return df

# COMMAND ----------

DELTA_BASE = "/Volumes/workspace/default/nifty50_raw/bronze"

for file_key, file_path in FILES.items():
    
    df = ingest_bronze(file_key, file_path, raw_schema)
    
    delta_path = f"{DELTA_BASE}/{file_key}"
    
    df.write.format("delta") \
        .mode("overwrite") \
        .option("overwriteSchema", "true") \
        .save(delta_path)
    
    print(f"✅ Written to Delta: {delta_path}")
    print("-------------------------------------------")

# COMMAND ----------

df_check = spark.read.format("delta").load(f"{DELTA_BASE}/nifty50_minute")

print("Row count  :", df_check.count())
print("Schema     :")
df_check.printSchema()
print("Sample rows:")
df_check.show(5, truncate=False)

# COMMAND ----------

df_check_vix = spark.read.format("delta").load(f"{DELTA_BASE}/india_vix_minute")

print("Row count  :", df_check.count())
print("Schema     :")
df_check.printSchema()
print("Sample rows:")
df_check.show(5, truncate=False)