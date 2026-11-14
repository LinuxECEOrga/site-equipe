#!/bin/bash
set -e

REPO="$HOME/serveur/site-equipe"

if [ ! -d "$REPO" ]; then
    echo "Erreur : le dossier du projet n'existe pas."
    exit 1
fi

cd "$REPO"

git pull origin main

sudo cp index.html style.css /var/www/html/

echo "Déploiement terminé avec succès !"
