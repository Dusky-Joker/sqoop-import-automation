#!/bin/bash

#Hadoop Variables
export HADOOP_HOME=/home/ubh01/hadoop-2.7.1
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/nativ"

#sqoop
export SQOOP_HOME=/home/ubh01/sqoop-1.4.7.bin__hadoop-2.6.0
export PATH=$PATH:$SQOOP_HOME/bin



# Define variables
DB_NAME="EcommerceData"
DB_USER="root"
HDFS_DIR="/Data"
LOCAL_DIR="/home/ubh01/Desktop/Interim_Project/output"
PASSWORD_FILE="/home/ubh01/Desktop/Interim_Project/sqoop.password"

echo $(date '+%Y-%m-%d %H:%M:%S')

echo "Starting Sqoop Job Automation"

# Start Hadoop Daemons
echo "Starting Hadoop Daemons..."
$HADOOP_HOME/sbin/start-all.sh

# Check if Hadoop started successfully
if [ $? -ne 0 ]; then
    echo "Failed to start Hadoop. Exiting..."
    exit 1
fi

# Turn off the safe mode
echo "Leaving Safe Mode..."
$HADOOP_HOME/bin/hdfs dfsadmin -safemode leave

# Setting HDFS
echo "Setting up HDFS directories..."
$HADOOP_HOME/bin/hdfs dfs -rm -r $HDFS_DIR
$HADOOP_HOME/bin/hdfs dfs -mkdir $HDFS_DIR

# Import data from MySQL to HDFS for UK products
echo "Importing UK products data..."
$SQOOP_HOME/bin/sqoop-import --connect jdbc:mysql://localhost:3306/$DB_NAME --username $DB_USER --password-file file://$PASSWORD_FILE --table amazon_uk_products --target-dir $HDFS_DIR/UK --mysql-delimiters --direct -m 1

# Check if Sqoop import was successful
if [ $? -ne 0 ]; then
    echo "Failed to import UK products data. Exiting..."
    exit 1
fi

# Import data from MySQL to HDFS for USA products
echo "Importing USA products data..."
$SQOOP_HOME/bin/sqoop-import --connect jdbc:mysql://localhost:3306/$DB_NAME --username $DB_USER --password-file file://$PASSWORD_FILE --table amazon_usa_products --target-dir $HDFS_DIR/USA --mysql-delimiters --direct -m 1

# Check if Sqoop import was successful
if [ $? -ne 0 ]; then
    echo "Failed to import USA products data. Exiting..."
    exit 1
fi

# Check if the local directory exists and remove it
if [ -d $LOCAL_DIR ]; then
    echo "Removing existing local directory..."
    rm -r $LOCAL_DIR
fi

# Create a new local directory
echo "Creating new local directory..."
mkdir $LOCAL_DIR

# Get data from HDFS to local file system
echo "Fetching data from HDFS to local file system..."
$HADOOP_HOME/bin/hdfs dfs -get $HDFS_DIR/UK $LOCAL_DIR
$HADOOP_HOME/bin/hdfs dfs -get $HDFS_DIR/USA $LOCAL_DIR

# Check if data fetch was successful
if [ $? -ne 0 ]; then
    echo "Failed to fetch data from HDFS. Exiting..."
    exit 1
fi

echo "Sqoop Job Automation completed successfully"
echo "/n"
echo "/n"
