



---
layout: post
title:  "k8s learn"
date:   2018-10-14 23:31:15 +0000
categories: jekyll update
---

# 学习k8s

k8s太难了，单独写一下这玩意怎么搞的

## 目标

学习使用k8s作为测试发布平台

自身需要安装的工具是dashboard，另外需要安装的是发布目标程序

在这其间还要踩一些坑，需要安装以下应用
-- ingress
-- dashboard
-- docker registry
-- https

## ingress

我先安装了dashboard，但是真的要做成应用的话，ingress应该是最早安装的

kubernetes会把它的服务做成一个个小网络组成的集群，每个服务对应了集群的ip，想获取服务时，需要从这些虚拟ip上映射到外网ip的端口

其实就是一个k8s版的nginx，nginx现在吃了屎一样在追社区的ingress了

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch
```

## dashboard

dashboard就是看看这个有个啥功能，冒个烟充充门面

## docker registry

docker registry配合devops工具

## https

80端口怕被阿里云封

devops那个我还没弄成，k8s先架起来，服务起来再说

## 基本概念

厘清问题之后，我们可以回来看基本概念查漏补缺了。

原本以为k8s是一个方便的工具，docker放在上面就可以安稳运行了，实际上并不是，k8s反而是复杂化了问题。它的逻辑是强迫分离运维的各个组件，从而适配上高级功能。

k8s基本的组件分离是比较好懂的，几个docker组成一个pod，一个pod有它自己的ip地址，pod可以存在一个node上面，node就是我们登录的物理机或者是虚拟机，然后node组成一个k8s集群，管理集群的机器叫master。简单的说就是一个pod一个ip，一个node一台机器，pod相当于node上起的虚拟机。

k8s和docker一样，是一个运行在机器上的服务，必须用客户端与这个服务通信，正因为如此翻墙的事情我经常搞不定，用网上的yml文件最好提前下载下来。kubectl就是这样一个客户端工具，而初始化新节点就是用kubeadm。

现在概念才刚刚开始，之后的概念，新手的我就开始混沌了。也是我说这玩意很复杂的原因，连我都搞不定，一定是框架设计的原因。

## 网络插件

首先是网络插件，为什么k8s要装网络插件呢，一个docker编排平台需要网络插件干什么？k8s的网络插件就是负责为pod分配ip的工具。我现在还不知道装哪一种比较好，总之安装完k8s之后需要马上安装一种。网络插件使用还是比较简单的，即插即用，至少在刚刚安装完的一段时间内，不用操心它的行为了。

之后应用调试的时候，可以直接在机器上面curl内部ip就可以访问服务了。docker原本把进程抽象成端口，k8s的网络库把docker的端口抽象成了由ip组织的端口。

## k8s资源

kubectl可以查看k8s上运行的东西，`kubectl get all --all-namespaces`是获取运行内容的基本信息，`kubectl describe all --all-namespaces`是获取运行内容的详细信息。

我们注意到，抛开动词，这上面由两个参数，一个是all，还有一个是all-namespaces，第一个all是k8s运行内容，比如pod，service，deployment，daemonset等等，但是不是所有东西都会显示，第二个是选择命名空间，相当于一个标签。

## ingress

ingress是一个服务的统一出口。k8s的pod默认不对外开放，但是在宿主机上可以访问，于是社区就想用一个类似nginx的东西来管理这些网络的对外服务。需要自己管理插件和服务，这就是ingress的复杂之处。

还有一种解决方案是用nodeport，每个服务分配一个port。个人觉得问题是不够灵活，ingress还可以管理二级域名，而且nodeport大规模使用非常蛋疼，因为nodeport是全局分配的，所有机器都要留一个nodeport，很不漂亮。

## yml格式

现在研究一下yml都长什么样，结构看是能看懂。

比如第一个下载的dashboard

```yaml
# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ------------------- Dashboard Secret ------------------- #

apiVersion: v1
kind: Secret
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard-certs
  namespace: kube-system
type: Opaque

---
# ------------------- Dashboard Service Account ------------------- #

apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system

---
# ------------------- Dashboard Role & Role Binding ------------------- #

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kubernetes-dashboard-minimal
  namespace: kube-system
rules:
  # Allow Dashboard to create 'kubernetes-dashboard-key-holder' secret.
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["create"]
  # Allow Dashboard to create 'kubernetes-dashboard-settings' config map.
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["create"]
  # Allow Dashboard to get, update and delete Dashboard exclusive secrets.
- apiGroups: [""]
  resources: ["secrets"]
  resourceNames: ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs"]
  verbs: ["get", "update", "delete"]
  # Allow Dashboard to get and update 'kubernetes-dashboard-settings' config map.
- apiGroups: [""]
  resources: ["configmaps"]
  resourceNames: ["kubernetes-dashboard-settings"]
  verbs: ["get", "update"]
  # Allow Dashboard to get metrics from heapster.
- apiGroups: [""]
  resources: ["services"]
  resourceNames: ["heapster"]
  verbs: ["proxy"]
- apiGroups: [""]
  resources: ["services/proxy"]
  resourceNames: ["heapster", "http:heapster:", "https:heapster:"]
  verbs: ["get"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kubernetes-dashboard-minimal
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubernetes-dashboard-minimal
subjects:
- kind: ServiceAccount
  name: kubernetes-dashboard
  namespace: kube-system

---
# ------------------- Dashboard Deployment ------------------- #

kind: Deployment
apiVersion: apps/v1beta2
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
    spec:
      containers:
      - name: kubernetes-dashboard
        image: k8s.gcr.io/kubernetes-dashboard-amd64:v1.10.0
        ports:
        - containerPort: 8443
          protocol: TCP
        args:
          - --auto-generate-certificates
          # Uncomment the following line to manually specify Kubernetes API server Host
          # If not specified, Dashboard will attempt to auto discover the API server and connect
          # to it. Uncomment only if the default does not work.
          # - --apiserver-host=http://my-address:port
        volumeMounts:
        - name: kubernetes-dashboard-certs
          mountPath: /certs
          # Create on-disk volume to store exec logs
        - mountPath: /tmp
          name: tmp-volume
        livenessProbe:
          httpGet:
            scheme: HTTPS
            path: /
            port: 8443
          initialDelaySeconds: 30
          timeoutSeconds: 30
      volumes:
      - name: kubernetes-dashboard-certs
        secret:
          secretName: kubernetes-dashboard-certs
      - name: tmp-volume
        emptyDir: {}
      serviceAccountName: kubernetes-dashboard
      # Comment the following tolerations if Dashboard must not be deployed on master
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule

---
# ------------------- Dashboard Service ------------------- #

kind: Service
apiVersion: v1
metadata:
  labels:
    k8s-app: kubernetes-dashboard
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  ports:
    - port: 443
      targetPort: 8443
      nodePort: 443
  type: NodePort
  selector:
    k8s-app: kubernetes-dashboard
```

三横是分割符，表示上下完全是两个东西，编程语言里就是两个对象或者是两个结构体。缩进分格跟python一样，yml的层级通过行首缩进实现，一般是两个空格。冒号代表map或者hash，左边是键，右边是值，右边写不下可以加两个空格的缩进，写到下一行。单横杠跟个空格代表之后是数组的元素。

实在不能理解的时候可以看着缩进把它看成是json，yml经常标榜自己是json的超集。

## deployment, service

service是kubernetes管理pods的东西。service描述了pods的对外状态，比如说pod的对外端口。基本上一个service就是一个pod。上面的yml例子里，kind: Service的就是描述了一个k8s服务。

deployment描述了部署service的行为过程，也描述k8s资源的整合，比如镜像，持久化卷。可以说deployment才是管理everything的，所以上面那个yml也是deployment最长。

这两个行为是主要关心的行为，天知道k8s的人是怎么想的，给一个hello world一样的dashboard会死，一定要把secret，role binding这样有的没的的功能都加上去才能显示水平。

## 对外服务

k8s的service负责管理pod对外服务，但是对于整个系统来说，默认服务不对外。

之前的yml是我改过的，确定nodePort和type是NodePort之后，直接就会对外了。nodeport一般情况下都会有限制，需要手动改以下配置，重启apiserver，扩充端口到可以绑定30000以下。

但是我觉得nodeport比较low，一个service对应一个nodeport很不优雅。因为我想用k8s来实现最终对外的行为，必须都绑定到80端口，需要nginx做二级域名的转发。

所以我们就建立一个nginx的服务和一个default backend的服务。



