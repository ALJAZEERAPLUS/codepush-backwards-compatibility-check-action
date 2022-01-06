FROM ubuntu:18.04

RUN apt update && apt install -y git

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/entrypoint.sh" ]