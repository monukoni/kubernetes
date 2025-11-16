FROM golang:tip-alpine3.22

WORKDIR /app

COPY . .

EXPOSE 80
RUN go get -u github.com/gorilla/mux
ENTRYPOINT [ "go", "run", "main.go" ]