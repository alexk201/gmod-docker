FROM docker.io/cm2network/steamcmd:steam-trixie

EXPOSE 27015/tcp 27015/udp 27005/udp

USER root

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tini ca-certificates && apt-get autoremove -y && apt-get clean
ENV DEBIAN_FRONTEND=dialog

USER steam

RUN ./steamcmd.sh +login anonymous +quit
RUN ./steamcmd.sh +force_install_dir /home/steam/gmod +login anonymous +app_update 4020 -beta x86-64 validate +quit
RUN ./steamcmd.sh +force_install_dir /home/steam/css +login anonymous +app_update 232330 validate +quit

RUN mkdir -p /home/steam/.steam/sdk32 /home/steam/.steam/sdk64 \
 && ln -sf /home/steam/steamcmd/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so \
 && ln -sf /home/steam/steamcmd/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

# SET GMOD MOUNT CONTENT
RUN echo '"mountcfg" {"cstrike" "/home/steam/css/cstrike"}' > /home/steam/gmod/garrysmod/cfg/mount.cfg

# CREATE FOLDER STRUCTURES (DB, CACHE, ...)
RUN mkdir -p /home/steam/gmod/garrysmod/data && mkdir -p /home/steam/gmod/steam_cache/content && mkdir -p /home/steam/gmod/garrysmod/cache/srcds

# CREATE DATABASE FILE
RUN touch /home/steam/gmod/garrysmod/data/sv.db \
 && ln -sf /home/steam/gmod/garrysmod/data/sv.db /home/steam/gmod/garrysmod/sv.db

ENV LD_LIBRARY_PATH=/home/steam/gmod/bin/linux64:/home/steam/gmod/linux64:/home/steam/gmod:/home/steam/.steam/sdk64

# START THE SERVER
WORKDIR /home/steam/gmod

ENTRYPOINT ["tini", "--", "/home/steam/gmod/bin/linux64/srcds", "-game", "garrysmod", "-console", "-steam_dir", "/home/steam/steamcmd", "-steam_cache_dir", "/home/steam/gmod/steam_cache"]
