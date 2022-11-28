FROM golang:latest AS builder
WORKDIR /root
COPY . .
RUN go build main.go


FROM debian:11-slim

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends -y ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# https://github.com/moby/moby/issues/2259
# Only root use have access to volume
# RUN useradd -ms /bin/bash pwuser
# WORKDIR /home/pwuser
# COPY --from=builder  /root/main /home/pwuser/x-ui
# COPY bin/. /home/pwuser/bin/.
# RUN chown -R pwuser:pwuser /home/pwuser/bin/
# USER pwuser

RUN groupadd -r pwuser -g 4000
RUN useradd -u 4001 -g pwuser -ms /bin/bash pwuser

WORKDIR /home/pwuser

COPY --from=builder  /root/main /home/pwuser/x-ui
COPY bin/. /home/pwuser/bin/.

RUN chown -R pwuser:pwuser /home/pwuser/bin/

USER pwuser

VOLUME [ "/etc/x-ui" ]
CMD [ "./x-ui" ]
