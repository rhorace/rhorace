#!/bin/bash

# Dossier où se trouve le script
SITE_DIR="$( cd "$( dirname "$0" )" && pwd )"

# Vérifier l'argument
if [ "$1" != "--test" ] && [ "$1" != "--apply" ]; then
    echo "Usage: $0 --test | --apply"
    exit 1
fi

if [ "$1" = "--test" ]; then
    echo "🔍 Mode simulation - affichage des fichiers et dossiers concernés"
    echo ""
    echo "---- FICHIERS (seront en chmod 644) ----"
    find "$SITE_DIR" -type f -print
    echo ""
    echo "---- DOSSIERS (seront en chmod 755) ----"
    find "$SITE_DIR" -type d -print
    echo ""
    echo "👉 Exécute $0 --apply pour appliquer les changements."
elif [ "$1" = "--apply" ]; then
    echo "➡️ Application des permissions dans $SITE_DIR ..."
    find "$SITE_DIR" -type f -exec chmod 644 {} \;
    find "$SITE_DIR" -type d -exec chmod 755 {} \;
    echo "✅ Permissions mises à jour (fichiers = 644, dossiers = 755)"
fi

