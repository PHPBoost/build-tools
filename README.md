## Introduction

Ce script permet de générer les différents zips nécessaires pour une version.

## Pré-requis

Installer git, zip, unzip et java sur votre machine avant de commencer.

## Utilisation

Exécuter ./build-version.sh pour créer les fichiers zip (pour PHPBoost 4.1 par défaut si pas d'options)

Possibilité de spécifier la branche voulue :
./build-version.sh -b <branche>

Liste des branches disponibles : 3.0, 4.0, 4.1
Le script se charge de cloner le repository s'il n'est pas présent sur la machine.
Les différents fichiers zip sont placés dans le dossier export (les dossiers dézippés sont laissés dans le dossier builds pour contrôler le contenu si besoin).

## TODO

- Possibilité de taguer une nouvelle version automatiquement avec l'option -t
- Possibilité de générer des versions sur le trunk pour alpha/beta/rc
