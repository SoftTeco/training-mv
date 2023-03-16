# WP-DB-JS
<p>Инфраструктура с манифест файлами для Deployment и Service: wordpress, js-app, mysql.</p>
<p>Сделаны 2 namespace: terraform-k8s-dev-test, terraform-k8s-prod-test.</p>
<p>Сделаны по 2 реплики на каждый сервис.</p>
<p>Service типа NodePort.</p>
<p>Кластер "new": root@192.168.58.2 , port: 8443</p>

<p>To create Containerized runner, use:</p>
<p>docker build --build-arg RUNNER_VERSION=<version_number> --tag docker-github-runner-lin .</p>
<p>docker run -e GH_TOKEN='myPatToken' -e GH_OWNER='orgName' -e GH_REPOSITORY='repoName' -d image-name</p>

