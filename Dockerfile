FROM node:18-bullseye AS build

ARG NEXTAUTH_SECRET
ARG DATABASE_URL

ENV NEXTAUTH_SECRET=$NEXTAUTH_SECRET
ENV DATABASE_URL=$DATABASE_URL

# Disable Next.js telemetry
ENV NEXT_TELEMETRY_DISABLED 1

WORKDIR /app

# Clone Cal.com repository
RUN git clone --depth 1 https://github.com/calcom/cal.com.git .

# Install dependencies and build
RUN corepack enable && \
    yarn install --frozen-lockfile && \
    yarn build

# Production image
FROM node:18-bullseye-slim

WORKDIR /app

# Copy built application
COPY --from=build /app /app

# Install production dependencies only
RUN corepack enable && \
    yarn install --production --frozen-lockfile && \
    yarn cache clean

# Create a non-root user
RUN useradd -m calcom && \
    chown -R calcom:calcom /app

USER calcom

# Expose application port
EXPOSE 3000

# Start the application
CMD ["yarn", "start"]