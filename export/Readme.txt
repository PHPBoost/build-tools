Ce script permet de g�n�rer les diff�rents zips n�cessaires pour une version.

installer mercurial, zip, unzip et java avant de commencer

Ex�cuter ./make-build.sh pour cr�er les fichiers zip (phpboost 4.1 par d�faut si pas d'options)

Possibilit� de sp�cifier la branche voulue :
./make-build.sh -b <branche>
Liste des branches disponibles : 3.0, 4.0, 4.1
Le script se charge de cloner le repo s'il n'est pas pr�sent sur la machine.
Les diff�rents zip sont plac�s dans le dossier builds (les dossiers d�zipp�s sont laiss�s pour contr�ler le contenu si besoin.

Todo :
- Possibilit� de taguer une nouvelle version automatiquement
- Possibilit� de g�n�rer des versions sur le trunk pour alpha/beta/rc