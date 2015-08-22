# nginx-ensite

Ce script a pour but de faire un equivalent à a2ensite de nginx.

## Utilisation

3 choix sont possibles :

* enable : Active un server block de nginx
* disable : Desactive un server block de nginx
* list : Liste les servers blocks de nginx disponibles dans vos dossiers sites-available et sites-enabled

Je vous conseille de mettre directement le script dans un dossier de **$PATH** afin d'éviter d'écrire bash... à chaque fois.

Par défaut, le dossier **/usr/bin** fait partie de la variable $PATH.

Je vous conseille également de le renommer sans le .sh, ce qui est plus "propre" si vous mettez le script dans votre **$PATH**

## Exemples

Je veux :
* Activer mon server block test.conf : "nginx-ensite enable test.conf"
* Désactiver mon server block test.conf : "nginx-ensite disable test.conf"
* Lister tous mes server blocks : "nginx-ensite list"
 
A chaque fois que vous activez ou désactivez un server block un redémarrage de nginx est fait automatiquement.

**Si vous utilisez systemd**, vous devrez probablement changer la variable SERVICE en début de script.

Ce script fonctionne par un système de liens symboliques entre sites-enabled et sites-available.

Si vous avez directement votre fichier dans sites-enabled, et que vous le désactivez par mégarde, pas de panique, le script est capable de detecter s'il s'agit d'un lien symbolique ou pas et ne supprimera que les liens symboliques.

