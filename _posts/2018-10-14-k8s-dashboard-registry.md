
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

就是一个k8s版的nginx，nginx现在吃了屎一样在追社区的ingress了

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
kubectl get pods --all-namespaces -l app.kubernetes.io/name=ingress-nginx --watch
```

## dashboard

dashboard就是看看这个有个啥功能，冒个烟充充门面

## docker registry

docker registry配合devops工具箱

## https

80端口怕被阿里云封

devops那个我还没弄成，先架起来，服务起来再说





