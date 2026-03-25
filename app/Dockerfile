# Multi-stage build with distroless final image
FROM golang:1.25 AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o /server ./cmd/api

# Distroless image runs as nonroot (UID 65532) by default
FROM gcr.io/distroless/static-debian12:nonroot

# Copy the binary
COPY --from=builder /server /server

# Port must be > 1024 since we are not root
EXPOSE 8080

ENTRYPOINT ["/server"]
