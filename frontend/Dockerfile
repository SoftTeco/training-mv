FROM node:16

WORKDIR /app

ENV NEXT_PUBLIC_API_PORT=8003
ENV NEXT_PUBLIC_API_URL=http://localhost:${NEXT_PUBLIC_API_PORT}/graphql

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
