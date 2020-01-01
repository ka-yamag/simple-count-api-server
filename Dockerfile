FROM scratch

ENV PORT 8080

ADD ./target/linux/server /server

ENTRYPOINT ["/server"]
