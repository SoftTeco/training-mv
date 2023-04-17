FROM node:16

WORKDIR /app

ARG API_URL
ARG APP_PORT

COPY package.json /app
COPY yarn.lock /app

RUN yarn install

RUN echo "NEXT_PUBLIC_API_URL=$API_URL" >>.env.local
RUN echo "PORT=$APP_PORT" >>.env.local
COPY jsconfig.json /app
COPY next.config.js /app
COPY src /app/src
COPY public /app/public
COPY hooks/ /app/hooks
COPY lib/ /app/lib
RUN export PORT=$APP_PORT

RUN yarn run build

CMD yarn run start
