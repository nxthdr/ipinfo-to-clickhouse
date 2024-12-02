# ipinfo-to-clickhouse

This is a simple bash script that fetches free `IP to Country + ASN` ([Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/)) from [ipinfo.io](https://ipinfo.io) and inserts it into a ClickHouse database.

## Usage 

```bash
$ docker build --platform linux/amd64 -t ttl.sh/ipinfo-to-clickhouse:1h .
$ docker push ttl.sh/ipinfo-to-clickhouse:1h
```

```bash
$ docker run -ti --entrypoint=/bin/bash --network=backend --ip6=2a06:de00:50:cafe:10::1002 ttl.sh/ipinfo-to-clickhouse:1h
```