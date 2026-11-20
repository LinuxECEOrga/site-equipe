# Utiliser PHP avec Apache en version 8.4
FROM php:8.4-apache

# Copier uniquement le contenu du site dans le dossier public d'Apache
COPY site/ /var/www/html/

# Exposer le port HTTP d'Apache
EXPOSE 80