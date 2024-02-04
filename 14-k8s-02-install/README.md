# Домашнее задание к занятию «Установка Kubernetes»

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
2. [Документация kubespray](https://kubespray.io/).

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

```bash
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.
dimi@DESKTOP-K8RTBSS:~/terraform$ yc compute instance list
+----------------------+--------------+---------------+---------+-----------------+---------------+
|          ID          |     NAME     |    ZONE ID    | STATUS  |   EXTERNAL IP   |  INTERNAL IP  |
+----------------------+--------------+---------------+---------+-----------------+---------------+
| fhm36u4gpc5h4f2l2a7d | k8s-worker-1 | ru-central1-a | RUNNING | 158.160.48.225  | 192.168.56.14 |
| fhm8pnk7gqq8ttt325vv | k8s-worker-0 | ru-central1-a | RUNNING | 158.160.114.122 | 192.168.56.7  |
| fhmcfm6b3g8cb1h4op3h | k8s-worker-2 | ru-central1-a | RUNNING | 158.160.98.62   | 192.168.56.3  |
| fhmdlgjmf5l60ohiqjdc | k8s-master   | ru-central1-a | RUNNING | 158.160.116.26  | 192.168.56.36 |
| fhmi7ok3561bo879ap7l | k8s-worker-3 | ru-central1-a | RUNNING | 130.193.48.69   | 192.168.56.20 |
+----------------------+--------------+---------------+---------+-----------------+---------------+

dimi@DESKTOP-K8RTBSS:~/terraform$
```
```bash
dimi@DESKTOP-K8RTBSS:~$ git clone https://github.com/kubernetes-sigs/kubespray
Cloning into 'kubespray'...
remote: Enumerating objects: 72939, done.
remote: Counting objects: 100% (441/441), done.
remote: Compressing objects: 100% (309/309), done.
remote: Total 72939 (delta 191), reused 313 (delta 104), pack-reused 72498
Receiving objects: 100% (72939/72939), 23.04 MiB | 23.22 MiB/s, done.
Resolving deltas: 100% (41014/41014), done.
dimi@DESKTOP-K8RTBSS:~$ cd kubespray
dimi@DESKTOP-K8RTBSS:~/kubespray$ sudo pip3 install -r requirements.txt

Successfully installed MarkupSafe-2.1.3 ansible-8.5.0 ansible-core-2.15.9 cffi-1.16.0 cryptography-41.0.4 jinja2-3.1.2 jmespath-1.0.1 netaddr-0.9.0 packaging-23.2 pbr-5.11.1 pycparser-2.21 resolvelib-1.0.1 ruamel.yaml-0.17.35 ruamel.yaml.clib-0.2.8
WARNING: Running pip as the 'root' user can result in broken permissions and conflicting behaviour with the system package manager. It is recommended to use a virtual environment instead: https://pip.pypa.io/warnings/venv
dimi@DESKTOP-K8RTBSS:~/kubespray$ cp -rfp inventory/sample inventory/mycluster
dimi@DESKTOP-K8RTBSS:~/kubespray$ declare -a IPS=(158.160.116.26 158.160.114.122 158.160.48.225 158.160.98.62 130.193.48.69)
dimi@DESKTOP-K8RTBSS:~/kubespray$ CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
DEBUG: Adding group all
DEBUG: Adding group kube_control_plane
DEBUG: Adding group kube_node
DEBUG: Adding group etcd
DEBUG: Adding group k8s_cluster
DEBUG: Adding group calico_rr
DEBUG: adding host node1 to group all
DEBUG: adding host node2 to group all
DEBUG: adding host node3 to group all
DEBUG: adding host node4 to group all
DEBUG: adding host node5 to group all
DEBUG: adding host node1 to group etcd
DEBUG: adding host node2 to group etcd
DEBUG: adding host node3 to group etcd
DEBUG: adding host node1 to group kube_control_plane
DEBUG: adding host node2 to group kube_control_plane
DEBUG: adding host node1 to group kube_node
DEBUG: adding host node2 to group kube_node
DEBUG: adding host node3 to group kube_node
DEBUG: adding host node4 to group kube_node
DEBUG: adding host node5 to group kube_node
dimi@DESKTOP-K8RTBSS:~/kubespray$ sudo nano  ./inventory/mycluster/hosts.yaml
```
```yaml
all:
  hosts:
    k8s-master:
      ansible_host: 158.160.116.26
      ip: 192.168.56.36
      access_ip: 192.168.56.36
      ansible_user: ubuntu
    k8s-worker-0:
      ansible_host: 158.160.114.122
      ip: 192.168.56.7
      access_ip: 158.160.114.122
      ansible_user: ubuntu
    k8s-worker-1:
      ansible_host: 158.160.48.225
      ip: 192.168.56.14
      access_ip: 158.160.48.225
      ansible_user: ubuntu
    k8s-worker-2:
      ansible_host: 158.160.98.62
      ip: 192.168.56.3
      access_ip: 158.160.98.62
      ansible_user: ubuntu
    k8s-worker-3:
      ansible_host: 130.193.48.69
      ip: 192.168.56.20
      access_ip: 130.193.48.69
      ansible_user: ubuntu
  children:
    kube_control_plane:
      hosts:
        k8s-master:
    kube_node:
      hosts:
        k8s-master:
        k8s-worker-0:
        k8s-worker-1:
        k8s-worker-2:
        k8s-worker-3:
    etcd:
      hosts:
        k8s-master:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```
```bash
dimi@DESKTOP-K8RTBSS:~$ ansible-playbook -u ubuntu -i inventory/mycluster/hosts.yaml cluster.yml -b -v --private-key=~/.ssh/id_rsa
```
```bash
PLAY RECAP *************************************************************************************************************
k8s-master                 : ok=682  changed=68   unreachable=0    failed=0    skipped=1134 rescued=0    ignored=5
k8s-worker-0               : ok=443  changed=33   unreachable=0    failed=0    skipped=676  rescued=0    ignored=1
k8s-worker-1               : ok=443  changed=33   unreachable=0    failed=0    skipped=676  rescued=0    ignored=1
k8s-worker-2               : ok=443  changed=33   unreachable=0    failed=0    skipped=676  rescued=0    ignored=1
k8s-worker-3               : ok=443  changed=33   unreachable=0    failed=0    skipped=676  rescued=0    ignored=1
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Sunday 04 February 2024  19:49:17 +0300 (0:00:00.129)       0:09:22.583 *******
===============================================================================
kubernetes/control-plane : Kubeadm | Initialize first master --------------------------------------------------- 80.29s
network_plugin/calico : Wait for calico kubeconfig to be created ----------------------------------------------- 44.42s
kubernetes/kubeadm : Join to cluster --------------------------------------------------------------------------- 21.90s
network_plugin/cni : CNI | Copy cni plugins -------------------------------------------------------------------- 10.69s
kubernetes/node : Install | Copy kubelet binary from download dir ----------------------------------------------- 8.60s
etcd : Configure | Wait for etcd cluster to be healthy ---------------------------------------------------------- 8.52s
kubernetes-apps/ansible : Kubernetes Apps | Lay Down CoreDNS templates ------------------------------------------ 7.73s
network_plugin/calico : Start Calico resources ------------------------------------------------------------------ 5.98s
etcd : Reload etcd ---------------------------------------------------------------------------------------------- 5.66s
kubernetes/preinstall : Preinstall | wait for the apiserver to be running --------------------------------------- 5.55s
etcd : Configure | Check if etcd cluster is healthy ------------------------------------------------------------- 5.24s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ----------------------------------------------------- 5.19s
container-engine/containerd : Containerd | Unpack containerd archive -------------------------------------------- 4.91s
network_plugin/calico : Calico | Copy calicoctl binary from download dir ---------------------------------------- 4.53s
network_plugin/calico : Calico | Create calico manifests -------------------------------------------------------- 4.14s
container-engine/crictl : Extract_file | Unpacking archive ------------------------------------------------------ 3.80s
container-engine/crictl : Copy crictl binary from download dir -------------------------------------------------- 3.53s
kubernetes/control-plane : Master | wait for kube-scheduler ----------------------------------------------------- 3.47s
bootstrap-os : Install dbus for the hostname module ------------------------------------------------------------- 3.44s
container-engine/validate-container-engine : Populate service facts --------------------------------------------- 3.24s
dimi@DESKTOP-K8RTBSS:~$
```
```bash
dimi@DESKTOP-K8RTBSS:~$ ssh ubuntu@158.160.116.26
ubuntu@k8s-master:~$ mkdir -p $HOME/.kube
ubuntu@k8s-master:~$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
ubuntu@k8s-master:~$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
ubuntu@k8s-master:~$ kubectl get nodes
NAME           STATUS   ROLES           AGE   VERSION
k8s-master     Ready    control-plane   78m   v1.29.1
k8s-worker-0   Ready    <none>          77m   v1.29.1
k8s-worker-1   Ready    <none>          77m   v1.29.1
k8s-worker-2   Ready    <none>          77m   v1.29.1
k8s-worker-3   Ready    <none>          77m   v1.29.1
ubuntu@k8s-master:~$ kubectl get nodes -o wide
NAME           STATUS   ROLES           AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k8s-master     Ready    control-plane   78m   v1.29.1   192.168.56.36   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.13
k8s-worker-0   Ready    <none>          77m   v1.29.1   192.168.56.7    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.13
k8s-worker-1   Ready    <none>          77m   v1.29.1   192.168.56.14   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.13
k8s-worker-2   Ready    <none>          77m   v1.29.1   192.168.56.3    <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.13
k8s-worker-3   Ready    <none>          77m   v1.29.1   192.168.56.20   <none>        Ubuntu 20.04.5 LTS   5.4.0-137-generic   containerd://1.7.13
ubuntu@k8s-master:~$
```


## Дополнительные задания (со звёздочкой)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой необязательные к выполнению и не повлияют на получение зачёта по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA.
2. Использовать нечётное количество Master-node.
3. Для cluster ip использовать keepalived или другой способ.

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl get nodes`, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.
