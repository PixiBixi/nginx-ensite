# nginx-ensite

Équivalent de `a2ensite` / `a2dissite` d'Apache pour nginx.

Permet d'activer et désactiver des server blocks nginx via un système de liens symboliques entre `sites-available` et `sites-enabled`.

## Installation

```bash
sudo make install
```

Le script sera installé dans `/usr/local/bin/nginx-ensite` et l'autocomplétion bash/zsh sera configurée automatiquement si les répertoires existent.

Pour désinstaller :

```bash
sudo make uninstall
```

### Installation manuelle

Copiez `nginx_ensite.sh` dans un dossier de votre `$PATH` :

```bash
sudo cp nginx_ensite.sh /usr/local/bin/nginx-ensite
sudo chmod +x /usr/local/bin/nginx-ensite
```

## Utilisation

```
nginx-ensite enable  <site> [site2 ...]   Active un ou plusieurs server blocks
nginx-ensite disable <site> [site2 ...]   Désactive un ou plusieurs server blocks
nginx-ensite status  <site>               Affiche le statut d'un server block
nginx-ensite list                         Liste tous les server blocks
nginx-ensite --help                       Affiche l'aide
nginx-ensite --version                    Affiche la version
```

## Exemples

```bash
# Activer un server block
nginx-ensite enable example.conf

# Activer plusieurs server blocks d'un coup
nginx-ensite enable site1.conf site2.conf

# Désactiver un server block
nginx-ensite disable example.conf

# Voir le statut d'un site
nginx-ensite status example.conf

# Lister tous les server blocks avec leur état
nginx-ensite list
```

## Fonctionnalités

- **Activation/désactivation** par liens symboliques entre `sites-available` et `sites-enabled`
- **Test automatique** de la configuration nginx (`nginx -t`) avant chaque reload
- **Reload** (et non restart) de nginx pour un rechargement sans interruption
- **Support multi-sites** : activez ou désactivez plusieurs sites en une commande
- **Détection automatique** de `systemctl` / `service` / `nginx -s reload`
- **Autocomplétion** bash et zsh
- **Protection** : le script détecte si un fichier dans `sites-enabled` est un lien symbolique ou un fichier direct, et demande confirmation avant de supprimer un fichier direct
- **Portabilité** : fonctionne sur toute distribution Linux avec nginx (pas de dépendance à `dpkg`)

## Configuration

Les chemins par défaut sont définis en haut du script :

```bash
NGINX_PATH="/etc/nginx"
NGINX_AVAILABLE="$NGINX_PATH/sites-available"
NGINX_ENABLED="$NGINX_PATH/sites-enabled"
```

## Licence

Voir le fichier [LICENSE](LICENSE).
