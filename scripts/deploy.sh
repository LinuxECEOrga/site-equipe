#!/bin/bash

# Activer l'arrêt immediat en cas d'erreur
set -e

# Determiner le dossier racine du depot depuis l'emplacement du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Se placer a la racine du depot
cd "$SCRIPT_DIR/.."

# Verifier que Docker est disponible
if ! command -v docker >/dev/null 2>&1; then
    echo "Erreur : Docker n'est pas installe ou n'est pas accessible."
    exit 1
fi

# Recuperer les dernieres references distantes
git fetch origin main
# Basculer sur la branche principale
git checkout main
# Mettre a jour main sans fusion implicite
git pull --ff-only origin main

# Construire l'image du site
docker build -t site-equipe .

# Supprimer l'ancien conteneur s'il existe
docker rm -f site >/dev/null 2>&1 || true
# Demarrer le nouveau conteneur sur le port 8081
docker run -d --name site -p 8081:80 site-equipe

# Attendre puis verifier la reponse HTTP locale
if curl --fail --silent --show-error --retry 10 --retry-delay 1 --retry-connrefused http://localhost:8081/ >/dev/null; then
    echo "Succes : le site est accessible sur http://localhost:8081/"
else
    echo "Echec : impossible d'acceder au site sur http://localhost:8081/" >&2
    exit 1
fi
