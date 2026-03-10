#!/bin/bash
#
# Copyright PixiBixi
# nGinx_enSite
# Équivalent de a2ensite/a2dissite pour nginx
#

set -euo pipefail

# CONF #
NGINX_PATH="/etc/nginx"
NGINX_AVAILABLE="$NGINX_PATH/sites-available"
NGINX_ENABLED="$NGINX_PATH/sites-enabled"
NAME=${0##*/}
VERSION="2.0.0"
# END OF CONF #

# COLORS #
if [[ -t 1 ]]; then
	BOLD="\033[1m"
	RED="\033[31m"
	GREEN="\033[32m"
	YELLOW="\033[33m"
	BLUE="\033[34m"
	CEND="\033[0m"
else
	BOLD=""
	RED=""
	GREEN=""
	YELLOW=""
	BLUE=""
	CEND=""
fi
# END OF COLORS #

# Détection du système d'init
detect_service_cmd() {
	if command -v systemctl &>/dev/null; then
		echo "systemctl"
	elif command -v service &>/dev/null; then
		echo "service"
	else
		echo ""
	fi
}

SERVICE_CMD=$(detect_service_cmd)

# Fonctions utilitaires
msg_error() {
	echo -e "${RED}${BOLD}$1${CEND}" >&2
}

msg_success() {
	echo -e "${GREEN}${BOLD}$1${CEND}"
}

msg_info() {
	echo -e "${YELLOW}${BOLD}$1${CEND}"
}

# Vérification des prérequis
preCheck() {
	local errors=0

	if [[ ! -d "$NGINX_AVAILABLE" ]]; then
		msg_error "$NGINX_AVAILABLE inexistant"
		errors=$((errors + 1))
	fi

	if [[ ! -d "$NGINX_ENABLED" ]]; then
		msg_error "$NGINX_ENABLED inexistant"
		errors=$((errors + 1))
	fi

	if ! command -v nginx &>/dev/null; then
		msg_error "nginx n'est pas installé ou n'est pas dans le PATH"
		errors=$((errors + 1))
	fi

	if [[ $errors -gt 0 ]]; then
		exit 1
	fi
}

# Test de la configuration nginx et reload
nginx_reload() {
	echo -n "Test de la configuration nginx... "
	if nginx -t &>/dev/null; then
		msg_success "OK"
	else
		msg_error "ERREUR"
		msg_error "La configuration nginx est invalide :"
		nginx -t 2>&1 | while read -r line; do
			msg_error "  $line"
		done
		msg_error "Le reload n'a pas été effectué. Corrigez la configuration."
		exit 1
	fi

	if [[ "$SERVICE_CMD" == "systemctl" ]]; then
		systemctl reload nginx
	elif [[ "$SERVICE_CMD" == "service" ]]; then
		service nginx reload
	else
		nginx -s reload
	fi
	msg_success "nginx rechargé"
}

# Activer un ou plusieurs sites
do_enable() {
	local site="$1"

	if [[ ! -f "$NGINX_AVAILABLE/$site" ]]; then
		msg_error "Fichier $site inexistant dans $NGINX_AVAILABLE"
		return 1
	fi

	if [[ -e "$NGINX_ENABLED/$site" ]]; then
		msg_info "Fichier $site déjà activé, ignoré"
		return 0
	fi

	ln -s "$NGINX_AVAILABLE/$site" "$NGINX_ENABLED/$site"
	msg_success "Site $site activé"
}

# Désactiver un ou plusieurs sites
do_disable() {
	local site="$1"

	if [[ ! -e "$NGINX_ENABLED/$site" ]]; then
		msg_error "Fichier $site inexistant dans $NGINX_ENABLED"
		return 1
	fi

	if [[ -L "$NGINX_ENABLED/$site" ]]; then
		# C'est un lien symbolique
		if [[ ! -e "$NGINX_AVAILABLE/$site" ]]; then
			msg_info "Attention : $NGINX_AVAILABLE/$site n'existe plus (lien symbolique cassé)"
		fi
		/bin/rm "$NGINX_ENABLED/$site"
		msg_success "Site $site désactivé"
	else
		# Ce n'est PAS un lien symbolique
		echo -en "${RED}${BOLD}$NGINX_ENABLED/$site n'est pas un lien symbolique. Supprimer ? (oui/non) ${CEND}"
		read -r choice
		if [[ "$choice" =~ ^(oui|o|yes|y)$ ]]; then
			/bin/rm "$NGINX_ENABLED/$site"
			msg_success "$site supprimé"
		else
			msg_info "$site non supprimé"
			return 1
		fi
	fi
}

# Afficher le statut d'un site
do_status() {
	local site="$1"

	if [[ ! -f "$NGINX_AVAILABLE/$site" ]]; then
		msg_error "$site n'existe pas dans $NGINX_AVAILABLE"
		return 1
	fi

	if [[ -L "$NGINX_ENABLED/$site" ]]; then
		msg_success "$site : activé (lien symbolique)"
	elif [[ -f "$NGINX_ENABLED/$site" ]]; then
		msg_info "$site : activé (fichier direct, pas un lien symbolique)"
	else
		msg_error "$site : désactivé"
	fi
}

# Lister les sites
do_list() {
	echo -e "${YELLOW}${BOLD}Sites disponibles ($NGINX_AVAILABLE) :${CEND}"
	local available
	available=$(/bin/ls "$NGINX_AVAILABLE" 2>/dev/null)
	if [[ -z "$available" ]]; then
		echo "  (aucun)"
	else
		while IFS= read -r site; do
			if [[ -e "$NGINX_ENABLED/$site" ]]; then
				echo -e "  ${GREEN}$site${CEND} [activé]"
			else
				echo -e "  ${RED}$site${CEND} [désactivé]"
			fi
		done <<< "$available"
	fi

	echo ""
	echo -e "${YELLOW}${BOLD}Sites activés ($NGINX_ENABLED) :${CEND}"
	local enabled
	enabled=$(/bin/ls "$NGINX_ENABLED" 2>/dev/null)
	if [[ -z "$enabled" ]]; then
		echo "  (aucun)"
	else
		while IFS= read -r site; do
			if [[ -L "$NGINX_ENABLED/$site" ]]; then
				echo -e "  ${GREEN}$site${CEND} -> $(readlink "$NGINX_ENABLED/$site")"
			else
				echo -e "  ${YELLOW}$site${CEND} (fichier direct)"
			fi
		done <<< "$enabled"
	fi
}

# Affichage de l'aide
show_help() {
	echo -e "${BLUE}${BOLD}$NAME${CEND} v$VERSION — Gestion des server blocks nginx"
	echo ""
	echo -e "${BOLD}Usage :${CEND}"
	echo -e "  $NAME enable  <site> [site2 ...]   Active un ou plusieurs server blocks"
	echo -e "  $NAME disable <site> [site2 ...]   Désactive un ou plusieurs server blocks"
	echo -e "  $NAME status  <site>               Affiche le statut d'un server block"
	echo -e "  $NAME list                         Liste tous les server blocks"
	echo -e "  $NAME --help, -h                   Affiche cette aide"
	echo -e "  $NAME --version, -v                Affiche la version"
	echo ""
	echo -e "${BOLD}Exemples :${CEND}"
	echo -e "  $NAME enable example.conf"
	echo -e "  $NAME enable site1.conf site2.conf"
	echo -e "  $NAME disable example.conf"
	echo -e "  $NAME status example.conf"
	echo -e "  $NAME list"
}

# Vérification root
if [[ $UID -ne 0 ]]; then
	msg_error "$NAME doit être exécuté en root"
	exit 1
fi

# Parse des arguments
case "${1:-}" in
	enable)
		preCheck
		shift
		if [[ $# -eq 0 ]]; then
			msg_error "Usage : $NAME enable <site> [site2 ...]"
			exit 1
		fi
		has_error=0
		for site in "$@"; do
			do_enable "$site" || has_error=1
		done
		if [[ $has_error -eq 0 ]]; then
			nginx_reload
		else
			msg_error "Des erreurs sont survenues, le reload n'a pas été effectué"
			exit 1
		fi
		;;

	disable)
		preCheck
		shift
		if [[ $# -eq 0 ]]; then
			msg_error "Usage : $NAME disable <site> [site2 ...]"
			exit 1
		fi
		has_error=0
		for site in "$@"; do
			do_disable "$site" || has_error=1
		done
		if [[ $has_error -eq 0 ]]; then
			nginx_reload
		else
			msg_error "Des erreurs sont survenues, le reload n'a pas été effectué"
			exit 1
		fi
		;;

	status)
		preCheck
		shift
		if [[ $# -eq 0 ]]; then
			msg_error "Usage : $NAME status <site>"
			exit 1
		fi
		do_status "$1"
		;;

	list)
		preCheck
		do_list
		;;

	--help | -h | help)
		show_help
		;;

	--version | -v)
		echo "$NAME v$VERSION"
		;;

	*)
		show_help
		exit 1
		;;
esac
