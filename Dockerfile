FROM node:16.13.1-alpine
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm","run","start:dev"]
EXPOSE 3000
