# syntax=docker/dockerfile:1

FROM golang:1.22 AS builder
WORKDIR /app

# Install dependencies before copying the whole tree to leverage Docker layer caching
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

# Copy project sources and build the service binary
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o todo-api ./cmd/api

FROM gcr.io/distroless/base-debian12
WORKDIR /srv

# Default runtime configuration values; override through environment variables
ENV APP_PORT=8080 \
    DB_HOST=db \
    DB_PORT=3306 \
    DB_USER=app \
    DB_PASSWORD=app-secret \
    DB_NAME=todo

COPY --from=builder /app/todo-api ./todo-api
EXPOSE 8080
ENTRYPOINT ["/srv/todo-api"]
