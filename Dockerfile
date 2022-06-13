FROM golang:alpine AS binarybuilder
RUN apk --no-cache --no-progress add \
    gcc git musl-dev

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ARG VERSION
ARG TARGETARCH
WORKDIR /home

RUN git clone https://github.com/slackhq/nebula.git &&\
    cd nebula && VERSION=$(git describe --tags `git rev-list --tags --max-count=1`) &&\
    git checkout $VERSION &&\
    cd cmd/nebula && go build -o nebula -trimpath -ldflags="-s -w -X main.version=${VERSION:1} -X main.arch=${TARGETARCH}"


FROM alpine:latest

RUN apk --no-cache --no-progress add \
    ca-certificates \
    tzdata
ENV TZ="Asia/Shanghai"
RUN cp "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone 

WORKDIR /home
COPY --from=binarybuilder /home/nebula/cmd/nebula/nebula /usr/loval/bin/nebula

VOLUME ["/config"]

ENTRYPOINT [ "/usr/local/bin/nebula" ]
CMD ["-config", "/config/config.yaml"]
