# DCS-Persistent-World-Script
[Update 2026-02]

Téléchargement / Download  
-- 
Pour télécharger le script, rdv à la page [Releases](https://github.com/Queton1-1/DCS-Persistent-World-Script/releases)

# = FR =  
Script pour sauvegarder la progression en mission si implémenté.   
Inspiré à la base des travaux de l'excellent Pikey.  
Ce qui est sauvegardé :
- Unités et Statics détruits
- unités et Statics spawnés
- Marks
- Warehouses (stocks des bases)
- Flags (déclencheurs)
- Variables globale libre de type table PWS_ops et PWS_datas

**Mises à jour / Updates**
--  
/!\ Rien n'est jamais parfait, ce script évoluera au fil des idées d'améliorations, des bugs éventuels à corriger et surtout du temps que je peux y consacrer.  

**Installation**  
--  
Il suffit de créer un trigger avec pour condition 'temps sup. à' (1) et charger le script .lua contenu dans le .zip (Ou plus de temps si génération d'unités pour prise en compte)  
Ne nécessite aucunes dépendances (Moose, Mist, etc...) et ne gène pas leur fonctionnement.  

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

Pour chaque utilisation du script, vérifier qu'un nom de mission est présent dans le panneau Briefing de l'éditeur de mission.  
  
Le temps entre chaque save (600s par défaut) et ce paramètre se trouve dans le script, éditable avec n'importe quel éditeur texte (bloc note, notepad++, visual studio code) 
Le dossier par défaut pour les saves est \Saved Games\DCS.Saves

**Utilisation**  
--  
Rien de plus simple.  
Si le script est bien chargé, c'est automatique et des messages s'afficheront à chaque sauvegarde.  
Les fichiers de sauvegardes se situerons dans le dossier Missions de DCS (/Saved Games/DCS.Persistence) >>(à partir de v2.16)  


  
  
  
# = EN =  
Script to save mission progression.  
During game, spawned units can be saved.  
Based on the awesome Pikey works.  
Can save :
- Units et Statics dead
- units et Statics spawned
- Marks
- Warehouses
- Flags
- Global var table PWS_ops et PWS_datas

**Updates**  
--  
/!\ Nothing's perfect, but if you track bugs and share it, i will do my best to update the script. I'm not professionnal and like most of us, i have to share my time between familly and work also.  

**Installation**  
--  
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

**Use**  
--  
Easy!  
If well done un mission editor, messages will be displayed.  
Saves file will be created in DCS application folder (/Saved Games/DCS.Persistence) >>(after v2.16)  

Enjoy!  
  
o7  

Quéton 1-1 | [YouTube](https://www.youtube.com/channel/UCkYOYKrKMwCV-3yASP9gf8Q) | [Twitch](https://www.twitch.tv/queton11) | [DCS UserFiles](https://www.digitalcombatsimulator.com/fr/files/filter/user-is-TheJGi/apply/) | [GitHub](https://github.com/Queton1-1)
