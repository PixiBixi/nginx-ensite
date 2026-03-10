PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
BASH_COMPLETION_DIR ?= /etc/bash_completion.d
ZSH_COMPLETION_DIR ?= /usr/local/share/zsh/site-functions

.PHONY: install uninstall

install:
	@echo "Installation de nginx-ensite..."
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 nginx_ensite.sh $(DESTDIR)$(BINDIR)/nginx-ensite
	@echo "Installé dans $(DESTDIR)$(BINDIR)/nginx-ensite"
	@if [ -d "$(BASH_COMPLETION_DIR)" ]; then \
		install -m 644 completions/nginx_ensite.bash $(BASH_COMPLETION_DIR)/nginx-ensite; \
		echo "Autocomplétion bash installée"; \
	fi
	@if [ -d "$(ZSH_COMPLETION_DIR)" ]; then \
		install -m 644 completions/nginx_ensite.zsh $(ZSH_COMPLETION_DIR)/_nginx-ensite; \
		echo "Autocomplétion zsh installée"; \
	fi
	@echo "Installation terminée."

uninstall:
	@echo "Désinstallation de nginx-ensite..."
	rm -f $(DESTDIR)$(BINDIR)/nginx-ensite
	rm -f $(BASH_COMPLETION_DIR)/nginx-ensite
	rm -f $(ZSH_COMPLETION_DIR)/_nginx-ensite
	@echo "Désinstallation terminée."
