FROM ubuntu:18.04

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN apt-get update && \
      apt-get install -y wget curl gnupg2 postgresql-server-dev-all postgresql-client && \
      curl -sSL https://get.haskellstack.org/ | sh && \
      rm -rf /var/lib/apt/lists/*

RUN stack setup --resolver lts-12.2

RUN mkdir -p /builds/lorepub/moot
WORKDIR /builds/lorepub/moot

RUN curl -sL https://deb.nodesource.com/setup_9.x -o nodesource_setup.sh && \
      bash nodesource_setup.sh && \
      apt-get install -y nodejs

COPY frontend/package.json package.json

RUN npm install -g gulp

RUN addgroup --gid 1000 docker && \
    adduser --uid 1000 --ingroup docker --home /home/docker --shell /bin/sh --disabled-password --gecos "" docker

# install fixuid
RUN USER=docker && \
    GROUP=docker && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.1/fixuid-0.1-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml
USER docker:docker    
ENTRYPOINT ["fixuid"]
