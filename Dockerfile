FROM docker.io/cm2network/steamcmd:steam-trixie

ENV LD_LIBRARY_PATH=/home/steam/gmod/bin

EXPOSE 27015/tcp
EXPOSE 27015/udp
EXPOSE 27005/udp

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python3 tini && apt-get autoremove -y && apt-get clean
ENV DEBIAN_FRONTEND=dialog

USER steam

RUN ./steamcmd.sh +login anonymous +quit
RUN ./steamcmd.sh +force_install_dir /home/steam/gmod +login anonymous +app_update 4020 validate +quit
RUN ./steamcmd.sh +force_install_dir /home/steam/css +login anonymous +app_update 232330 validate +quit

# SET GMOD MOUNT CONTENT
RUN echo '"mountcfg" {"cstrike" "/home/steam/css/cstrike"}' > /home/steam/gmod/garrysmod/cfg/mount.cfg

# CREATE DATABASE FILE
RUN touch /home/steam/gmod/garrysmod/sv.db

# CREATE CACHE FOLDERS
RUN mkdir -p /home/steam/gmod/steam_cache/content && mkdir -p /home/steam/gmod/garrysmod/cache/srcds

# START THE SERVER
ENTRYPOINT [ "tini", "--", "/home/steam/gmod/srcds_linux" ]
