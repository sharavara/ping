FROM golang:1.22-alpine AS builder

WORKDIR /app

# Set build arguments
ARG VERSION=0.0.1
ARG COMMIT_SHA=dev
ARG IMAGE_NAME=sharavara/ping
ARG REPOSITORY=https://github.com/sharavara/ping
ARG COMMIT_AUTHOR=unknown

RUN apk add --no-cache git ca-certificates tzdata

# Copy go mod and sum files
COPY go.mod ./
#COPY go.sum ./
#RUN go mod download

# Copy source code
COPY . .

# Build the application with build information
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags "\
        -s -w \
        -X 'main.version=${VERSION}' \
        -X 'main.commitSHA=${COMMIT_SHA}' \
        -X 'main.dockerImage=${IMAGE_NAME}:${VERSION}' \
        -X 'main.repository=${REPOSITORY}' \
        -X 'main.commitAuthor=${COMMIT_AUTHOR}'" \
    -o app .
    
# Create a minimal production image
FROM alpine:3.21.3 AS final

# Add non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Install necessary runtime dependencies
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/app .

# Set ownership for security
RUN chown -R appuser:appgroup /app

# Use non-root user
USER appuser

# Expose the port the app runs on
EXPOSE 8080

# Command to run
CMD ["./app"]