FROM ghcr.io/home-assistant/amd64-base:3.15

LABEL maintainer="erreur32"


# ✅ Ajout du mode "host" pour éviter les problèmes réseau
ENV DOCKER_HOST=unix:///var/run/docker.sock

# Mettre à jour les dépôts et installer libc6-compat
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" > /etc/apk/repositories \
    && echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories \
    && apk update && apk add --no-cache libc6-compat

# Supprimer gcompat et le fichier en conflit AVANT d'installer glibc
# Supprimer gcompat proprement et forcer l'installation de glibc
RUN apk del --purge gcompat \
    && apk add --no-cache --force-overwrite libc6-compat \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.35-r1/glibc-2.35-r1.apk \
    && apk add --allow-untrusted --force-overwrite glibc-2.35-r1.apk \
    && rm -f glibc-2.35-r1.apk

# Vérifier que glibc est bien installé
RUN ldd --version || true


# 📌 **Fix des chemins pour HA (dossier `dozzle/` utilisé comme racine)**
COPY bin/dozzle /usr/local/bin/dozzle
RUN chmod +x /usr/local/bin/dozzle

# Ajouter le script de démarrage
COPY run.sh /run.sh
RUN chmod +x /run.sh

#CMD [ "/run.sh" ]
ENTRYPOINT [ "/run.sh" ]

