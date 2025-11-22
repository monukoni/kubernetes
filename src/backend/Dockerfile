FROM golang:tip-alpine3.22 AS builder

WORKDIR /builder

COPY go.mod ./
RUN go mod download

COPY . ./
RUN go build -o app

FROM alpine:3.15

WORKDIR /app

COPY --from=builder /builder/app ./

EXPOSE 80

ENTRYPOINT ["./app"]