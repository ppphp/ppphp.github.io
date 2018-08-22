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

这次的安装与以往不同，以前自己折腾会力求完美，所有都安装最新版本的，但是这次只求快速，尽量使用容易获取的版本。因为这台机子以前装过pg9.6所以这次也是pg9.6。开发版安装，反正跟项目没关系，不对了git checkout一下就好了。

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

## gitlab
参考https://docs.gitlab.com/ee/install/installation.html和https://packages.gitlab.com/gitlab/gitlab-ce/install社区版的gitlab没有很复杂的组件，只有一rails，一redis，一db而已

有rpm包，但是怕出事，主要是pg版本的问题，选择源码安装，还是不负责任的直接开发版，开发版果然挂了。。。用稳定版，稳定版也不太行。。。简直是吃内存的怪物

```
git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 11-2-stable gitlab
```

还真他妈巧了，这里面有个叫`.ruby-version`的文件，他会指导rbenv用哪种版本，包括gem，bundle全家。

但是我他娘的居然之前没装epel？？？
```
rbenv install 2.4.4
sudo yum install epel-release
sudo yum install libicu-devel cmake mysql-devel re2-devel libsqlite3x-devel
gem install bundle
bundle install
```

然后还需要一个nodejs环境
```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
nvm install
```

忘了配db了，真他妈巧了，gitlab也推荐用postgresql，直接建表了
```
CREATE ROLE gitlab LOGIN ENCRYPTED PASSWORD 'my_password' NOINHERIT VALID UNTIL 'infinity';
CREATE DATABASE gitlabhq_production OWNER gitlab;
\c gitlabhq_production
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

```
yum install redis golang
```
git too old
```
sudo rpm -U http://opensource.wandisco.com/centos/7/git/x86_64/wandisco-git-release-7-2.noarch.rpm     && sudo yum install -y git
```
终于可以配置了
```
cp config/gitlab.yml.example config/gitlab.yml
vim config/gitlab.yml # for me, alter every /home/git path to my path, gitlab user to myself
cp config/secrets.yml.example config/secrets.yml
chmod 0600 config/secrets.yml
mkdir public/uploads/
chmod 0700 public/uploads
cp config/unicorn.rb.example config/unicorn.rb
vim config/unicorn.rb # change working directory
cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb
git config --global core.autocrlf input
git config --global gc.auto 0
git config --global repack.writeBitmaps true
git config --global receive.advertisePushOptions true
cp config/resque.yml.example config/resque.yml
cp config/database.yml.postgresql config/database.yml
vim config/database.yml
bundle exec rake gitlab:shell:install REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production SKIP_STORAGE_VALIDATION=true # most problem happened here please check config/gitlab.yml
bundle exec rake "gitlab:workhorse:install[/home/devops/gitlab-workhorse]" RAILS_ENV=production
git clone https://gitlab.com/gitlab-org/gitlab-pages.git
cd gitlab-pages
git checkout v$(</home/devops/gitlab/GITLAB_PAGES_VERSION)
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
sudo yum install bison -y
gvm install go1.10.3 -B
gvm use go1.10.3 --default
gmake
cd ../gitlab
bundle exec rake "gitlab:gitaly:install[/home/devops/gitaly]" RAILS_ENV=production
bundle exec rake gitlab:setup RAILS_ENV=production # change lib/tasks/gitlab/setup.rake not to check gitaly, then go back
bundle exec rake gitlab:env:info RAILS_ENV=production
bundle exec rake gettext:compile RAILS_ENV=production
npm install yarn --global
yarn install --production --pure-lockfile
bundle exec rake gitlab:assets:compile RAILS_ENV=production NODE_ENV=production
sudo cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab
sudo cp lib/support/init.d/gitlab /etc/init.d/gitlab
sudo cp lib/support/init.d/gitlab.default.example /etc/default/gitlab
sudo service git
```

## jenkins
jenkins是个java包，下个jar就能跑了

```
wget http://mirrors.jenkins-ci.org/war-stable/2.121.3/jenkins.war
java -jar jenkins.war
```

## k8s
k8s是个go，打包成可执行文件了



## docker
必须使用社区源支持的版本




