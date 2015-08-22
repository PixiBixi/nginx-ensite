# nginx_ensite

Ce script à pour but de faire un equivalent à a2ensite de nginx

## Utilisation

3 choix son possibles :

* enable : active un server block de nginx
* disable : desactive un server block de nginx
* list : list les servers blocks de nginx disponible dans vos dossiers sites-available et sites-enabled

Je vous conseille de mettre directement le script dans un dossier de $PATH afin d'éviter d'écrire bash... à chaque fois.

Je vous conseille également de le renommer sans le .sh, ce qui est plus "propre" si vous mettez le script dans votre $PATH

## Exemples

Je veux :
* Activer mon server block test.conf : "nginx-ensite enable test.conf"
* Désactiver mon server block test.conf : "nginx-ensite disable test.conf"
* Connaitre tous mes server blocks : "nginx-ensite list"
 
A chaque fois que vous activez ou désactivez un site, un redémarrage de nginx est fait automatiquement

Si vous utilisez systemd, vous devrez probablement changer la variable SERVICE en début de script

Ce script fonctionne par un système de liens sympboliques entre sites-enabled et sites-disabled

Si vous avez directement votre fichier dans sites-enabled, et que vous le désactivez par mégarde, pas de panique, le script ne le supprimera pas et détectera l'utilisation de lien symbolique/ou pas, et vous indique lorsque qu'il s'agit d'un fichier, et non d'un lien symbolique
