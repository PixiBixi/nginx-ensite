# Autocomplétion bash pour nginx_ensite
# À placer dans /etc/bash_completion.d/ ou à sourcer dans ~/.bashrc

_nginx_ensite() {
	local cur prev commands nginx_available nginx_enabled
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	commands="enable disable status list help"
	nginx_available="/etc/nginx/sites-available"
	nginx_enabled="/etc/nginx/sites-enabled"

	case "$prev" in
		enable | status)
			if [[ -d "$nginx_available" ]]; then
				COMPREPLY=($(compgen -W "$(ls "$nginx_available" 2>/dev/null)" -- "$cur"))
			fi
			;;
		disable)
			if [[ -d "$nginx_enabled" ]]; then
				COMPREPLY=($(compgen -W "$(ls "$nginx_enabled" 2>/dev/null)" -- "$cur"))
			fi
			;;
		*)
			COMPREPLY=($(compgen -W "$commands" -- "$cur"))
			;;
	esac
}

complete -F _nginx_ensite nginx_ensite
complete -F _nginx_ensite nginx-ensite
