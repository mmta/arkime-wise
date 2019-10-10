FROM node:8-alpine as builder

RUN apk update && \
      apk upgrade && \
      apk add --update --no-cache --virtual .gyp python make g++ git && \
      npm install -g node-gyp

RUN git clone https://github.com/aol/moloch.git
RUN mv /moloch/wiseService / 

# install npm packages required by wise with version taken from moloch package.json
RUN sh -c 'cd /wiseService; \
      for p in iniparser express async csv request lru-cache bson ioredis \
      console-stamp morgan connect-timeout elasticsearch splunk-sdk unzip; \
      do pkg=$(grep $p /moloch/package.json | cut -d\" -f4 | \ 
      xargs -I {} npm install --save $p@{}); done'

FROM node:8-alpine

RUN apk update && apk upgrade && \
      apk add --update ca-certificates && \
      rm /var/cache/apk/*

# s6-overlay
RUN wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v1.20.0.0/s6-overlay-amd64.tar.gz | tar xvz -C /
ADD s6files /etc/
ENV S6_KEEP_ENV 1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

WORKDIR /wiseService
COPY --from=builder /wiseService .
RUN mkdir -p etc && cp wiseService.ini.sample etc/wise.ini

# add a test plugin for easier testing
RUN echo -e '\n[file:testing]\nfile=/wiseService/etc/testing.csv\n\
      tags=testing\n\
      type=ip\n\
      column=0\n\
      format=csv\n\
      fields=field:match;shortcut:0\\nfield:description;shortcut:1\n'\
      >> etc/wise.ini && \
      sed -i -E 's/^[ ]+//' etc/wise.ini

RUN echo "127.0.0.1/8,blacklisted localhost -- testing only" >> /wiseService/etc/testing.csv

EXPOSE 8081
VOLUME [ "/wiseService/etc" ]
ENTRYPOINT ["/init"]


