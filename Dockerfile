FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    squid \
    curl \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 3128

CMD ["squid", "-N"]