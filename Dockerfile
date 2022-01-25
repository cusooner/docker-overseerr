FROM node:14.18-alpine AS BUILD_IMAGE
ARG VERSION
ENV VERSION=${VERSION:-v1.28.0}
#ENV NODE_OPTIONS=--openssl-legacy-provider

RUN apk add --no-cache git curl
WORKDIR /output
# clone repo from github into /src
#RUN git clone https://github.com/sct/overseerr.git --branch ${VERSION} /src
# alternatively curl the repo
RUN curl -o /tmp/overseerr.tar.gz -L "https://github.com/sct/overseerr/archive/${VERSION}.tar.gz" && \
    mkdir -p /src && \
    tar xzf /tmp/overseerr.tar.gz -C /src --strip-components=1

# copy selected files from src into working dir
RUN cp -a /src/.eslintrc.js /src/babel.config.js /src/next-env.d.ts \
        /src/next.config.js /src/ormconfig.js /src/package.json \
        /src/postcss.config.js /src/stylelint.config.js /src/tailwind.config.js \
        /src/tsconfig.json /src/yarn.lock /src/overseerr-api.yml .

RUN yarn install --frozen-lockfile --network-timeout 1000000

RUN cp -a /src/server /src/src /src/public .
RUN yarn run build
RUN yarn install --production --ignore-scripts --prefer-offline

ENV COMMIT_TAG=${VERSION}
RUN echo "{\"commitTag\": \"${COMMIT_TAG}\"}" > committag.json

RUN ln -s /config config
#RUN touch config/DOCKER

RUN rm -rf src server .eslintrc.js babel.config.js next-env.d.ts next.config.js postcss.config.js \
        stylelint.config.js tailwind.config.js tsconfig.json yarn.lock


# =============================================================================

FROM node:14.18-alpine
WORKDIR /app

COPY --from=BUILD_IMAGE /output/ ./
#RUN apk add --no-cache nodejs npm yarn tzdata tini && rm -rf /tmp/*

LABEL org.label-schema.name="overseerr" \
      org.label-schema.description="Request management and media discovery tool for the Plex ecosystem" \
      org.label-schema.url="https://docs.overseerr.dev" \
      org.label-schema.version=${VERSION}

VOLUME ["/config"]
EXPOSE 5055/TCP

# delayed healthcheck as the startup can take a while on slow NAS systems
HEALTHCHECK --start-period=120s --interval=60s --timeout=10s \
    CMD wget -qO /dev/null "http://localhost:5055/api/v1/status"

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "yarn", "start" ]


