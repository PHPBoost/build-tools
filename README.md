## Introduction

Ce script permet de générer les différents zips nécessaires pour une version. Il se base sur le dernier tag.

## Pré-requis

Installer git, zip, unzip et java sur votre machine avant de commencer.

## Utilisation

Exécuter ./build-version.sh pour créer les fichiers zip (pour PHPBoost 5.0 par défaut si pas d'options)

Possibilité de générer une version de test (exemple a1) :
./build-version.sh -s <nom de la version spéciale>
Le script prend la dernière version du trunk pour créer l'archive

Possibilité de spécifier la branche voulue :
./build-version.sh -b <branche>

Liste des branches disponibles : 3.0, 4.0, 4.1 et 5.0.
Le script se charge de cloner le repository s'il n'est pas présent sur la machine.
Les différents fichiers zip sont placés dans le dossier export (les dossiers dézippés sont laissés dans le dossier builds pour contrôler le contenu si besoin).
