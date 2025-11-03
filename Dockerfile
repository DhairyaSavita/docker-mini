# === Stage 1: Build Stage (Node.js) ===
FROM node:lts-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# === Stage 2: Production Stage (Nginx) ===
FROM nginx:alpine
EXPOSE 80
RUN rm /usr/share/nginx/html/index.html
COPY --from=builder /app/build /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]