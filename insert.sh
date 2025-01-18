#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <token> <clickhouse_host>"
    exit 1
fi

mkdir -p csv

# Download the CSV file
filename=csv/$(date "+%Y-%m-%d").csv
if [ ! -f "$filename" ]; then
    echo "Downloading data"
    curl -s -L "https://ipinfo.io/data/free/country_asn.csv.gz?token=$1" -o $filename.gz

    echo "Decompressing data"
    gzip -d $filename.gz

    echo "Sanitizing data"
    mlr --csv --ifs ',' put '$asn = sub($asn, "^AS", "")' $filename > csv/tmp.csv && mv csv/tmp.csv $filename
fi

echo "Inserting data"
clickhouse-client -h $2 -q "CREATE DATABASE IF NOT EXISTS ipinfo"
clickhouse-client -h $2 -q "DROP TABLE IF EXISTS ipinfo.asn"
clickhouse-client -h $2 -q "CREATE TABLE ipinfo.asn (start_ip String, end_ip String, country_name String, continent String, continent_name String, asn UInt32, as_name String, as_domain String) ENGINE = MergeTree ORDER BY (start_ip,end_ip)"
clickhouse-client -h $2 -q "INSERT INTO ipinfo.asn FORMAT CSV" < $filename

echo "Creating dictionary"
clickhouse-client -h $2 -q "CREATE DICTIONARY ipinfo.asn_asname (asn UInt32, as_name String) PRIMARY KEY asn SOURCE(CLICKHOUSE(TABLE 'asn')) LIFETIME(3600) LAYOUT(FLAT())"
clickhouse-client -h $2 -q "SYSTEM RELOAD DICTIONARY ipinfo.asn_asname"
