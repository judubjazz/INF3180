Bonjour tout le monde.

J'ai essayé de m'inspirer de vos créations des jeux de mots, mais c'était trop aléatoire pour pouvoir tester efficacement les contraintes.

j'ai donc cŕee un fichier excel qui où l'on peut visualiser le concept

les id < 10 sont des erreurs
les id entre 10 et 20 sont valides
les id en haut de 20 sont pour les triggers

en rouge c'est l'attribut qui devra causer erreur
en bleu c est le default
en orange c est l'enregistrement sur lequel sera appelé le trigger


DE PLUS

il y a qqch qui ne fonctionne pas avec les contraintes uniques. 
Dans ORDONNANCECHIRURGIE : ca sert à rien de mettre les trois attributs unique.
ils seront de facto unique par la cle primaire;

meme chose pour la table MEDICAMENT, si idMed est clé primaire, la combinaison de idMed et categorie sera aussi unique.




