# Valider avant une application sur son Mac

Exécuter d’abord les [contrôles statiques](verification.md). Pour les essais
de déploiement, utiliser un macOS jetable avec un instantané et un compte de
test. Placer les deux dépôts à leur emplacement prévu et relever les
[versions des outils et applications](compatibilite.md).

## Vérifier le déploiement Mac_setup

Suivre les commandes du [guide Mac_setup](https://github.com/Masternaka/Mac_setup#simulation-et-application)
sur le Mac jetable. Comparer les états avant et après chaque scénario.

| Scénario | Vérification |
| --- | --- |
| Simulation sur un compte neuf | Les destinations annoncées correspondent au [tableau des paquets](../README.md#configurations). Aucun lien ni dossier de sauvegarde n’apparaît. |
| Première application | Les outils et plugins manquants sont préparés et les destinations des cinq paquets pointent vers leurs fichiers sources. |
| Nouvelle application | Les liens existants corrects sont conservés. |
| Fichier ordinaire préexistant | Le nouveau lien et sa sauvegarde sont présents. Le contenu sauvegardé correspond au fichier d’origine. |
| Conflit ou chemin personnalisé | Les messages correspondent au chemin détecté. Vérifier les fichiers personnels avant toute nouvelle tentative. |
| Retour arrière | Les fichiers sauvegardés reviennent à leur destination. Les liens marqués `conserve` restent en place. |

Pour valider le [parcours Stow manuel](premiere-utilisation.md#lier-un-paquet-manuellement-avec-gnu-stow),
tester un paquet seul et restaurer les copies préparées pour l’essai.

## Vérifier les applications

- Ouvrir un nouveau Zsh et vérifier le chargement des fragments, les
  complétions, l’historique et les raccourcis avec et sans plugins facultatifs.
  Avec `zsh-history-substring-search`, saisir un fragment d’une ancienne
  commande puis essayer ↑ et ↓. Vérifier aussi la recherche avec Ctrl+R.
- Vérifier la configuration et les éventuelles surcharges locales de Ghostty,
  puis le rendu de Starship en clair et en sombre.
- Vérifier l’affichage, les aperçus et les [touches Yazi](raccourcis-yazi.md),
  puis la présentation de Bat dans le terminal et dans l’aperçu fzf.

Consigner la version de macOS, les révisions des dépôts, les outils utilisés,
le résultat et les constats avant et après chaque essai.
