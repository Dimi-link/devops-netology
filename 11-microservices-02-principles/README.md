
# Домашнее задание к занятию «Микросервисы: принципы»

Вы работаете в крупной компании, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps-специалисту необходимо выдвинуть предложение по организации инфраструктуры для разработки и эксплуатации.

## Задача 1: API Gateway 

Предложите решение для обеспечения реализации API Gateway. Составьте сравнительную таблицу возможностей различных программных решений. На основе таблицы сделайте выбор решения.

Решение должно соответствовать следующим требованиям:
- маршрутизация запросов к нужному сервису на основе конфигурации,
- возможность проверки аутентификационной информации в запросах,
- обеспечение терминации HTTPS.

Обоснуйте свой выбор.

Основываясь на найденной информации в таких источниках [Cloud Native Interactive Landscape](https://landscape.cncf.io/guide#orchestration-management--api-gateway), [TecMint](https://www.tecmint.com/open-source-api-gateways-and-management-tools/), [Habr](https://habr.com/ru/articles/665558/), была составлена 
следующая таблица:

|                            Наименование                            | Маршрутизация<br/>запросов | Проверка аутентификации<br/>в запросах | HTTPS-терминация |
|:------------------------------------------------------------------:|:--------------------------:|:--------------------------------------:|:----------------:|
| [gravitee](https://github.com/gravitee-io/gravitee-api-management) |             да             |                   да                   |        да        |
|         [apache apisix](https://github.com/apache/apisix)          |             да             |                   да                   |        да        |
|           [krakend](https://github.com/luraproject/lura)           |             да             |                   да                   |        да        |
|        [wso2](https://github.com/wso2/product-microgateway)        |             да             |                   да                   |        да        |
|                [kong](https://github.com/Kong/kong)                |             да             |                   да                   |        да        |
|           [tyk](https://github.com/TykTechnologies/tyk)            |             да             |                   да                   |        да        |

Из таблицы видно, что все представленные варианты соответствуют предъявляемым требованиям к решению для обеспечения 
реализации API Gateway. Из представленных standalone решений можно выбрать gravitee (имеющий наивысшую итоговую 
оценку по различным критериям) или apache apisix (известная организация-фонд с множеством активных проектов и большим 
комьюнити)...в зависимости от разрабатываемых командой микросервисов возможно использование и других решений. Также 
в случае развертывания микросервисной архитектуры в облаке скорее всего предпочтительнее использовать API Gateway 
облачных провайдеров. Все популярные провайдеры имеют решения, соответствующие предъявляемым требованиям: Amazon API 
Gateway, Azure API Management,Yandex API Gateway, Google Apigee API Management и др.
## Задача 2: Брокер сообщений

Составьте таблицу возможностей различных брокеров сообщений. На основе таблицы сделайте обоснованный выбор решения.

Решение должно соответствовать следующим требованиям:
- поддержка кластеризации для обеспечения надёжности,
- хранение сообщений на диске в процессе доставки,
- высокая скорость работы,
- поддержка различных форматов сообщений,
- разделение прав доступа к различным потокам сообщений,
- простота эксплуатации.

Обоснуйте свой выбор.

Исходя из сведений, полученных из следующих источников [Cloud Native Interactive Landscape](https://landscape.cncf.io/guide#app-definition-and-development--streaming-messaging), [Ultimate Message Broker Comparison](https://ultimate-comparisons.github.io/ultimate-message-broker-comparison/), [Habr](https://habr.com/ru/companies/innotech/articles/698838/), [еще Habr](https://habr.com/ru/companies/yandex_praktikum/articles/700608/), [Mediasoft](https://academy.mediasoft.team/article/brokery-soobshenii-chto-eto-iz-chego-sostoyat-plyusy-i-minusy-sravnivaem-apache-kafka-redis-i-rabbitmq/) 

|                      Наименование                       | Кластеризация | Хранение сообщений<br/>на диске | Высокая скорость<br/>работы | Поддержка различных<br/>форматов сообщений | Разделение прав<br/>доступа | Простота<br/>эксплуатации |
|:-------------------------------------------------------:|:-------------:|:-------------------------------:|:---------------------------:|:------------------------------------------:|:---------------------------:|:-------------------------:|
|     [Apache Kafka](https://github.com/apache/kafka)     |      да       |               да                |             да              |                    нет                     |             да              |            нет            |
|  [Apache ActiveMQ](https://github.com/apache/activemq)  |      да       |               да                |      да<sup>[*]</sup>       |                     да                     |             да              |            да             |
|  [Apache RocketMQ](https://github.com/apache/rocketmq)  |      да       |               да                |      да<sup>[*]</sup>       |                     да                     |             да              |            да             |
|     [NATS](https://github.com/nats-io/nats-server)      |      да       |               да                |             да              |                    нет                     |             да              |            да             |
| [RabbitMQ](https://github.com/rabbitmq/rabbitmq-server) |      да       |               да                |      да<sup>[*]</sup>       |                     да                     |             да              |            да             |
|         [Redis](https://github.com/redis/redis)         |      да       |               да                |      да<sup>[*]</sup>       |                    нет                     |             да              |            да             |

<sup>[*]</sup>  при некоторых ограничениях на количество/объем/задержки сообщений или (возможно) не в 
высоконагруженных системах

можно сделать вывод, что среди представленных брокеров, наиболее подходящими будут Apache ActiveMQ, Apache RocketMQ, 
RabbitMQ. Если неизвестны иные требования к брокеру сообщений или не формализована архитектура система, то наилучшим 
выбором будет брокер RabbitMQ, т.к. имеет низкий порог вхождения в интеграцию и не слишком требователен к ресурсам 
аппаратной части системы.  
## Задача 3: API Gateway * (необязательная)

### Есть три сервиса:

**minio**
- хранит загруженные файлы в бакете images,
- S3 протокол,

**uploader**
- принимает файл, если картинка сжимает и загружает его в minio,
- POST /v1/upload,

**security**
- регистрация пользователя POST /v1/user,
- получение информации о пользователе GET /v1/user,
- логин пользователя POST /v1/token,
- проверка токена GET /v1/token/validation.

### Необходимо воспользоваться любым балансировщиком и сделать API Gateway:

**POST /v1/register**
1. Анонимный доступ.
2. Запрос направляется в сервис security POST /v1/user.

**POST /v1/token**
1. Анонимный доступ.
2. Запрос направляется в сервис security POST /v1/token.

**GET /v1/user**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис security GET /v1/user.

**POST /v1/upload**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис uploader POST /v1/upload.

**GET /v1/user/{image}**
1. Проверка токена. Токен ожидается в заголовке Authorization. Токен проверяется через вызов сервиса security GET /v1/token/validation/.
2. Запрос направляется в сервис minio GET /images/{image}.

### Ожидаемый результат

Результатом выполнения задачи должен быть docker compose файл, запустив который можно локально выполнить следующие команды с успешным результатом.
Предполагается, что для реализации API Gateway будет написан конфиг для NGinx или другого балансировщика нагрузки, который будет запущен как сервис через docker-compose и будет обеспечивать балансировку и проверку аутентификации входящих запросов.
Авторизация
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/token

**Загрузка файла**

curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @yourfilename.jpg http://localhost/upload

**Получение файла**
curl -X GET http://localhost/images/4e6df220-295e-4231-82bc-45e4b1484430.jpg

---

#### [Дополнительные материалы: как запускать, как тестировать, как проверить](https://github.com/netology-code/devkub-homeworks/tree/main/11-microservices-02-principles)


