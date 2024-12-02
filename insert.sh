#!/bin/sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <token> <clickhouse_host>"
    exit 1
fi

mkdir -p csv

# Download the CSV file
filename=csv/$(date "+%Y-%m-%d").csv
if [ ! -f "$filename" ]; then
    echo "Downloading"
    curl -s -L "https://ipinfo.io/data/free/country_asn.csv.gz?token=$1" -o $filename.gz

    echo "Decompressing"
    gzip -d $filename.gz

    echo "Sanitizing"
    mlr --csv --ifs ',' put '$asn = sub($asn, "^AS", "")' $filename > csv/tmp.csv && mv csv/tmp.csv $filename
fi

echo "Inserting"
clickhouse-client -h $2 -q "DROP TABLE IF EXISTS nxthdr.ipinfo"
clickhouse-client -h $2 -q "CREATE TABLE nxthdr.ipinfo (start_ip String, end_ip String, country_name String, continent String, continent_name String, asn UInt32, as_name String, as_domain String) ENGINE = MergeTree ORDER BY (start_ip,end_ip)"
clickhouse-client -h $2 -q "INSERT INTO nxthdr.ipinfo FORMAT CSV" < $filename

echo "Creating dictionary"
clickhouse-client -h $2 -q "CREATE DICTIONARY nxthdr.ipinfo_asn_asname (asn UInt32, as_name String) PRIMARY KEY asn SOURCE(CLICKHOUSE(TABLE 'ipinfo')) LIFETIME(3600) LAYOUT(FLAT())"
clickhouse-client -h $2 -q "SYSTEM RELOAD DICTIONARY nxthdr.ipinfo_asn_asname"
