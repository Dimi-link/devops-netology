# Домашнее задание к занятию "2. Облачные провайдеры и синтаксис Terraform."

Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. 
Поэтому в рамках первого *необязательного* задания предлагается завести свою учетную запись в AWS (Amazon Web Services) или Yandex.Cloud.
Идеально будет познакомится с обоими облаками, потому что они отличаются. 

## Задача 1 (вариант с AWS). Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов. 

AWS предоставляет достаточно много бесплатных ресурсов в первый год после регистрации, подробно описано [здесь](https://aws.amazon.com/free/).
1. Создайте аккаут aws.
1. Установите c aws-cli https://aws.amazon.com/cli/.
1. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
1. Создайте IAM политику для терраформа c правами
    * AmazonEC2FullAccess
    * AmazonS3FullAccess
    * AmazonDynamoDBFullAccess
    * AmazonRDSFullAccess
    * CloudWatchFullAccess
    * IAMFullAccess
1. Добавьте переменные окружения 
    ```
    export AWS_ACCESS_KEY_ID=(your access key id)
    export AWS_SECRET_ACCESS_KEY=(your secret access key)
    ```
1. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс. 

В виде результата задания приложите вывод команды `aws configure list`.

## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта. 
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы 
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ. 

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер 
   1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
   блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион 
   внутри блока `provider`.
   2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти 
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения. 
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс 
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке 
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент: 
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент, 
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок. 


В качестве результата задания предоставьте:
1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
1. Ссылку на репозиторий с исходной конфигурацией терраформа.  

Конфиг Terraform \
[main.tf](../terraform/07-terraform-02-syntax/src/main.tf) \
[version.tf](../terraform/07-terraform-02-syntax/src/version.tf) \
[outputs.tf](../terraform/07-terraform-02-syntax/src/outputs.tf)

```bash
vagrant@docker:~/cloud-terraform$ yc iam service-account create --name terradimi
id: ajeb22eiuf8e0ugrulij
folder_id: b1gn6do9flnmpvijh6jq
created_at: "2023-02-20T19:21:03.543933190Z"
name: terradimi

vagrant@docker:~/cloud-terraform$ yc iam service-account --folder-id b1gn6do9flnmpvijh6jq list
+----------------------+-----------+
|          ID          |   NAME    |
+----------------------+-----------+
| ajeb22eiuf8e0ugrulij | terradimi |
+----------------------+-----------+
```
```bash
root@docker:/home/vagrant/cloud-terraform# export YC_TOKEN=`yc iam create-token`
root@docker:/home/vagrant/cloud-terraform# terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Using previously-installed yandex-cloud/yandex v0.85.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
root@docker:/home/vagrant/cloud-terraform# terraform apply -auto-approve


Plan: 3 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + private_ip_address_terra-node = (known after apply)
  + subnet_ip_address_terra-node  = (known after apply)
yandex_vpc_network.terranet: Creating...
yandex_vpc_network.terranet: Creation complete after 2s [id=enpqe0gd6ntsfffpoo91]
yandex_vpc_subnet.terrasubnet: Creating...
yandex_vpc_subnet.terrasubnet: Creation complete after 1s [id=e9bc5i7eb6j6jacmnqio]
yandex_compute_instance.terra-node: Creating...
yandex_compute_instance.terra-node: Still creating... [10s elapsed]
yandex_compute_instance.terra-node: Still creating... [20s elapsed]
yandex_compute_instance.terra-node: Still creating... [30s elapsed]
yandex_compute_instance.terra-node: Still creating... [40s elapsed]
yandex_compute_instance.terra-node: Still creating... [50s elapsed]
yandex_compute_instance.terra-node: Creation complete after 59s [id=fhm57tn3g67iksjt5djj]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

private_ip_address_terra-node = "51.250.94.127"
subnet_ip_address_terra-node = "192.168.56.24"
```
```bash
root@docker:/home/vagrant/cloud-terraform# terraform destroy -auto-approve
Plan: 0 to add, 0 to change, 3 to destroy.

Changes to Outputs:
  - private_ip_address_terra-node = "51.250.94.127" -> null
  - subnet_ip_address_terra-node  = "192.168.56.24" -> null
yandex_compute_instance.terra-node: Destroying... [id=fhm57tn3g67iksjt5djj]
yandex_compute_instance.terra-node: Still destroying... [id=fhm57tn3g67iksjt5djj, 10s elapsed]
yandex_compute_instance.terra-node: Still destroying... [id=fhm57tn3g67iksjt5djj, 20s elapsed]
yandex_compute_instance.terra-node: Destruction complete after 21s
yandex_vpc_subnet.terrasubnet: Destroying... [id=e9bc5i7eb6j6jacmnqio]
yandex_vpc_subnet.terrasubnet: Destruction complete after 3s
yandex_vpc_network.terranet: Destroying... [id=enpqe0gd6ntsfffpoo91]
yandex_vpc_network.terranet: Destruction complete after 0s

Destroy complete! Resources: 3 destroyed.
```