# -----------------------
# Build stage
# -----------------------
FROM node:18-alpine AS build
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci || npm install

# Copy source files
COPY . .

# Build with empty API URL (will be replaced at runtime)
ENV VITE_API_URL=""
RUN npm run build

# -----------------------
# Production stage
# -----------------------
FROM node:18-alpine
WORKDIR /app

# Install serve
RUN npm install -g serve

# Copy built files
COPY --from=build /app/dist ./dist

# Create a script to inject environment variables at runtime
COPY entrypoint.sh ./
RUN chmod +x entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["./entrypoint.sh"]