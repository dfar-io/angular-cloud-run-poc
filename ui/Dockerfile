FROM node:18-slim

WORKDIR /usr/app
COPY ./ /usr/app

RUN npm i -g @angular/cli@15.1.0
RUN npm i
RUN npm run build

EXPOSE 4200

CMD [ "node", "index.js" ]