#compdef nginx_ensite nginx-ensite
# Autocomplétion zsh pour nginx_ensite
# À placer dans un répertoire de $fpath (ex: /usr/local/share/zsh/site-functions/_nginx_ensite)

local nginx_available="/etc/nginx/sites-available"
local nginx_enabled="/etc/nginx/sites-enabled"

_nginx_ensite_sites_available() {
	local -a sites
	if [[ -d "$nginx_available" ]]; then
		sites=(${nginx_available}/*(N:t))
		_describe 'sites disponibles' sites
	fi
}

_nginx_ensite_sites_enabled() {
	local -a sites
	if [[ -d "$nginx_enabled" ]]; then
		sites=(${nginx_enabled}/*(N:t))
		_describe 'sites activés' sites
	fi
}

_nginx_ensite() {
	local -a commands
	commands=(
		'enable:Activer un server block'
		'disable:Désactiver un server block'
		'status:Afficher le statut d'\''un server block'
		'list:Lister tous les server blocks'
		'help:Afficher l'\''aide'
	)

	_arguments -C \
		'1:commande:->command' \
		'*:site:->site'

	case "$state" in
		command)
			_describe 'commandes' commands
			;;
		site)
			case "${words[2]}" in
				enable | status)
					_nginx_ensite_sites_available
					;;
				disable)
					_nginx_ensite_sites_enabled
					;;
			esac
			;;
	esac
}

_nginx_ensite "$@"
