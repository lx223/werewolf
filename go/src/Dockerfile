FROM golang:alpine

RUN apk update

COPY . /go/src

RUN go install server

ENTRYPOINT ["/go/bin/server"]