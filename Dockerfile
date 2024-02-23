FROM node:lts-alpine3.18 as base
WORKDIR /usr/src/wpp-server

# Environment variables
ENV NODE_ENV=production PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV SECRET_KEY $SECRET_KEY
ENV SECRET_KEY $HOST
ENV PORT $PORT

# Database for storing sessions
ENV MONGO_DB_DATABASE $MONGO_DB_DATABASE
ENV MONGO_DB_COLLECTION $MONGO_DB_COLLECTION
ENV MONGO_DB_USER $MONGO_DB_USER
ENV MONGO_DB_PASSWORD $MONGO_DB_PASSWORD
ENV MONGO_DB_HOST $MONGO_DB_HOST
ENV MONGO_DB_URL_REMOTE $MONGO_DB_URL_REMOTE
ENV MONGO_DB_PORT $MONGO_DB_PORT

# S3 configuration for storing media
ENV AWS_S3_REGION $AWS_S3_REGION
ENV AWS_S3_ACCESS_KEY $AWS_S3_ACCESS_KEY
ENV AWS_S3_SECRET_KEY $AWS_S3_SECRET_KEY
ENV AWS_S3_DEFAULT_BUCKET_NAME $AWS_S3_DEFAULT_BUCKET_NAME
ENV AWS_S3_ENDPOINT $AWS_S3_ENDPOINT
ENV AWS_S3_FORCED_PATH_STYLE $AWS_S3_FORCED_PATH_STYLE

COPY package.json ./
RUN yarn install --production --pure-lockfile && \
    yarn cache clean

FROM base as build
WORKDIR /usr/src/wpp-server
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
COPY package.json  ./
RUN yarn install --production=false --pure-lockfile && \
    yarn cache clean
COPY . .
RUN yarn build


FROM base
WORKDIR /usr/src/wpp-server/
RUN apk add --no-cache chromium
RUN yarn cache clean
COPY . .
COPY --from=build /usr/src/wpp-server/ /usr/src/wpp-server/
EXPOSE 21465
ENTRYPOINT ["node", "dist/server.js"]
