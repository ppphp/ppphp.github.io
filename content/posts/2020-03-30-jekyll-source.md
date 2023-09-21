---
layout: post
title:  "jekyll源码观看"
date:   2020-03-30 23:31:15 +0000
categories: source-code
---

# jekyll

因为我比较喜欢ruby，所以想用jekyll作为博客平台。然后因为在搞emacs所以想用org写文档，然后jekyll官方不支持，所以想自己搞个大大的插件，先从源码看起。

## 项目结构

### 组织架构
首先我们看到.github文件夹下的CODEOWNER，分了6个组
- build组做核心渲染
- ecosystem组做插件，我主要看这个咯
- stability组做ci
- documentation组写文档
- windows组做windows
- affinity team captions组基本就是大佬管管github配置文件

### 参数
cli他们自己写了一个库叫mercenary来管理命令行参数，这个具体我就不看了。。。就看看参数
- source,s 源码地址，也就是项目地址
- destination,d 目标地址，生成的markdown渲染html就到这里
- safe安全模式
- plugins_dir,p 插件地址
- layouts_dir 布局地址
- profile 个人介绍

## 初始化
exe里可以看到mercenary把命令封装的特别好，以至于我都不知道它是怎么跑起来的了，我觉得block里的是初始化，因为我看他最后p.subcommand还在找。

于是直接进入下一步，看lib里的jekyll.rb这个文件，这个里面一堆autoload，我就知道，直接看commands里的代码就对了。

## 命令

jekyll的命令还挺好看的，在commands里一眼就看的出来。

### build
new和new_theme这种太傻了，没啥看的，然后干啥都得build，先看build。

build在 jekyll/commands/build.rb里，这个文件也是很简单的。init里啥也没有，然后process方法封装了一下就调了build方法。

然后转到site.process方法，这是个啥，我看不懂了，卡壳了。。。

