
# Table of Contents

1.  [简单的org入门](#orgaa7d01b)
    1.  [标题](#org75decbe)
    2.  [列表](#orgb00d0a0)
    3.  [表格](#org5b2109f)
    4.  [简单操作](#org39ecdec)
    5.  [html](#orga6ff0e1)



<a id="orgaa7d01b"></a>

# 简单的org入门

org mode可以理解为比较老，功能比较多的markdown了。
看了一圈教程，markdown有的功能它都有，还有特别复杂的功能，只在emacs里面有。
那么饭要一口一口吃，先学一下一些org的简单标记符号。


<a id="org75decbe"></a>

## 标题

org使用\*作为标题的标记，和markdown用#做标题类似，markdown主要方便兼容在代码里作为注释使用，org就没有这个顾虑了，用专用的就行。


<a id="orgb00d0a0"></a>

## 列表

org使用-,+,\*作为无须列表的标记， 1. , 1) 这样的作为有序列表的标记

举例

-   1
-   2
-   **3:** 1+2


<a id="org5b2109f"></a>

## 表格

org表格跟markdown也差不多的

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="org-left" />

<col  class="org-left" />
</colgroup>
<tbody>
<tr>
<td class="org-left">1</td>
<td class="org-left">2</td>
</tr>


<tr>
<td class="org-left">==</td>
<td class="org-left">==</td>
</tr>


<tr>
<td class="org-left">&#xa0;</td>
<td class="org-left">&#xa0;</td>
</tr>
</tbody>
</table>


<a id="org39ecdec"></a>

## 简单操作

打开org，所有正文会缩起来，就一个标题露在外面，动也动不了，tab可以展开


<a id="orga6ff0e1"></a>

## html

jekyll的html可以解析出来，看一下org mode的标签行不行

<canvas width="150" height="150" id="canvas"></canvas>
<script>
function draw() {
  var canvas = document.getElementById('canvas');
  if (canvas.getContext) {
    var ctx = canvas.getContext('2d');

    ctx.fillRect(25, 25, 100, 100);
    ctx.clearRect(45, 45, 60, 60);
    ctx.strokeRect(50, 50, 50, 50);
  }
}
draw();
</script>

