#
# ---------------------------------------------build stage
FROM node:16.13-alpine AS build-stage

COPY VERSION /VERSION
RUN export VERSION=$(cat /VERSION)
ARG VERSION
ENV VERSION=${VERSION:-1.28.0}

RUN apk add --no-cache git curl

WORKDIR /output
RUN curl -o /tmp/overseerr.tar.gz -L "https://github.com/sct/overseerr/archive/v${VERSION}.tar.gz" && \
    for item in package.json yarn.lock public src server .eslintrc.js babel.config.js next-env.d.ts next.config.js ormconfig.js postcss.config.js \
        stylelint.config.js tailwind.config.js tsconfig.json overseerr-api.yml; \
    do tar --strip-components=1 -zxf /tmp/overseerr.tar.gz overseerr-${VERSION}/$item; \
    done && \
    rm /tmp/overseerr.tar.gz

RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --frozen-lockfile --network-timeout 1000000 
RUN --mount=type=cache,target=./node_modules/.cache/webpack yarn run build
RUN --mount=type=cache,target=/root/.yarn YARN_CACHE_FOLDER=/root/.yarn yarn install --production --ignore-scripts --prefer-offline

#ENV COMMIT_TAG=${VERSION} 
# RUN echo "{\"commitTag\": \"${COMMIT_TAG}\"}" > committag.json && \
RUN ln -s /config config && \
    rm -rf /src src server .eslintrc.js babel.config.js next-env.d.ts next.config.js postcss.config.js \
        stylelint.config.js tailwind.config.js tsconfig.json yarn.lock


# ------------------------------------------------------------------------

#FROM node:14.18-alpine
FROM node:16.13-alpine
#FROM nginx:1.12-alpine
ENV PUID=1001 PGID=100
WORKDIR /app
COPY --from=build-stage /output/ ./
RUN apk add --no-cache tzdata tini && rm -rf /tmp/*

LABEL org.label-schema.name="overseerr" 
LABEL org.label-schema.description="Request management and media discovery tool for the Plex ecosystem" 
LABEL org.label-schema.url="https://docs.overseerr.dev" 
LABEL org.label-schema.version=${VERSION}
LABEL maintainer="thebungler@github.com"

VOLUME ["/config"]
EXPOSE 5055/TCP

# delayed healthcheck as the startup can take a while on slow NAS systems
# HEALTHCHECK --start-period=120s --interval=60s --timeout=10s \
#     CMD wget -qO /dev/null "http://localhost:5055/api/v1/status"

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "yarn", "start" ]


