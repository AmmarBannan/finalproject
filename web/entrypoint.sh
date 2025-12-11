#!/bin/sh
# Replace placeholder in index.html with runtime environment variable
sed -i "s|__VITE_API_URL__|${VITE_API_URL:-/api}|g" /app/dist/index.html

# Start the server
exec serve -s dist -l 3000