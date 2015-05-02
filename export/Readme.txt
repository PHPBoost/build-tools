Ce script permet de générer les différents zips nécessaires pour une version.

installer mercurial, zip, unzip et java avant de commencer

Exécuter ./make-build.sh pour créer les fichiers zip (phpboost 4.1 par défaut si pas d'options)

Possibilité de spécifier la branche voulue :
./make-build.sh -b <branche>
Liste des branches disponibles : 3.0, 4.0, 4.1
Le script se charge de cloner le repo s'il n'est pas présent sur la machine.
Les différents zip sont placés dans le dossier builds (les dossiers dézippés sont laissés pour contrôler le contenu si besoin.

Todo :
- Possibilité de taguer une nouvelle version automatiquement
- Possibilité de générer des versions sur le trunk pour alpha/beta/rc