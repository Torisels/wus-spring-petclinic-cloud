# WUS-LAB3
### Skład zespołu:

- Gustaw Daczkowski
- Hubert Decyusz
- Adam Lisichin
- Wojciech Nowicki

---
### Wymagania:
- lokalnie zainstalowany pakiet `gcloud` - [Instrukcja instalacji](https://cloud.google.com/sdk/docs/install). W przypadku Windowsa zalecane jest skorzystanie z WSL/WSL2
- zalogowanie do `gcloud` (instalator poprosi o to automatycznie) oraz wykonana wstępna konfiguracja za pomocą `gcloud init` (warto wybrać region: `europe-west4` oraz zone: `europe-west1-b`)
- lokalnie zainstalowany `kubectl` - [Instrukcja instalacji](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- lokalnie zainstalowany `helm` - [Instrukcja instalacji](https://helm.sh/docs/intro/install/)
---
### Konfiguracja gcloud
Należy wszystkim plikom `*.sh` dodać uprawnienia do wykonywania.

W pliku `setup.sh` należy ustawić wszystkie znajdujące się tam zmienne środowiskowe.

Przed uruchomieniem skryptu instalującego klaster należy uruchomić komendę 
`source setup.sh`, tak aby załadować konfigurację.


# Uruchomienie klastra
1. Uruchomić skrypt `scripts/create_cluster.sh` (tworzenie klastra trwa kilka minut)
2. Ustawić zmienną środowiskową `export REPOSITORY_PREFIX=<DOCKER_HUB_USERNAME>`
3. Przejść do katalogu `spring-petclinic-cloud`
4. Uruchomić `kubectl apply -f k8s/init-namespace`
5. Utworzyć sekret do Wavefront `kubectl create secret generic wavefront -n spring-petclinic --from-literal=wavefront-url=https://wavefront.surf --from-literal=wavefront-api-token=2e41f7cf-1111-2222-3333-7397a56113ca`
6. Zainicjalizować serwisy `kubectl apply -f k8s/init-services`
7. Zainstalować bazy danych z helm 
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --version 8.8.8 --set auth.database=service_instance_db
helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic  --version 8.8.8 --set auth.database=service_instance_db
helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic  --version 8.8.8 --set auth.database=service_instance_db
```

8. Wykonać deploy do k8s poprzez skrypt 
`./scripts/deployToKubernetes.sh`

9. Zamiast wykonywać deploy ze skryptu można to zrobić automatycznie poprzez pipeline wykonując commit z dowolną zmianą

10. Serwis będzie dostepny pod zewnetrznym IP (`EXTERNAL-IP`) api-gateway, które można uzyskać komendą:
`kubectl get svc -n spring-petclinic api-gateway`
## Konfiguracja pipeline do automatycznego deploy'u

Aby działał pipeline obecny w `.github/workflows` należy ustawić następujące secrety w repozytorium GitHub:

* `DOCKER_HUB_TOKEN` - haslo lub token do DockerHub
* `DOCKER_HUB_USER` - username do DockerHub
* `GKE_CLUSTER` - nazwa klastra GKE
* `GKE_REGION` - region, w którym znajduję się klaster
* `GKE_SA_KEY` - klucz serviceaccount, w formacie `.json`. Można go uzyskać wykonując skrypt `obtain_gh_credentials.sh` - wówczas zostanie utworzony plik `key.json`, który potem należy przekopiować do secretu.


## Logowanie do CloudLogging

Aby uruchomić logowanie aplikacji do usługi GCP cloud logging należy dodać odpowiednią zależność maven do pliku `pom.xml`

```xml
<dependency>
        <groupId>com.google.cloud</groupId>
        <artifactId>google-cloud-logging-logback</artifactId>
        <version>0.122.7-alpha</version>
</dependency>
```

Oraz odpowiedni log-appender w pliku `<app_name>/src/main/resources/logback-spring.xml`

```xml
  <appender name="CLOUD" class="com.google.cloud.logging.logback.LoggingAppender">
    <!-- Optional : filter logs at or above a level -->
    <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
      <level>INFO</level>
    </filter>
    <log>customers-service.log</log> <!-- Optional : default java.log -->
    <enhancer>com.example.logging.logback.enhancers.ExampleEnhancer</enhancer> <!-- Optional -->
    <flushLevel>WARN</flushLevel> <!-- Optional : default ERROR -->
  </appender>

  <root level="info">
    <appender-ref ref="CLOUD" />
  </root>
```

Aby testy działaly poprawnie należy wyłączyć logowanie w testach poprzez dodanie pliku
```xml
<?xml version="1.0" encoding="UTF-8"?>

<configuration />
```
W ścieżce: `<app_name>/src/test/resources/logback-test.xml`