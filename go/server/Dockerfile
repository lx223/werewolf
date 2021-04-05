FROM golang:1.16-alpine

COPY . /server

WORKDIR /server

RUN go build -mod=vendor -o server-binary .

ENTRYPOINT ["/server/server-binary"]