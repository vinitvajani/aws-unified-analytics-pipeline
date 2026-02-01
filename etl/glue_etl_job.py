import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

from pyspark.sql.functions import (
    trim, initcap, lower, col,
    to_timestamp, year, month, dayofmonth, to_date, lit
)

args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

df_stream = spark.read \
    .option("multiLine", False) \
    .json("s3://e-comm-proj/raw/orders/data_source=mobile_app/") \
    .withColumn("data_source", lit("mobile_app"))

df_batch = spark.read \
    .option("header", True) \
    .option("inferSchema", True) \
    .csv("s3://e-comm-proj/raw/orders/data_source=batch/") \
    .withColumn("data_source", lit("batch"))

df = df_batch.unionByName(df_stream)

df = df.filter(col("order_id").isNotNull())

df = df.withColumn("product_name", initcap(trim(col("product_name"))))
df = df.withColumn("category", initcap(trim(col("category"))))
df = df.withColumn("city", initcap(trim(col("city"))))

df = df.filter(col("quantity") > 0)

df = df.withColumn("price", col("price").cast("double"))
df = df.filter(col("price") > 0)

df = df.withColumn("status", lower(trim(col("status"))))
df = df.filter(col("status").isNotNull())

df = df.withColumn("order_timestamp", to_timestamp(col("order_timestamp")))

df = df.withColumn("source", lower(trim(col("source"))))

df = df.withColumn("order_date", to_date(col("order_timestamp")))
df = df.withColumn("year", year(col("order_timestamp")))
df = df.withColumn("month", month(col("order_timestamp")))
df = df.withColumn("day", dayofmonth(col("order_timestamp")))

df.show()

df.write.mode("overwrite") \
    .partitionBy("data_source", "year", "month", "day") \
    .parquet("s3://e-comm-proj/processed/orders/")

job = Job(glueContext)
job.init(args['JOB_NAME'], args)
job.commit()