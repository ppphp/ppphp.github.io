
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

首先是网络插件，为什么k8s要装网络插件呢，一个docker编排平台需要网络插件干什么，这个就是负责为pod分配ip的工具。我现在还不知道装哪一种比较好，总之安装完k8s之后需要马上安装一种。网络插件还是比较简单的，至少安装完一段时间内，不用操心它的行为了。

之后应用调试的时候，可以直接在机器上面curl内部ip就可以访问服务了。docker原本把进程抽象成端口，k8s的网络库把docker的端口抽象成了由ip组织的端口。

## k8s资源

kubectl可以查看k8s上运行的东西，`kubectl get all --all-namespaces`是获取运行内容的基本信息，`kubectl describe all --all-namespaces`是获取运行内容的详细信息。

我们注意到，抛开动词，这上面由两个参数，一个是all，还有一个是all-namespaces，第一个all是k8s运行内容，比如pod，service，deployment，daemonset等等，但是不是所有东西都会显示，第二个是选择命名空间，相当于一个标签。

## ingress

ingress是一个服务的统一出口。k8s的pod默认不对外开放，但是在宿主机上可以访问，于是社区就想用一个类似nginx的东西来管理这些网络的对外服务。需要自己管理插件和服务，这就是ingress的复杂之处。

还有一种解决方案是用nodeport，每个服务分配一个port。个人觉得问题是不够灵活，ingress还可以管理二级域名，而且nodeport大规模使用非常蛋疼，因为nodeport是全局分配的，所有机器都要留一个nodeport，很不漂亮。

##

