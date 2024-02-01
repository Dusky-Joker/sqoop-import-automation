#!/bin/bash

echo "Staraing Sqoop Job Automation"

# Re-starting Hadoop Daemons
stop-all.sh
start-all.sh


# In HDFS
hdfs dfs -rm -r /Data
hdfs dfs --mkdir /Data

# Import data from MySQL to HDFS for UK products
sqoop import --connect jdbc:mysql://localhost:3306/EcommerceData --username root --password-file file:///home/ubh01/Desktop/Interim\ Project/sqoop.password --table amazon_uk_products --target-dir /Data/UK --mysql-delimiters --direct -m 1


# Import data from MySQL to HDFS for USA products
sqoop import --connect jdbc:mysql://localhost:3306/EcommerceData --username root --password-file file:///home/ubh01/Desktop/Interim\ Project/sqoop.password --table amazon_usa_products --target-dir /Data/USA --mysql-delimiters --direct -m 1


rm -r /home/ubh01/Desktop/Interim\ Project/output
mkdir /home/ubh01/Desktop/Interim\ Project/output

# Get data from HDFS to local file system
hdfs dfs -get /Data/UK /home/ubh01/Desktop/Interim%20Project/output
hdfs dfs -get /Data/USA /home/ubh01/Desktop/Interim%20Project/output

echo "Sqoop Job Automation completed successfully"

