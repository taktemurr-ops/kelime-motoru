// fr: kelime ailesinin ipucu, atasözü, kategori ve eş/zıt anlam içeriği.
// Stüdyonun kendi metinleri; atasözleri halk malıdır (kamu malı).

const List<String> kCluesFr = [
  'pomme|Fruit rouge ou vert', 'pain|Cuit au four chaque jour', 'rivière|Eau qui coule', 'mer|Grande eau salée',
  'île|Terre entourée d’eau', 'montagne|Très haut relief', 'forêt|Beaucoup d’arbres', 'désert|Terre sèche et sableuse',
  'nuage|Flotte dans le ciel', 'pluie|Tombe des nuages', 'neige|Flocons blancs d’hiver', 'soleil|Étoile du jour',
  'lune|Satellite de la Terre', 'étoile|Brille la nuit', 'vent|Air qui bouge', 'glace|Eau gelée',
  'feu|Flammes et chaleur', 'pierre|Morceau de roche', 'sable|Sur la plage', 'fleur|Pousse au jardin',
  'arbre|Tronc et branches', 'feuille|Pend à la branche', 'racine|Sous la plante', 'chien|Animal qui aboie',
  'chat|Animal qui miaule', 'cheval|Animal que l’on monte', 'oiseau|Plumes et ailes', 'poisson|Nage dans l’eau',
  'abeille|Fait du miel', 'souris|Petit rongeur', 'vache|Donne du lait', 'mouton|Donne de la laine',
  'canard|Oiseau qui fait coin coin', 'hibou|Oiseau de nuit', 'lapin|Longues oreilles', 'renard|Rusé et roux',
  'ours|Grand animal des bois', 'lion|Roi des animaux', 'maison|Lieu où l’on vit', 'porte|On l’ouvre pour entrer',
  'fenêtre|Vitre dans le mur', 'toit|Couvre la maison', 'mur|Sépare les pièces', 'chaise|Pour s’asseoir',
  'table|Meuble pour manger', 'lit|Pour dormir', 'lampe|Donne de la lumière', 'horloge|Donne l’heure',
  'livre|Beaucoup de pages', 'lettre|Arrive par la poste', 'crayon|Pour écrire', 'école|Lieu pour apprendre',
  'maître|Enseigne aux enfants', 'médecin|Soigne les malades', 'cuisinier|Travaille en cuisine', 'jardin|Fleurs et potager',
  'rue|Chemin en ville', 'pont|Passe au-dessus de la rivière', 'ville|Beaucoup de maisons', 'village|Petite localité',
  'voiture|Quatre roues', 'train|Roule sur des rails', 'bateau|Navigue sur la mer', 'avion|Vole dans le ciel',
  'vélo|Deux roues et des pédales', 'lait|Boisson blanche', 'eau|Pour boire', 'fromage|Fait avec du lait',
  'miel|Sucré des abeilles', 'sucre|Rend sucré', 'sel|Assaisonne', 'soupe|Plat chaud',
  'gâteau|Dessert de fête', 'œuf|Pondu par la poule', 'nez|Pour sentir', 'œil|Pour voir',
  'oreille|Pour entendre', 'bouche|Pour parler', 'main|Cinq doigts', 'pied|Va dans la chaussure',
  'cœur|Pompe le sang', 'tête|En haut du corps', 'cheveux|Poussent sur la tête', 'dent|Pour mordre',
  'chaussure|Se porte au pied', 'chapeau|Se porte sur la tête', 'manteau|Vêtement chaud', 'bague|Bijou du doigt',
  'couleur|Rouge, bleu ou vert', 'musique|Notes et chansons', 'chanson|Se chante', 'jeu|C’est amusant',
  'ballon|Rond pour jouer', 'matin|Début du jour', 'soir|Fin du jour', 'nuit|Moment sombre',
  'semaine|Sept jours', 'année|Douze mois', 'été|Saison chaude', 'hiver|Saison froide',
  'automne|Les feuilles tombent', 'printemps|Saison des fleurs', 'ami|Personne chère', 'famille|Parents et enfants',
  'enfant|Jeune personne', 'nom|Comment on s’appelle', 'argent|Pour payer', 'marché|Lieu des achats',
  'carte|Montre le chemin', 'rêve|Images du sommeil', 'lumière|Éclaire', 'ombre|Noire derrière toi au soleil',
];

const List<String> kProverbsFr = [
  'Petit à petit le chat fait son nid', 'Petit à petit oiseau fait son nid', 'Qui vivra verra', 'Mieux vaut tard que jamais',
  'Tout vient à point à qui sait attendre', 'Qui sème le vent récolte la tempête', 'Après la pluie le beau temps', 'Une hirondelle ne fait pas le printemps',
  'Qui ne risque rien n’a rien', 'Les murs ont des oreilles', 'La nuit porte conseil', 'Rira bien qui rira le dernier',
  'Chat échaudé craint eau froide', 'Vouloir c’est pouvoir', 'Tel père tel fils', 'Qui se ressemble s’assemble',
  'Tout ce qui brille n’est pas or', 'Paris ne s’est pas fait en un jour', 'Loin des yeux loin du cœur', 'Chose promise chose due',
  'Plus on est de fous plus on rit', 'Qui trop embrasse mal étreint', 'Il faut battre le fer pendant qu’il est chaud', 'Les bons comptes font les bons amis',
  'Il ne faut pas vendre la peau de l’ours avant de l’avoir tué', 'Ce n’est pas à un vieux singe qu’on apprend à faire la grimace',
];

const List<String> kGroupsFr = [
  'Fruits|pomme poire cerise banane raisin citron orange', 'Légumes|carotte navet radis oignon tomate concombre salade', 'Animaux|chien chat cheval vache mouton chèvre âne', 'Oiseaux|pigeon corbeau hibou aigle moineau cigogne perroquet',
  'Couleurs|rouge bleu vert jaune blanc noir marron', 'Meubles|chaise table lit armoire canapé étagère commode', 'Corps|tête main pied nez œil oreille genou', 'Vêtements|chemise pantalon jupe manteau veste chaussette robe',
  'Métiers|médecin maître cuisinier boulanger pilote peintre jardinier', 'Boissons|eau lait jus café thé chocolat limonade', 'Météo|pluie neige vent brouillard grêle orage tonnerre', 'Véhicules|voiture train bus bateau vélo avion tracteur',
  'Instruments|violon guitare flûte tambour piano harpe trompette', 'Outils|marteau scie pince perceuse pelle lime ciseaux',
];

const List<String> kSynonymsFr = [
  'rapide|vite', 'grand|immense', 'petit|minuscule', 'beau|joli',
  'malin|rusé', 'commencer|débuter', 'content|joyeux', 'fin|terme',
  'chemin|sentier', 'courage|bravoure', 'parler|discuter', 'regarder|observer',
  'marcher|avancer', 'calme|tranquille',
];

const List<String> kAntonymsFr = [
  'grand|petit', 'long|court', 'chaud|froid', 'clair|sombre',
  'rapide|lent', 'vieux|jeune', 'plein|vide', 'haut|bas',
  'jour|nuit', 'dur|mou', 'beaucoup|peu', 'près|loin',
  'léger|lourd', 'pauvre|riche', 'tôt|tard', 'ouvert|fermé',
  'malade|sain', 'facile|difficile',
];
