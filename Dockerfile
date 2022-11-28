FROM golang:latest AS builder
WORKDIR /root
COPY . .
RUN go build main.go


FROM debian:11-slim

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends -y ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://github.com/moby/moby/issues/2259
# Docker image with none root user cant access volumes
# Hence we create a user to map in the host
RUN useradd -u 4001 -ms /bin/bash pwuser

# prevent root user login
RUN chsh -s /usr/sbin/nologin root

WORKDIR /home/pwuser

COPY --from=builder  /root/main /home/pwuser/x-ui
COPY bin/. /home/pwuser/bin/.

RUN chown -R pwuser:pwuser /home/pwuser/bin/

USER pwuser

VOLUME [ "/etc/x-ui" ]
CMD [ "./x-ui" ]
