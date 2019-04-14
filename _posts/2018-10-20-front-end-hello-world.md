---
layout: post
title:  "frontend hello world"
date:   2018-10-21 23:31:15 +0000
categories: jekyll update
---

# 前端小研究

github page主要是为了搞前端的东西，因为这玩意就是个网页，canvas小程序什么的，结果忘了初心，搞了老半天devops去了，主要devops对我来说擅长一点，前端学习需要自己创造美术素材。。。我这个不行

但是能无条件嵌入javascript脚本还是很爽的。

https://developer.mozilla.org/zh-CN/docs/Web/API/Canvas_API/Tutorial/Drawing_shapes

<canvas width="150" height="150"></canvas>
<script>
function draw() {
  var canvas = document.getElementsByTagName('canvas');
  if (canvas.getContext) {
    var ctx = canvas.getContext('2d');

    ctx.fillRect(25, 25, 100, 100);
    ctx.clearRect(45, 45, 60, 60);
    ctx.strokeRect(50, 50, 50, 50);
  }
}
draw();
</script>
