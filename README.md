# G(ipeline)Ubuntu PHP - for GitLab CI Pipelines

In some cases it is a good idea to run some CI jobs in an Ubuntu Docker image. **glubuntu-php** is such an image, with PHP-8 packages pre-installed. It makes it easier (and faster) to run e.g. unit tests faster in the CI pipeline.

It also includes a json-server to mock APIs, also NodeJS and NPM are installed.

Pre-installed tools / packages / software:
- json-server
- nodejs 17 + npm
- git
- acl
- PHP 8.1/8.0/7.4
- mysql-client

## How to use it

### Running static code analysis in the pipeline

The following examples shows how to use the image for a single pipeline job in the GitLab CI.

```
#.gitlab-ci.yml

variables:
  PHP_VERSION: 8.1 # also possible is 8.0 or 7.4
  JOB_IMAGE: git.var-lab.com:5050/dev-tools/glubuntu-php:latest-php-8.1

checks_backend:
  image:
    name: $JOB_IMAGE
  script:
    - composer install
    - composer normalize --dry-run
    - composer run yaml-lint
    - composer run check-style
    - composer run phpstan
    - composer run psalm
```

### Running phpunit-tests in the pipeline

In the following example you can see how the image is used to run phpunit tests. In this case the application needs a connection to a MySQL database, so we added MySQL as a service.

```
#.gitlab-ci.yml

variables:
  PHP_VERSION: 8.1 # also possible is 8.0 or 7.4
  JOB_IMAGE: git.var-lab.com:5050/dev-tools/glubuntu-php:latest-php-8.1

tests_backend:
  services:
    - name: mysql:8.0.28
      alias: database
  variables:
    MYSQL_DATABASE_NAME: symfony
    MYSQL_ROOT_PASSWORD: root
    MYSQL_USER: symfony
    MYSQL_PASSWORD: symfony
    MYSQL_DATABASE: symfony
  image:
    name: $JOB_IMAGE
  script:
    - mysql -h database -u symfony -psymfony <<< "SET GLOBAL sql_mode = '';"
    - cd backend
    - composer install
    - php bin/console lexik:jwt:generate-keypair --skip-if-exists
    - setfacl -R -m u:www-data:rX -m u:"$(whoami)":rwX config/jwt
    - setfacl -dR -m u:www-data:rX -m u:"$(whoami)":rwX config/jwt
    - bin/console doctrine:migrations:migrate -n --env=test
    - bin/console doctrine:fixtures:load -n --env=test
    - composer run phpunit
  artifacts:
    when: always
    reports:
      junit: backend/report.xml
      cobertura: backend/coverage.cobertura.xml
```
