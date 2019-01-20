# Niveau 1

Nous souhaitons développer une application e-santé qui permette à des professionnels de santé (`Practitioner`) d'envoyer des compte rendus médicaux (`Communication`).

Nous souhaitons connaître à la fin du mois notre CA journalier en suivant la logique métier suivante :
- 0,10 € par `Communication`
- +0,18 € si le mode couleur est demandé (valeur par défaut : `false`)
- +0,07 € par page additionnelle (la première page est déjà comprise dans les 0,10 € initiaux)
- +0,60 € si l'auteur (le `Practitioner`) a le mode "express delivery" activé (valeur par défaut : `false`)

La consigne principale pour ce niveau est donc d'écrire l'application qui va générer `output.json` à partir de `data.json`

Une fois ce challenge terminé -> [niveau suivant](https://github.com/honestica/ruby-jobs/tree/master/level2)


# Lancer les specifications:

$ bundle install
$ bundle exec rspec


# Commentaires:

J'ai utilisé une approche BDD "outside-in", en m'appuyant sur rspec pour les tests, et les libs standard de Ruby pour les conversions JSON et dates (étant donné que le format des données en entrée étaient standard).

J'ai rencontré un problème sur le fin un problème que j'ai abandonné: la sortie d'exemple présente deux décimales après la virgule même lorsqu'elles sont inutiles. J'ai essayé de le régler en utilisant les refinements mais j'ai pas obtenu de résultats dans les 15 minutes que je m'étais alloué, la différence n'étant que cosmétique.
