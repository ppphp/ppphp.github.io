---
layout: post
title:  "godot源码简析"
date:   2024-01-29 23:31:15 +0000
categories: source-code
---
# godot 源码分析

学习godot源码，简单的介绍这个软件。

godot是一个开源的游戏引擎。非常小巧简单，对大型3d项目以外的游戏项目都非常适合。

我使用的godot是一个4.3左右的master版本。

## 编译运行

godot使用一个非常小众的编译工具，叫做 `scons`，相当于是一个 `python`版的 `Makefile`。

`scons`非常的小巧，使用起来非常简单。开发基本都有python，直接pip就行。

```
pip install scons
scons
```

安装+运行，非常简单，自动多核编译，而且不需要任何的依赖。

一般玩一个代码第一步就是编译，这一步已经过去了。

随后打开 `bin`文件夹下的二进制文件，即可运行godot游戏编辑器。

## 简单的使用

godot基于场景节点构建整个游戏。使用起来非常简单，可以自行找教程，花不了多久。

编写完游戏后，会想要导出这个游戏，这个时候需要另外两个编译目标作为游戏模板。

```
scons target=template_debug
scons target=template_release
```

会在bin文件夹下生成两个二进制，顾名思义，是debug和release的模板。只要编译器支持，交叉编译也可以做到，换参数就行。

他们的运行原理是会把资源文件都打包成一个 `.pck`文件，template会想办法读取这个pck，等于是在虚拟机上跑脚本。

而我们之前编译的，其实是一个默认参数

```
scons target=editor
```

## 文件夹

源代码有一些文件夹，按字母顺序介绍一下

- `core`是一些怎么着都会被编译的代码，重要且平台无关。
- `doc`存放的文档，就是官网的文档，以xml格式组织，xml代表了节点的类和方法。
- `drivers`是一些驱动，基本上是图形api和声音api。
- `editor`包含了编辑器的代码，template就不会编译这个文件夹。
- `main`是启动代码，也是平台无关的，主要就在这里区分editor和template，其他和 `core`定位差不多。
- `misc`是一些乱七八糟的脚本，和代码没啥关系。
- `modules`是模块，一些对第三方的简单封装，反正就是些模块。
- `platform`是目标平台相关代码，一些平台api封装，举个例子就是syscall，fork这种，还有平台的图形api比如directx等等。
- `scene`是场景节点代码，比如editor里用到的节点，Node3D这种，都在这里封装。
- `servers`是一些功能封装，比modules高一点，比scenes低一点，不是真的服务器。
- `tests`是测试。
- `thirdparty`是第三方源码。

我们可以发现大概有一些封装的层次。

最高的是editor，他需要所有模块。

最低的是thirdparty，他不依赖任何文件，但是他不是真正属于godot的项目文件。其次是drivers，做的都是api接入的脏活累活，platform在他上面一点点。

调用的时候逻辑大概是：

editor->scene->servers->modules->core/platform->drivers->thirdparty

其他的忽略不计。

## 启动逻辑

`main`文件夹管理启动逻辑。

程序的启动的main在platform中，具体是哪个platform，取决于本机是那个platform，不然也跑不起来不是。比如我是gentoo，那就是linuxbsd。有时候是windows，就是windows。

经过platform的一通操作，会跑到两个 `main`的函数。

`main`的核心是一个 `Main`类，有 `setup`和 `start`两个方法，顾名思义，`setup`初始化环境，`start`进入loop。这是基本的程序逻辑。

在这里，template和editor会有不同的逻辑。

- template会在setup的时候读取pck文件，并进行解析验证，start会跳进脚本入口。
- editor会在setup的时候做很少的事情，然后在start的时候跳进 ` editor`文件夹下的 `EditorNode`类。

除了这两个最本质的区别，如果你的游戏很小，比如只有2d，可以通过宏裁剪template大小，也会通过宏影响到main是否初始化一些模块。

## 编辑器

`editor`包含了一个完整的编辑器，入口是 `EditorNode`节点。

用过qt和godot的同学会发现这俩玩意就是一模一样，或者说用c++的signal机制那就写出来只能一个样。

editor是一个非常传统的gui应用，使用了很多widget，存在 `scene/gui`文件夹下。

一些大的功能也放入了子文件夹，比如debugger可以连接新窗口的debug游戏，export可以打包成pck并连接到template，还有plugins读取编辑器插件。

编辑器包括了一些基本的widget，左边的treewidget，右边的属性编辑器，下面的资源管理器和通知和debug面板。

编辑器还在中间包括了三个复杂的编辑器，3dviewport，2dviewport，code editor，这三个编辑器代码量相对较多，特别是code editor，交互比较多，但是封装的比较好，可以把复杂度分摊到下面的scene,module,servers。

project manager封装了一些项目功能。

模板其实相对编辑器在c++的程度上简单，主要工作是读取pck。

## 场景节点

`scene`里提供了场景节点的功能。场景节点可以理解为godot提供的api和运行时。

一般游戏或者是应用，都跑在一个主线程上，godot也不例外，主线程主要功能就是管理node。main里可以看到加载根节点的功能，就是一个loop，也支持多个loop，我没有细看。

场景对于editor是通过c++的方式暴露接口，对于模板是通过脚本的方式暴露接口，相当于qt和pyside。

gui模块封装了一些gui模块，主要是editor会用，所以非常花哨，连节点编辑器都有。

2d模块是canvas。

3d模块比较复杂，最近render server在非常高强度的开发。

## 服务模块

`servers`和 `modules`在相似的层级上封装了api。我还不是很了解内部原理。

`modules`是一些具体的功能，比如 `fbx`，`csg`等等。很多都是对第三方的模块的简单封装。

`servers`是一组功能，比如 `rendering`，`physics_3d`。组装了 `modules`的功能提供了人性化接口。比如很流行的渲染工具d3d12和vulkan都是在 `rendering` server里实现的。

## 重要功能

`godot`在代码上有一些核心的功能。

`gdscript`。这个是godot官方支持的脚本，gdscript和gdextension是两个平行的关系，他们可以控制节点，使用 `_process`这个godot核心函数。除了gdscript，C#的支持是最好的，因为有很多Unity用户很喜欢C#。

`variant`。这个其实是gdscript的类型系统，他用Callable等概念包装了gdscript的函数和类和基本类型。

`signal`。这个是godot的通信机制，脚本可以自定义signal发射，也可以处理其他节点的信号。

`debug`。godot的editor有个很强的debugger，可以运行游戏，而真的运行游戏是把资源和脚本打包成 `pck`文件，然后通过template运行，有点像浏览器跑js。
