# ---- Stage 1: Build ----
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=dev
COPY . .

# ---- Stage 2: Runtime ----
FROM node:18-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=build /app /app
USER appuser
ENV NODE_ENV=dev
EXPOSE 3000
CMD ["node", "index.js"]
