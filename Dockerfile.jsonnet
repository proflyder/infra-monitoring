FROM golang:1.23-alpine AS builder

RUN apk add --no-cache git make

# Install jsonnet and jsonnet-bundler
RUN go install github.com/google/go-jsonnet/cmd/jsonnet@latest && \
    go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest

FROM alpine:3.19

RUN apk add --no-cache make

# Copy binaries from builder
COPY --from=builder /go/bin/jsonnet /usr/local/bin/
COPY --from=builder /go/bin/jb /usr/local/bin/

WORKDIR /workspace

ENTRYPOINT ["/bin/sh"]
