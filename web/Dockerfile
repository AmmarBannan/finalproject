FROM node:18 AS builder
WORKDIR /app

# Copy package manifests first to leverage Docker layer caching
COPY package*.json ./

# If a lockfile exists use npm ci (faster, deterministic). Otherwise fall back to npm install.
RUN if [ -f package-lock.json ]; then \
      npm ci --prefer-offline --no-audit --progress=false; \
    else \
      npm install --no-audit --progress=false; \
    fi

# Copy source and build
COPY . .
RUN npm run build

# Production image: serve the built files with nginx
FROM nginx:stable-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

CMD ["npm", "run", "preview", "--", "--host"]
