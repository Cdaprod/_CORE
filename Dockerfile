# Multi-stage build

# Stage 1: Build stage
FROM golang:1.20-alpine AS builder

# Install necessary dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy go.mod and go.sum to the workspace
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the application
RUN go build -o core-app ./cmd/server/main.go

# Stage 2: Final image
FROM alpine:latest

# Create a non-root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Install CA certificates
RUN apk --no-cache add ca-certificates

# Copy the built application from the build stage
COPY --from=builder /app/core-app /usr/local/bin/core-app

# Set permissions
RUN chown -R appuser:appgroup /usr/local/bin/core-app

# Switch to non-root user
USER appuser

# Expose the application port
EXPOSE 8080

# Set the entry point
ENTRYPOINT ["/usr/local/bin/core-app"]