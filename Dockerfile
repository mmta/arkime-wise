FROM node:current-alpine as builder

RUN apk update && \
      apk upgrade && \
      apk add --update --no-cache --virtual .gyp python2 make g++ git

ENV PYTHON=/usr/bin/python2
RUN npm install -g node-gyp

RUN git clone https://github.com/arkime/arkime.git

WORKDIR /arkime

# fix navbar icon ..
RUN sed -i 's/assets/static\/img/' /arkime/wiseService/vueapp/src/components/Navbar.vue

# build vueapp
RUN npm install --production=false
RUN npm run wise:build

RUN cp /arkime/assets/Arkime_Icon_ColorMint.png /arkime/wiseService/vueapp/dist/static/img/

WORKDIR /arkime/wiseService

# remove dependency on viewer
RUN cp /arkime/viewer/version.js.in ./version.js
RUN sed -i 's/..\/viewer\/version/.\/version.js/' wiseService.js

# install npm packages required by wise with version taken from arkime package.json as needed
ADD ./install_pkg.sh /arkime/wiseService/
RUN ./install_pkg.sh && rm ./install_pkg.sh

FROM node:current-alpine

RUN apk update && apk upgrade && \
      apk add --update ca-certificates && \
      rm /var/cache/apk/*

# s6-overlay
RUN wget -qO- https://github.com/just-containers/s6-overlay/releases/download/v1.20.0.0/s6-overlay-amd64.tar.gz | tar xvz -C /
ADD s6files /etc/
ENV S6_KEEP_ENV 1
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

WORKDIR /wiseService
COPY --from=builder /arkime/wiseService .

# there's error in wiseService.ini.sample because of the zeus config, so we use this one
COPY wise.ini /wiseService/etc/wise.ini
RUN echo "127.0.0.1/8,blacklisted localhost -- testing only" >> /wiseService/etc/testing.csv

# this can be set to combination of --debug --webconfig --insecure --workers n
ENV WISE_OPTION ""

EXPOSE 8081
VOLUME [ "/wiseService/etc" ]
ENTRYPOINT ["/init"]


