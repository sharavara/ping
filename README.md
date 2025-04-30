# Ping API

A simple ping API service written in Go.

## Overview

This service provides a `/ping` endpoint that returns information about the service, including:
- Current time
- Service name
- Service version
- Docker image name
- Host IP address
- Container IP address
- Environment (prod, dev, staging)

## Build and Run

### Build Go application

```bash
go build -o app .
```

### Run the application

```bash
./app
```

## Docker

### Build Docker image

Build local image

```bash
make puild
```


Build image and push to repository

```bash
make push
```

### Run Docker container

```bash
# Run with default settings
docker run --rm -p 8080:8080 sharavara/ping:latest

# Run with specific environment
docker run --rm -p 8080:8080 -e ENV=prod sharavara/ping:latest
```

## API Usage

```bash
curl http://localhost:8080/ping
```

Response:
```json
{
  "time": "2025-04-29T12:00:00Z",
  "service_name": "ping",
  "version": "0.1.0",
  "docker_image": "sharavara/ping:latest",
  "container_ip": "172.17.0.2",
  "environment": "dev",
  "commit_author": "John Doe"
}
```

## Architecture

- Multi-architecture support (arm and x86)
- Minimal Docker image using multi-stage builds
- Security best practices (non-root user)
- Alpine Linux base image