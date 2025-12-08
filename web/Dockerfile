# ===== BUILD STAGE =====
FROM node:18 AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --prefer-offline --no-audit --progress=false

COPY . .
RUN npm run build

# ===== PRODUCTION STAGE =====
FROM nginx:stable-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
