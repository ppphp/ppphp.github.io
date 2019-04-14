
---
layout: post
title:  "frontend hello world"
date:   2018-10-21 23:31:15 +0000
categories: jekyll update
---
# let's encrypt基本操作
let's encrypt是非常流行的免费ssl证书提供商。它非常可用，非常方便。一次申请可以免费提供有效期为三个月的ssl证书。

let's encrypt的[官网](https://letsencrypt.org/)说的已经很详细了，但是我还是要记录一下流程。

## certbot安装
首先我们使用官方的管理工具certbot。

这是一个python脚本，自动处理申请证书的复杂流程。一般申请证书就只需要ssl的网址，然后获得相应的pem文件。使用的时候，把pem文件放到对外的服务器，比如nginx或apache，就大功告成了。

let's encrypt给大部份发行版都封装好了certbot的安装包，直接拿来用就可以了，但是centos有点问题，用贴近源码的方式，这样可以控制一点。centos包管理真的垃圾。

```sh
sudo su -
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
pyenv install 3.7.1
pyenv local 3.7.1
pip install certbot
certbot certonly
```

如果一步步下来能拿到证书，那就太好了，不过我自己的情况是不能拿到的，因为certbot有一套比较简单但是必要的逻辑，可能和目前环境不兼容，搞清楚问题就能方便地运行了。

## cerbot原理
接下来就是如何使用certbot了。

### 确认域名
因为lets encrypt不要钱，所以使用上会有点限制的地方，比如要证明这个域名是我的，否则万一来个机器人刷一刷，马上亏死了。那么如何证明这个域名是我的呢？let's encrypt会发一个http的授权信息到需要证书的某个url，然后我们用这个url收到的信息，回到它那里确认我们确实拥有这个域名。

### 服务器
于是我们需要一个服务器获取验证信息，certbot自带一个开箱即用的standalone。但是我们可能线上正在运行一个服务器，我们不想让它停下来一分钟三十秒，专门跑个certbot。而且三个月之后续期的时候，肯定影响到线上的运行。解决办法是对着我们使用的线上服务器写一个插件，预留一个url地址给let's encrypt来做验证。

我一般使用nginx来做服务器。一般不用java或者不是apache插件爱好者的话，基本都用nginx了。安装certbot的nginx插件，然后在nginx上面这个域名规定一个地址转发即可。

```sh
pip install cerbot-nginx
certbot --nginx
```

如果这一步能拿到证书，也挺好，但是我的情况还是不行。

### 阿里云
certbot在验证的时候是访问的http的80端口，很好理解，领免费证书的穷鬼里，只开443端口不开80端口的比较少，优先照顾只有http的困难用户。但是阿里云会对没有审批的80端口的服务器的域名访问做屏蔽处理，所以我们就收不到certbot请求的验证。好在certbot足够智能，我们还有别的办法。

使用阿里云绝对是失误。。。尽量用国外的云或者托管来运行自己的应用。

### DNS验证
certbot提供了按照DNS来验证域名所有权的方式。我用通配符域名，所以申请的也是通配符的证书。

```sh
certbot -d *.example.com --manual --preferred-challenges dns certonly
```

然后按照它说的修改DNS的txt记录就可以了。

### https验证

