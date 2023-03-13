# Домашнее задание к занятию 2 «Работа с Playbook»

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

Так как про Docker в этот раз ничего не написано, развернул хосты на Vagrant:
```bash
$clickhouse_host = "clickhouse"
$clickhouse_ip = "192.168.2.100"
$vector_host = "vector"
$vector_ip = "192.168.2.101"
$box = "bento/centos-7"
$ssh_public_key_path = "~/.ssh/id_rsa.pub"

Vagrant.configure("2") do |config|
  config.vm.define $clickhouse_host do |config|
    config.vm.provider "virtualbox" do |vb|
      vb.cpus = "2"
      vb.memory = "4096"
    end
    config.vm.box = $box
    config.vm.hostname = $clickhouse_host
    config.vm.network "public_network", ip: $clickhouse_ip
	config.vm.synced_folder "../Temp", "/home/vagrant"
	config.vm.provision 'file', 
        source: $ssh_public_key_path, 
        destination: '~/.ssh/authorized_keys'
  end
end

Vagrant.configure("2") do |config|
    config.vm.define $vector_host do |config|
      config.vm.provider "virtualbox" do |vb|
        vb.cpus = "2"
        vb.memory = "4096"
      end
	config.vm.box = $box
    config.vm.hostname = $vector_host
    config.vm.network "public_network", ip: $vector_ip
	config.vm.synced_folder "../Temp", "/home/vagrant"
	config.vm.provision 'file', 
        source: $ssh_public_key_path, 
        destination: '~/.ssh/authorized_keys'

    end
end
```
## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev).
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

_В playbook добавил таску в play clickhouse для включения удаленных соединений к серверу и изменил таску по добавлению 
БД, добавляется через переменную в group_vars._
```bash
vagrant@vagrant:~/playbook$ ansible-lint site.yml
[201] Trailing whitespace
site.yml:44
          - -q

[206] Variables should have spaces before and after: {{ var_name }}
site.yml:66
        line: "{{ hostvars[item].ansible_host }} {{item}}"
```
Исправил найденные проблемы с пробелами...

```bash
vagrant@vagrant:~/playbook$ ansible-playbook site.yml --check
[WARNING]: Could not match supplied host pattern, ignoring: clickhouse

PLAY [Install Clickhouse] **********************************************************************************************
skipping: no hosts matched
[WARNING]: Could not match supplied host pattern, ignoring: vector

PLAY [Install Vector] **************************************************************************************************
skipping: no hosts matched

PLAY RECAP ************************************************************************************************************
```
...странно, что хосты не нашлись, возможно из-за моей неоригинальности в выборе имени хостов:

```bash
vagrant@vagrant:~/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml --diff 

[WARNING]: Found both group and host with same name: clickhouse
[WARNING]: Found both group and host with same name: vector

PLAY [Install Clickhouse] *******************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse]

TASK [Get clickhouse distrib] ***************************************************************************************************************
ok: [clickhouse] => (item=clickhouse-client)
ok: [clickhouse] => (item=clickhouse-server)
failed: [clickhouse] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_tmp_t:s0", "size": 124946236, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-21.1.9.41-2.noarch.rpm"}

TASK [Get clickhouse distrib] ***************************************************************************************************************
ok: [clickhouse]

TASK [Install clickhouse packages] **********************************************************************************************************
ok: [clickhouse]

TASK [Enable remote connections to clickhouse server] ***************************************************************************************
ok: [clickhouse]

TASK [Flush handlers] ***********************************************************************************************************************

TASK [Create database] **********************************************************************************************************************
ok: [clickhouse]

TASK [Create log table] *********************************************************************************************************************
ok: [clickhouse]

PLAY [Install Vector] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [vector]

TASK [Add clickhouse addresses to /etc/hosts] ***********************************************************************************************
ok: [vector] => (item=clickhouse)

TASK [Get vector distrib] *******************************************************************************************************************
changed: [vector]

TASK [Install vector package] ***************************************************************************************************************
changed: [vector]

TASK [Redefine vector config name] **********************************************************************************************************
--- before: /etc/default/vector (content)
+++ after: /etc/default/vector (content)
@@ -2,3 +2,4 @@
 # This file can theoretically contain a bunch of environment variables
 # for Vector.  See https://vector.dev/docs/setup/configuration/#environment-variables
 # for details.
+VECTOR_CONFIG=/etc/vector/config.yaml

changed: [vector]

TASK [Create vector config] *****************************************************************************************************************
--- before
+++ after: /root/.ansible/tmp/ansible-local-2744yr4f4uue/tmpe_fz3ohl
@@ -0,0 +1,27 @@
+api:
+  address: 0.0.0.0:8686
+  enabled: true
+sinks:
+  to_clickhouse:
+    compression: gzip
+    database: logtest
+    endpoint: http://clickhouse:8123
+    inputs:
+    - parse_logs
+    table: mylogs
+    type: clickhouse
+sources:
+  dummy_logs:
+    format: syslog
+    interval: 1
+    type: demo_logs
+transforms:
+  parse_logs:
+    inputs:
+    - dummy_logs
+    source: '. = parse_syslog!(string!(.message))
+
+      .timestamp = to_string(.timestamp)
+
+      .timestamp = slice!(.timestamp, start:0, end: -1)'
+    type: remap

changed: [vector]

RUNNING HANDLER [Start Vector service] ******************************************************************************************************
changed: [vector]

PLAY RECAP **********************************************************************************************************************************
clickhouse                 : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
vector                     : ok=7    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
...пакета clickhouse-common-static.noarch.rpm нет никакой версии, без него вроде заработало...

```bash
vagrant@vagrant:~/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml 

[WARNING]: Found both group and host with same name: vector
[WARNING]: Found both group and host with same name: clickhouse

PLAY [Install Clickhouse] *******************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [clickhouse]

TASK [Get clickhouse distrib] ***************************************************************************************************************
ok: [clickhouse] => (item=clickhouse-client)
ok: [clickhouse] => (item=clickhouse-server)
failed: [clickhouse] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_tmp_t:s0", "size": 124946236, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-21.1.9.41-2.noarch.rpm"}

TASK [Get clickhouse distrib] ***************************************************************************************************************
ok: [clickhouse]

TASK [Install clickhouse packages] **********************************************************************************************************
ok: [clickhouse]

TASK [Enable remote connections to clickhouse server] ***************************************************************************************
ok: [clickhouse]

TASK [Flush handlers] ***********************************************************************************************************************

TASK [Create database] **********************************************************************************************************************
ok: [clickhouse]

TASK [Create log table] *********************************************************************************************************************
ok: [clickhouse]

PLAY [Install Vector] ***********************************************************************************************************************

TASK [Gathering Facts] **********************************************************************************************************************
ok: [vector]

TASK [Add clickhouse addresses to /etc/hosts] ***********************************************************************************************
ok: [vector] => (item=clickhouse)

TASK [Get vector distrib] *******************************************************************************************************************
ok: [vector]

TASK [Install vector package] ***************************************************************************************************************
ok: [vector]

TASK [Redefine vector config name] **********************************************************************************************************
ok: [vector]

TASK [Create vector config] *****************************************************************************************************************
ok: [vector]

PLAY RECAP **********************************************************************************************************************************
clickhouse                 : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
vector                     : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
```bash
vagrant@vagrant:~/playbook$ sudo ansible-playbook -i inventory/prod.yml site.yml --ask-pass --diff
SSH password:
[WARNING]: Found both group and host with same name: clickhouse
[WARNING]: Found both group and host with same name: vector

PLAY [Install Clickhouse] **********************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [clickhouse]

TASK [Get clickhouse distrib] ******************************************************************************************
ok: [clickhouse] => (item=clickhouse-client)
ok: [clickhouse] => (item=clickhouse-server)
failed: [clickhouse] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "gid": 0, "group": "root", "item": "clickhouse-common-static", "mode": "0644", "msg": "Request failed", "owner": "root", "response": "HTTP Error 404: Not Found", "secontext": "unconfined_u:object_r:user_tmp_t:s0", "size": 246310036, "state": "file", "status_code": 404, "uid": 0, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ******************************************************************************************
ok: [clickhouse]

TASK [Install clickhouse packages] *************************************************************************************
ok: [clickhouse]

TASK [Enable remote connections to clickhouse server] ******************************************************************
ok: [clickhouse]

TASK [Flush handlers] **************************************************************************************************

TASK [Create database] *************************************************************************************************
ok: [clickhouse]

TASK [Create log table] ************************************************************************************************
ok: [clickhouse]


TASK [Gathering Facts] *************************************************************************************************
ok: [vector]

TASK [Add clickhouse addresses to /etc/hosts] **************************************************************************
ok: [vector] => (item=clickhouse)

TASK [Get vector distrib] **********************************************************************************************
ok: [vector]

TASK [Install vector package] ******************************************************************************************
ok: [vector]

TASK [Redefine vector config name] *************************************************************************************
ok: [vector]

TASK [Create vector config] ********************************************************************************************
ok: [vector]

PLAY RECAP *************************************************************************************************************
clickhouse                 : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
vector                     : ok=6    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
Проверим наличие нашей БД

```bash
-bash-4.2$ systemctl status clickhouse-server.service
● clickhouse-server.service - ClickHouse Server (analytic DBMS for big data)
   Loaded: loaded (/usr/lib/systemd/system/clickhouse-server.service; disabled; vendor preset: disabled)
   Active: active (running) since Sun 2023-03-12 18:42:15 UTC; 7min ago
 Main PID: 10090 (clckhouse-watch)
   CGroup: /system.slice/clickhouse-server.service
           ├─10090 clickhouse-watchdog --config=/etc/clickhouse-server/config.xml --pid-file=/run/clickhouse-server/c...
           └─10091 /usr/bin/clickhouse-server --config=/etc/clickhouse-server/config.xml --pid-file=/run/clickhouse-s...
-bash-4.2$ clickhouse-client
ClickHouse client version 22.3.3.44 (official build).
Connecting to localhost:9000 as user default.
Connected to ClickHouse server version 22.3.3 revision 54455.

clickhouse :) SHOW DATABASES

SHOW DATABASES

Query id: 17437314-0da5-451e-af93-87d61e9eda2b

┌─name───────────────┐
│ INFORMATION_SCHEMA │
│ default            │
│ information_schema │
│ logtest            │
│ system             │
└────────────────────┘

5 rows in set. Elapsed: 0.001 sec.
```
[Лог проверки работы Vector](./mylogs.log)

[README.md](https://github.com/Dimi-link/playbook/blob/main/08-ansible-02-playbook/README.md)

[tag 08-ansible-02-playbook](https://github.com/Dimi-link/playbook/releases/tag/08-ansible-02-playbook)
