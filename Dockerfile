FROM rednoah/filebot:latest

LABEL maintainer="edifus <edifus@gmail.com>"

COPY rootfs /

ENV SETTLE_DOWN_TIME "600"
ENV SETTLE_DOWN_CHECK "5 seconds ago"

ENTRYPOINT [ "/opt/bin/run-as-user", "/opt/bin/filebot-watcher" ]
