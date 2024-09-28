FROM docker.io/cm2network/steamcmd:steam-bookworm

EXPOSE 27015/tcp
EXPOSE 27015/udp
EXPOSE 27005/udp

USER root
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y libtinfo5:i386 python3 && apt-get clean
USER steam

RUN ./steamcmd.sh +force_install_dir /home/steam/gmod +login anonymous +app_update 4020 validate +quit
RUN ./steamcmd.sh +force_install_dir /home/steam/css +login anonymous +app_update 232330 validate +quit

# SET GMOD MOUNT CONTENT
RUN echo '"mountcfg" {"cstrike" "/home/steam/css"}' > /home/steam/gmod/garrysmod/cfg/mount.cfg

# CREATE DATABASE FILE
RUN touch /home/steam/gmod/garrysmod/sv.db

# CREATE CACHE FOLDERS
RUN mkdir -p /home/steam/gmod/steam_cache/content && mkdir -p /home/steam/gmod/garrysmod/cache/srcds

# START THE SERVER
ENTRYPOINT [ "/home/steam/gmod/srcds_run" ]