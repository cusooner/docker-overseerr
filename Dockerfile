ARG BASEIMAGE=node:14.18-alpine


FROM ${BASEIMAGE} AS BUILD_IMAGE
ARG VERSION
ENV VERSION=${VERSION:-v1.28.0}

WORKDIR /app

RUN apk add --no-cache python3 build-base curl
RUN ln -s /usr/bin/python3 /usr/bin/python

#RUN curl -fsSL "https://github.com/sct/overseerr/archive/${VERSION}.tar.gz" | tar xzf - --strip-components=1 
RUN wget -O - "https://github.com/sct/overseerr/archive/${VERSION}.tar.gz" | tar xzf - --strip-components=1 

RUN yarn install --frozen-lockfile --network-timeout 1000000

COPY . ./

RUN yarn build

RUN yarn install --production --ignore-scripts --prefer-offline

RUN rm -rf src server .next/cache

RUN touch config/DOCKER

# =============================================================================
FROM ${BASEIMAGE}
WORKDIR /app

RUN apk add --no-cache tzdata tini && rm -rf /tmp/*

LABEL org.label-schema.name="overseerr" \
      org.label-schema.description="Request management and media discovery tool for the Plex ecosystem" \
      org.label-schema.url="https://docs.overseerr.dev" \
      org.label-schema.version=${VERSION}

COPY --from=BUILD_IMAGE /app ./

HEALTHCHECK --start-period=120s --interval=60s --timeout=10s \
    CMD wget -qO /dev/null "http://localhost:5055/api/v1/status"

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "yarn", "start" ]

EXPOSE 5055
