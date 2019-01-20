# Niveau 2

Nous venons de recevoir le MVP de notre application de communication e-santé. Nous souhaitons une API avec 2 endpoints pour créer une `Communication` puis pour consulter toutes les `Communication` émises.

Voici les instructions pour lancer l'application :

```bash
bundle install
rails db:create
rails db:migrate
rake populate:init
rails server
```

Cela vous permettra d'avoir une application rails avec un volume de donnée similaire à notre prédictions d'usage.

Nos premiers utilisateurs nous ont signalé que l'application était particulièrement lente ...

La consigne principale pour ce niveau est d'améliorer ces 2 endpoints.
Nous attendons une approche data driven ainsi que des explications claires sur les améliorations proposées.

## Endpoints

### Lister les `Communication`

```bash
curl -X GET http://localhost:3000/api/communications -H 'Content-Type: application/json'
```

### Créer une `Communication`

Pour cet exemple vous aurez besoin de créer un `Practitioner` en amont via : `Practitioner.create(first_name: 'Fritz', last_name: 'Kertzmann')`

```bash
curl -X POST \
  http://localhost:3000/api/communications \
  -H 'Content-Type: application/json' \
  -d '{
	"communication" : {
		"first_name" : "Fritz",
		"last_name" : "Kertzmann",
		"sent_at" : "2019-01-01"
	}
}'
```


## Démarche


### Constat et priorisation

Je commence par comparer les temps d'exécution des deux requêtes pour commencer par celle qui semble avoir le plus besoin d'optimisation:

- GET /
  Completed 200 OK in 4449ms (Views: 2.0ms | ActiveRecord: 148.2ms)
- POST /
  Completed 201 Created in 11ms (Views: 0.1ms | ActiveRecord: 15.2ms)

Visiblement l'index est un ordre de magnitude plus lent ; je commence cette requête.

N'ayant pas de tests existants sur le contrôleur et souhaitant valider mes hypothèses rapidement avant de passer du temps à écrire des tests, j'effectue mes recherches à la main.

(Je n'ajoute pas une batterie de tests pour cet exercice dont l'objecif me semble plus être d'observer mon raisonnement ; dans une situation réelle j'ajouterais les tests si le temps me le permet, probablement en utilisant https://github.com/brigade/db-query-matchers pour effectuer des assertions sur le nombre de requêtes exécutées.)


### Gain de performances sur GET /

La méthode `index` fait une ligne, assez simple de premier abord:
- la requête pour obtenir toutes les communications
- la conversion des résultats en JSON
- l'envoi de la réponse

Ma première intuition est de soupçonner la requête, plus particulièrement un problème n-query ; je regarde les logs de requête à l'exécution:
En effet, les practitionners sont chargés un par un pour chaque communication.

Un moyen simple de résoudre ce problème: utiliser l'eager-loading.

```ruby
render json: Communication.all.to_json, status: :ok
# observé dans les logs:
# - 1 requête pour les communications
# - n pour les practitionners
# Completed 200 OK in 4475ms (Views: 0.1ms | ActiveRecord: 143.5ms)

render json: Communication.includes(:practitioner).all.to_json, status: :ok
# observé dans les logs:
# - 1 requête pour les communications (36.8ms)
# - 1 pour les practitionners (1.5ms)
# Completed 200 OK in 528ms (Views: 0.2ms | ActiveRecord: 41.2ms)
```

Gain d'un ordre de magnitude environ sur la requête totale (5s => 0.5s).


### Gains de performance sur POST /

Un peu plus compliqué:
- recherche du practitioner correspondant aux nom et prénom fournis
- création d'une nouvelle instance de communiction et sauvegarde
- envoi des résultats

En exécutant la requête je constate dans les logs que le practitioner est chargé deux fois, ce qui me semble inutile. Effectivement, le practitioner est chargé et son identifiant est donné à la nouvelle communication ; avant de la sauvegarder (ou avant de la convertir en json) le practitioner est effectivement re-chargé.

Pour résoudre ce problème, je fournis à la communication le practitioner obtenu auparavant plutôt que son id:
```Ruby
communication = Communication.new(practitioner_id: practitioner.id, sent_at: communication_params[:sent_at])
# le practitioner est chargé deux fois

communication = Communication.new(practitioner: practitioner, sent_at: communication_params[:sent_at])
# le practitioner n'est chargé qu'une seule fois
```

Gain sur la requête: 15ms => 12ms (moyenne)


J'ai ensuite l'intuition que la recherche du practitioner n'est pas optimisée ; la recherche par nom/prénom utilise des comparaisons de chaînes de caractères beaucoup plus longues qu'une recherche par indexe. Pour tester cette hypothèse, je crée une migration qui ajoute un indexe sur les colonnes `first_name` et `last_name`, et teste avant et après le passage de ma migration.

```
- Sans index:
  Practitioner Load (3.5ms)  SELECT  "practitioners".* FROM "practitioners" WHERE "practitioners"."first_name" = $1 AND "practitioners"."last_name" = $2 ORDER BY "practitioners"."id" ASC LIMIT $3  [["first_name", "Fritz"], ["last_name", "Kertzmann"], ["LIMIT", 1]]

- Avec index:
  Practitioner Load (0.4ms)  SELECT  "practitioners".* FROM "practitioners" WHERE "practitioners"."first_name" = $1 AND "practitioners"."last_name" = $2 ORDER BY "practitioners"."id" ASC LIMIT $3  [["first_name", "Fritz"], ["last_name", "Kertzmann"], ["LIMIT", 1]]
```

Gain sur la requête: 12ms => 10ms (moyenne)

Le gain n'est pas aussi important que pour `GET /` mais reste appréciable.
