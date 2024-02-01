#!/bin/bash

# Define variables
DB_NAME="EcommerceData"
DB_USER="root"
HDFS_DIR="/Data"

echo "Starting Sqoop Job Automation"

# Re-start Hadoop Daemons
echo "Restarting Hadoop Daemons..."
stop-all.sh
start-all.sh

# Check if Hadoop started successfully
if [ $? -ne 0 ]; then
    echo "Failed to start Hadoop. Exiting..."
    exit 1
fi

# Turn off the safe mode
echo "Leaving Safe Mode..."
hdfs dfsadmin -safemode leave

# Setting HDFS
echo "Setting up HDFS directories..."
hdfs dfs -rm -r $HDFS_DIR
hdfs dfs -mkdir $HDFS_DIR

# Import data from MySQL to HDFS for UK products
echo "Importing UK products data..."
sqoop import --connect jdbc:mysql://localhost:3306/$DB_NAME --username $DB_USER --password-file file:///home/ubh01/Desktop/Interim\ Project/sqoop.password --table amazon_uk_products --target-dir $HDFS_DIR/UK --mysql-delimiters --direct -m 1

# Check if Sqoop import was successful
if [ $? -ne 0 ]; then
    echo "Failed to import UK products data. Exiting..."
    exit 1
fi

# Import data from MySQL to HDFS for USA products
echo "Importing USA products data..."
sqoop import --connect jdbc:mysql://localhost:3306/$DB_NAME --username $DB_USER --password-file file:///home/ubh01/Desktop/Interim\ Project/sqoop.password --table amazon_usa_products --target-dir $HDFS_DIR/USA --mysql-delimiters --direct -m 1

# Check if Sqoop import was successful
if [ $? -ne 0 ]; then
    echo "Failed to import USA products data. Exiting..."
    exit 1
fi

# Check if the local directory exists and remove it
if [ -d /home/ubh01/Desktop/Interim\ Project/output ]; then
    echo "Removing existing local directory..."
    rm -r /home/ubh01/Desktop/Interim\ Project/output
fi

# Create a new local directory
echo "Creating new local directory..."
mkdir /home/ubh01/Desktop/Interim\ Project/output

# Get data from HDFS to local file system
echo "Fetching data from HDFS to local file system..."
hdfs dfs -get $HDFS_DIR/UK /home/ubh01/Desktop/Interim%20Project/output
hdfs dfs -get $HDFS_DIR/USA /home/ubh01/Desktop/Interim%20Project/output

# Check if data fetch was successful
if [ $? -ne 0 ]; then
    echo "Failed to fetch data from HDFS. Exiting..."
    exit 1
fi

echo "Sqoop Job Automation completed successfully"

