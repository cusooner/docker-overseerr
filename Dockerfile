FROM node:14.18-alpine AS BUILD_IMAGE
ARG VERSION
ENV VERSION=${VERSION:-v1.28.0}

WORKDIR /app

RUN apk add --no-cache python3 build-base curl
RUN ln -s /usr/bin/python3 /usr/bin/python

RUN curl -fsSL "https://github.com/sct/overseerr/archive/${VERSION}.tar.gz" | tar xzf - --strip-components=1 

RUN yarn install --frozen-lockfile --network-timeout 1000000

COPY . ./

RUN yarn build

RUN yarn install --production --ignore-scripts --prefer-offline

RUN rm -rf src server .next/cache

RUN touch config/DOCKER

FROM node:14.18-alpine
WORKDIR /app
RUN apk add --no-cache tzdata tini && rm -rf /tmp/*
COPY --from=BUILD_IMAGE /app ./
ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "yarn", "start" ]

EXPOSE 5055
