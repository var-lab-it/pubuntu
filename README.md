# p(ipeline)Ubuntu PHP - for GitLab CI Pipelines

**pubuntu** is a lightweight Ubuntu-based Docker image designed for GitLab CI pipelines. It comes with pre-installed PHP 8 packages and essential development tools, making it easier and faster to run jobs such as unit tests and static code analysis.

The image also includes a **json-server** for API mocking, along with **Node.js** and **npm**.

## Pre-installed Tools and Packages

- Node.js + npm
- Git
- ACL (Access Control Lists)
- PHP 8.0, 8.1, 8.2, 8.3, 8.4
- MySQL Client

## How to use it

### Running static code analysis in the pipeline

The following examples shows how to use the image for a single pipeline job in the GitLab CI.

```
#.gitlab-ci.yml

variables:
  PHP_VERSION: 8.1 # also possible is 8.4, 8.3, 8.2, 8.1, 8.0
  JOB_IMAGE: git.var-lab.com:5050/dev-tools/glubuntu-php:latest-php-$PHP_VERSION

checks_backend:
  image:
    name: $JOB_IMAGE
  script:
    - composer install
    - composer normalize --dry-run
    - composer run ...
    - ...
```

### Running phpunit-tests in the pipeline

In the following example you can see how the image is used to run phpunit tests. In this case the application needs a connection to a MySQL database, so we added MySQL as a service.

```
#.gitlab-ci.yml

variables:
  PHP_VERSION: 8.1 # also possible is 8.4, 8.3, 8.2, 8.1, 8.0
  JOB_IMAGE: git.var-lab.com:5050/dev-tools/glubuntu-php:latest-php-$PHP_VERSION

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

Created by Anton Dachauer | [var-lab.com](https://var-lab.com)
