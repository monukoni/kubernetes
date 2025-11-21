FROM golang:tip-alpine3.22

WORKDIR /app

COPY . .

EXPOSE 80
RUN go mod download
ENTRYPOINT [ "go", "run", "main.go" ]