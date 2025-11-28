FROM golang:tip-alpine3.22 AS builder

WORKDIR /builder

RUN echo "nobody:x:65534:65534:nobody:/:/sbin/nologin" > passwd
RUN echo "nobody:x:65534:" > group

COPY go.mod go.sum ./
RUN go mod download

COPY . ./
RUN go build -o app

FROM scratch

WORKDIR /app

COPY --from=builder /builder/passwd /etc/passwd
COPY --from=builder /builder/group /etc/group
USER nobody

COPY --from=builder /builder/app ./

EXPOSE 80
ENTRYPOINT ["./app"]