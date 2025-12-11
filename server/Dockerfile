# Use Node.js Alpine image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install production dependencies
RUN npm ci --only=production || npm install --only=production

# Copy application source
COPY . .

# Expose backend port (matches K8s deployment)
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
