FROM golang:1.12-alpine

RUN apk update

COPY . /server

WORKDIR /server

RUN go build -mod=vendor -o server-binary .

ENTRYPOINT ["/server/server-binary"]