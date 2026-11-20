#!/bin/bash

# Activer l'arrêt immediat en cas d'erreur
set -e

# Utiliser $1 comme nom de conteneur, ou "site" par defaut
CONTAINER="${1:-site}"

# Verifier que Docker est disponible
if ! command -v docker >/dev/null 2>&1; then
    echo "Erreur : Docker n'est pas installe."
    exit 1
fi

# Verifier l'existence du conteneur
if ! docker ps -a --format '{{.Names}}' | grep -Fxq "$CONTAINER"; then
    echo "Erreur : le conteneur '$CONTAINER' n'existe pas."
    exit 1
fi

# Lire les journaux Apache du conteneur
LOGS="$(docker logs "$CONTAINER" 2>&1)"

# Compter les lignes contenant une methode HTTP et un code de retour
TOTAL="$(printf '%s\n' "$LOGS" | grep -E '"(GET|POST|HEAD|PUT|DELETE|PATCH|OPTIONS) ' | cut -d ' ' -f 1 | sort | uniq -c | awk '{sum += $1} END {print sum+0}')"

# Afficher la phrase appropriee en absence de visites
if [ "$TOTAL" -eq 0 ]; then
    echo "Aucune visite enregistree."
    exit 0
fi

# Compter les reponses HTTP 404 avec grep puis cut
NOT_FOUND="$(printf '%s\n' "$LOGS" | grep -E '"(GET|POST|HEAD|PUT|DELETE|PATCH|OPTIONS) ' | cut -d ' ' -f 9 | grep -cx '404' || true)"
# Extraire les adresses IP, les trier, compter et ordonner les frequences
TOP_IP="$(printf '%s\n' "$LOGS" | grep -E '"(GET|POST|HEAD|PUT|DELETE|PATCH|OPTIONS) ' | cut -d ' ' -f 1 | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')"
# Extraire les pages demandees, les trier, compter et ordonner les frequences
TOP_PAGE="$(printf '%s\n' "$LOGS" | grep -E '"(GET|POST|HEAD|PUT|DELETE|PATCH|OPTIONS) ' | cut -d ' ' -f 7 | sort | uniq -c | sort -nr | head -n 1 | awk '{print $2}')"

# Afficher les statistiques
echo "Nombre total de requetes HTTP : $TOTAL"
echo "Nombre de requetes 404 : $NOT_FOUND"
echo "IP la plus active : ${TOP_IP:-aucune}"
echo "Page la plus demandee : ${TOP_PAGE:-aucune}"
