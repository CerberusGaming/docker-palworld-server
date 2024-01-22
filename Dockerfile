FROM cm2network/steamcmd

LABEL org.opencontainers.image.authors="Cerberus Gaming"
LABEL org.opencontainers.image.source="https://github.com/CerberusGaming/docker-palworld-server"

ENV DEBIAN_FRONTEND   noninteractive
ENV TIMEZONE          Etc/UTC

ENV PALWORLD_PATH     /palworld
ENV UPDATE_ON_START   false
ENV COMMMUNITY_SERVER false

USER root
RUN apt-get update && apt-get install -y xdg-user-dirs xdg-utils && apt-get clean

ADD --chmod=555 --chown=${PUID}:${PUID} entrypoint.sh /entrypoint.sh

EXPOSE 8211/udp
EXPOSE 25575

ENTRYPOINT ["/entrypoint.sh"]