# Домашнее задание к занятию "5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

Dockerfile

```
FROM centos:7
RUN cd /opt && \
    groupadd elasticsearch && \
    useradd -c "elasticsearch" -g elasticsearch elasticsearch &&\
    yum update -y && yum -y install wget perl-Digest-SHA && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512 && \
    shasum -a 512 -c elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.2.0-linux-x86_64.tar.gz && \
	rm elasticsearch-8.2.0-linux-x86_64.tar.gz elasticsearch-8.2.0-linux-x86_64.tar.gz.sha512 && \ 
	mkdir /var/lib/data && chmod -R 777 /var/lib/data && \
	chown -R elasticsearch:elasticsearch /opt/elasticsearch-8.2.0 && \
	yum -y remove wget perl-Digest-SHA && \
	yum clean all
USER elasticsearch
WORKDIR /opt/elasticsearch-8.2.0/
COPY elasticsearch.yml  config/
EXPOSE 9200 9300
ENTRYPOINT ["bin/elasticsearch"]
```
elasticsearch.yml
```
node:
  name: netology_test
path:
  data: /var/lib/data
xpack.ml.enabled: false
```
https://hub.docker.com/r/dimitsuri/elasticsearch

```
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl --insecure -u elastic https://localhost:9200
Enter host password for user 'elastic':
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "0eB3V70XS6uvJTS4Zwky7g",
  "version" : {
    "number" : "8.2.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "b174af62e8dd9f4ac4d25875e9381ffe2b9282c5",
    "build_date" : "2022-04-20T10:35:10.180408517Z",
    "build_snapshot" : false,
    "lucene_version" : "9.1.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

```
curl -X PUT --insecure -u elastic "https://localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0 
    }
  }
}
'

curl -X PUT --insecure -u elastic "https://localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 2,  
      "number_of_replicas": 1 
    }
  }
}
'

curl -X PUT --insecure -u elastic "https://localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 4,  
      "number_of_replicas": 2 
    }
  }
}
'
```

```
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X GET --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localh
ost:9200/_cat/indices?v=true"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 m1kwFJKQS5W_FIbDW53Vaw   1   0          0            0       225b           225b
yellow open   ind-2 TJ1uv5trR4ug06u4hjrsPg   2   1          0            0       450b           450b
yellow open   ind-3 xFHap-E7R_W3nudoNan-OQ   4   2          0            0       900b           900b
```

```
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X GET --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localh
ost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 9,
  "active_shards" : 9,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 47.368421052631575
```
Кластер в состоянии yellow скорее всего из-за того, что при создании индексов реплики указали, но так как нода одна, то реплицировать их некуда.

```
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X DELETE --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://loc
alhost:9200/ind-1?pretty"
{
  "acknowledged" : true
}
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X DELETE --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://loc
alhost:9200/ind-2?pretty"
{
  "acknowledged" : true
}
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X DELETE --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://loc
alhost:9200/ind-3?pretty"
{
  "acknowledged" : true
}
```
## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

```
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X PUT --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
> {
>   "type": "fs",
>   "settings": {
>     "location": "/opt/elasticsearch-8.2.0/snapshots"
>   }
> }
> '
{
  "acknowledged" : true
}
```

```
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X GET --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localh
ost:9200/_cat/indices?v=true"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  BzP4C-5SRau8h3lRXunNFA   1   0          0            0       225b           225b
```

```
[elasticsearch@fa5150aee30c elasticsearch-8.2.0]$ curl -X PUT --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localh
ost:9200/_snapshot/netology_backup/my_snapshot?pretty"
{
  "accepted" : true
}
```

```
[elasticsearch@fa5150aee30c snapshots]$ ll
total 36
-rw-r--r-- 1 elasticsearch elasticsearch  1096 Feb 16 20:55 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Feb 16 20:55 index.latest
drwxr-xr-x 5 elasticsearch elasticsearch  4096 Feb 16 20:55 indices
-rw-r--r-- 1 elasticsearch elasticsearch 16539 Feb 16 20:55 meta-1Z94gWP5SH659ZRtw7PF7w.dat
-rw-r--r-- 1 elasticsearch elasticsearch   387 Feb 16 20:55 snap-1Z94gWP5SH659ZRtw7PF7w.dat
```

```
[elasticsearch@fa5150aee30c snapshots]$ curl -X GET --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localhost:9200/_
cat/indices?v=true"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 q6N_xf6sRNOeD_h6248nTQ   1   0          0            0       225b           225b
```

```
[elasticsearch@fa5150aee30c snapshots]$ curl -X GET --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localhost:9200/_
snapshot/netology_backup/*?verbose=false&pretty"
{
  "snapshots" : [
    {
      "snapshot" : "my_snapshot",
      "uuid" : "1Z94gWP5SH659ZRtw7PF7w",
      "repository" : "netology_backup",
      "indices" : [
        ".geoip_databases",
        ".security-7",
        "test"
      ],
      "data_streams" : [ ],
      "state" : "SUCCESS"
    }
  ],
  "total" : 1,
  "remaining" : 0
}
```

```
[elasticsearch@fa5150aee30c snapshots]$ curl -X POST --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localhost:9200/
_snapshot/netology_backup/my_snapshot/_restore?pretty" -H 'Content-Type: application/json' -d'
> {
>   "indices": "*",
>   "include_global_state": true
> }
> '
{
  "accepted" : true
}
```

```
[elasticsearch@fa5150aee30c snapshots]$ curl -X GET --insecure -u elastic:sZ*p4*KwHcVuSfqy0AG5 "https://localhost:9200/_
cat/indices?v=true"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 q6N_xf6sRNOeD_h6248nTQ   1   0          0            0       225b           225b
green  open   test   DKCZoWyfTH2jv3oQimis1Q   1   0          0            0       225b           225b
```
