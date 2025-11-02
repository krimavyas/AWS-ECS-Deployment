# ---- Build stage ----

FROM node:20-alpine AS build

# Set working directory inside container
WORKDIR /app

# Copy dependency files first
COPY package.json package-lock.json* ./

# Install only production dependencies (no dev)
RUN npm ci --only=production || npm install --omit=dev

# Copy the application source code
COPY index.js ./

# ---- Runtime Stage ----
FROM node:20-alpine

# Set environment variable for production mode
ENV NODE_ENV=production

# Set the working directory
WORKDIR /app

# Create a non-root user and group
RUN addgroup -S nodegrp && adduser -S nodeusr -G nodegrp

# Copy only the built artifacts and necessary files from the build stage
COPY --from=build /app /app

# Drop root privileges — run the app as 'nodeusr'
USER nodeusr

# Expose the application port (used by ECS/ALB)
EXPOSE 3000

# Define a simple healthcheck to ensure the container is running properly
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -qO- http://127.0.0.1:3000/health || exit 1

# Start the Node.js application
CMD ["node", "index.js"]
