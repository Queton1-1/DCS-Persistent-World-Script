# DCS-Persistent-World-Script

= FR =

Script pour sauvegarder la progression en mission si implémenté.
Les unitées sol, statiques et navires (hors portes-avions) détruits seront listés et retirés au prochain lancement.
Les unités spawnés pendant la partie peuvent être sauvés.
Basé sur les travaux des excellents Pikey et Surrexen mais énormément de refonte et beaucoup d'ajout.

-- Mises à jour / Updates --
/!\ Rien n'est jamais parfait, ce script évoluera au fil des idées d'améliorations, des bugs éventuels à corriger et surtout du temps que je peux y consacrer.

-- Installation --
Il suffit de créer un trigger avec pour condition 'temps sup. à' (1) et charger le script .lua contenu dans le .zip
Ne nécessite aucune dépendance (Moose, Mist, etc...) et ne gène pas leur fonctionnement.

Nécessite que votre fichier 'MissionScripting.lua' dans votre dossier '[...]\DCS World\Scripts' soit 'de-sanitize' car le script fait appel à des fonctions basique de la lib 'os'.
(Et à répeter après chaque mise à jour.)

Plus précisément désactiver les lignes suivantes :

    sanitizeModule('os' ),
    sanitizeModule('io' ),
    sanitizeModule('lfs' ),

en ajoutant -- devant comme suit :

    --sanitizeModule('os' ),
    --sanitizeModule('io' ),
    --sanitizeModule('lfs' ),

Pour chaque utilisation du script, pensez à régler le temps entre chaque save (300s par défaut) et le nom du fichier de sauvegarde.
Ces paramètres se trouvent dans le script, éditable avec n'importe quel éditeur texte (bloc note, notepad++, visual studio code)

-- Utilisation --
Rien de plus simple.
Si le script est bien chargé, c'est automatique et des messages s'afficheront à chaque sauvegarde.
Les fichiers de sauvegardes se situerons dans le dossier d'installation de DCS (/Program File/...) >>(versions antérieures à v2.09)
Les fichiers de sauvegardes se situerons dans le dossier Missions de DCS (/Saved Games/DCS/Missions/_PWS_Saves) >>(à partir de v2.09)




= EN =
Script to save mission progression.
All ground units, statics and boats (not carriers) destroyed will be list and destroy on next load.
During game, spawned units can be saved.
Based on the awesome Pikey and Surrexen works but with lots of rebuilds et adds.

-- Updates --
/!\ Nothing's perfect, but if you track bugs and share it, i will do my best to update the script. I'm not professionnal and like most of us, i have to share my time between familly and work also.

-- Installation --
Just create a trigger with condition time more' (1 or many seconds) and load the script .lua from .zip
Mist or Moose libs not needed.

Need 'MissionScripting.lua' 'de-sanitize' to access OS & IO lua libs.
(After every ED update, you will need to 'de-sanitize' your 'MissionScripting.lua' file.)

Comment these lines :

    sanitizeModule('os' ),
    sanitizeModule('io' ),
    sanitizeModule('lfs' ),

just add -- like below :

    --sanitizeModule('os' ),
    --sanitizeModule('io' ),
    --sanitizeModule('lfs' ),

Dont forget to set few parameters in the top of the script for every use. (Time between saves & filename prefix)

-- Use --
Easy
If well done un mission editor, messages will be displayed.
Saves file will be created in DCS application folder (/Program Files/...) >>(before v2.09)
Saves file will be created in DCS application folder (/Saved Games/DCS/Missions/_PWS_Saves) >>(after v2.09)
Enjoy!
