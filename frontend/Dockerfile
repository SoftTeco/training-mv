FROM node:16

WORKDIR /app

COPY package.json /app
COPY yarn.lock /app

RUN yarn install
COPY jsconfig.json /app
COPY next.config.js /app
COPY src /app/src
COPY public /app/public
COPY hooks/ /app/hooks
COPY lib/ /app/lib

RUN yarn run build

CMD yarn run start
