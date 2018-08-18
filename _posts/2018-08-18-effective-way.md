---
layout: post
title:  "小工具"
date:   2018-08-18 19:42:15 +0000
categories: jekyll update
---
想自己做点小东西，但是一整套工具不是很舒服，正好做搞自动化的工具，就尝试做一套流程

主要需求是要自动化测试，发布

看了半天，发觉还是gitlab，jenkins，redmine，k8s，docker这套流程比较好一点。

- redmine管理项目流程
- 代码托管在gitlab上
- 触发jenkins测试什么的
- 发布靠k8s
- docker打包运维

说起来简单，做起来难，随时更新，也可能分几步，大概按以下流程来
- 安装，管理组件
- 大致连接组件
- 管理
- 编写demo小网站
- 提交
- 编写测试，可能是tdd
- 测试
- 打包本地
- 自动发布
- 运行人肉测试

因为穷，开发环境和运行都只能在同一台vps上，搬瓦工服务器，便宜，并没有跑ss，ss在另外一台，主要怕封了ip，反正是docker，也无所谓环境的问题了。

介绍以下背景贺环境：半科班，会写一点go,ruby,python,c++等等，还有一点杂七杂八的语言，不提了，用过ubuntu,fedora,gentoo桌面，centos,freebsd服务器。

# 安装
## 安装redmine
先安装redmine是因为它管理软件，我可以直接用它来管理任务。比如之后的安装，又部署等等。

很简单，redmine有官网教程http://www.redmine.org/projects/redmine/wiki/redmineinstall。作为ruby入门玩家，我选择postgresql作为连接db。可能接下来

这次的安装与以往不同，以前自己折腾会力求完美，所有都安装最新版本的，但是这次只求快速，尽量使用容易获取的版本。因为这台机子以前装过pg9.6所以这次也是pg9.6。

```
yum install git ruby postgresql96-devel ImageMagick-devel
git clone https://github.com/redmine/redmine.git
```

数据库建库

```
su postgres -c psql
CREATE ROLE redmine LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE redmine WITH ENCODING='UTF8' OWNER=redmine;
```

发现他娘的依赖装不上，ruby版本太低了。然后老办法，rbenv，参照https://ruby-china.org/wiki/rbenv-guide
```
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
git clone git://github.com/rkh/rbenv-update.git ~/.rbenv/plugins/rbenv-update
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv install 2.5.1
rbenv global 2.5.1
```

银河护卫队可真有意思，可惜导演凉了

安装依赖
```
gem install bundler
bundle install --without development test
```

开始运行
```
bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production REDMINE_LANG=zh bundle exec rake redmine:load_default_data
mkdir -p tmp tmp/pdf public/plugin_assets
sudo find files log tmp public/plugin_assets -type f -exec chmod -x {} +
bundle exec rails server webrick -e production
```

用户名admin 密码admin

然后是redmine theme代替辣眼睛的默认主题

# gitlab
https://docs.gitlab.com/ee/install/installation.html

有rpm包，但是怕出事，选择源码安装





