FROM node:16-alpine as build

WORKDIR /app

COPY package.json /app

RUN yarn install
COPY jsconfig.json /app
COPY next.config.js /app
COPY src /app/src
COPY public /app/public
COPY lib /app/lib
COPY hooks /app/hooks

RUN yarn run build

FROM node:16-alpine

WORKDIR /usr/app

COPY --from=build /app/node_modules /usr/app/node_modules
COPY --from=build /app/yarn.lock /usr/app/yarn.lock
COPY --from=build /app/package.json /usr/app/package.json
COPY --from=build /app/.next /usr/app/.next
COPY --from=build /app/src/pages/index.js /usr/app/src/pages/index.js
COPY --from=build /app/src/styles/ /usr/app/src/styles/
COPY --from=build /app/public /usr/app/public/
COPY --from=build /app/lib /usr/app/lib/

CMD yarn run start

