FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    gzip \
    miller \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' |  gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | tee \
    /etc/apt/sources.list.d/clickhouse.list

RUN apt-get update && apt-get install -y \
    clickhouse-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY insert.sh /app/insert.sh

ENTRYPOINT ["/app/insert.sh"]