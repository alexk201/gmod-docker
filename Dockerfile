FROM docker.io/cm2network/steamcmd:steam-bookworm

ENV LD_LIBRARY_PATH=/home/steam/gmod/bin

EXPOSE 27015/tcp
EXPOSE 27015/udp
EXPOSE 27005/udp

USER root
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y libtinfo5:i386 python3 tini && apt-get clean
USER steam

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
