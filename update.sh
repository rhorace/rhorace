#!/usr/bin/env bash
# Maintenance APT – mise à jour + nettoyage
# Usage:
#   ./update.sh           # mode interactif avec confirmation
#   ./update.sh -y        # non interactif (oui à tout)
#   ./update.sh --full    # inclut dist-upgrade
#   ./update.sh --full -y # full + oui à tout

set -euo pipefail

# --- Options ---
AUTO_YES="no"
DO_FULL="no"
for arg in "$@"; do
  case "$arg" in
    -y|--yes) AUTO_YES="yes" ;;
    --full)   DO_FULL="yes" ;;
    *) echo "Option inconnue: $arg"; exit 2 ;;
  esac
done

# --- Vérif. privilèges ---
if [[ $EUID -ne 0 ]]; then
  echo "⛑️  Re-lance en root (sudo)…"
  exec sudo --preserve-env=AUTO_YES,DO_FULL "$0" "$@"
fi

# --- Journalisation ---
STAMP="$(date +'%Y%m%d-%H%M%S')"
LOG="$HOME/apt-maint-$STAMP.log"
exec > >(tee -a "$LOG") 2>&1
echo "📄 Journal: $LOG"

# --- Confirmation ---
if [[ "$AUTO_YES" != "yes" ]]; then
  echo "This will: apt-get update, upgrade, ${DO_FULL:+dist-upgrade, }autoclean, autoremove."
  read -r -p "Continuer ? [y/N] " ans
  [[ "${ans:-N}" =~ ^[Yy]$ ]] || { echo "Annulé."; exit 0; }
fi

# --- Mise à jour des index ---
echo "🔄 apt-get update…"
apt-get update

# --- Afficher ce qui est upgradable ---
echo "ℹ️  Paquets pouvant être mis à jour:"
apt list --upgradable || true

# --- Upgrade standard ---
echo "⬆️  apt-get upgrade…"
apt-get upgrade -y

# --- Full upgrade optionnel ---
if [[ "$DO_FULL" == "yes" ]]; then
  echo "🧩 apt-get dist-upgrade…"
  apt-get dist-upgrade -y
fi

# --- Nettoyage ---
echo "🧹 Nettoyage (autoclean, autoremove, clean)…"
apt-get autoclean -y
apt-get autoremove -y
apt-get clean

echo "✅ Terminé. Détails dans: $LOG"

