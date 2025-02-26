#!/usr/bin/with-contenv bashio

# Debug : afficher les logs au démarrage
echo "🚀 Dozzle Add-on is starting..."
export BASHIO_LOG_LEVEL="debug"

# Vérifier que l'exécutable est bien disponible
if [ ! -f /usr/bin/dozzle ]; then
    echo "❌ Dozzle binary not found! Exiting..."
    exit 1
fi

# Lancer Dozzle en mode natif (sans Docker-in-Docker)
exec /usr/bin/dozzle --host 0.0.0.0 --port 8666
