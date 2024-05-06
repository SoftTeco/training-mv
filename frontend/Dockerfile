FROM node:16 as build

WORKDIR /app

COPY package.json /app

RUN yarn install
COPY jsconfig.json /app
COPY next.config.js /app
COPY src/pages /app/src/pages
COPY src/styles /app/src/styles
COPY public /app/public
COPY hooks /app/hooks
COPY lib /app/lib

RUN yarn run build

FROM node:16-alpine

WORKDIR /app

COPY --from=build /app/node_modules /app/node_modules
COPY --from=build /app/package.json /app/package.json
COPY --from=build /app/.next /app/.next
COPY --from=build /app/src/pages/ /app/src/pages/
COPY --from=build /app/src/styles/ /app/src/styles/
COPY --from=build /app/public /app/public/
COPY --from=build /app/next.config.js /app/next.config.js
COPY --from=build /app/hooks /app/hooks
COPY --from=build /app/lib /app/lib
COPY --from=build /app/jsconfig.json /app/jsconfig.json

CMD yarn run start
RUN apk update && apk add bash

