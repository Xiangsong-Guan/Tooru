总览
===

本项目目前旨在实现一个博弈论计算、分析框架，并试图覆盖所有常见的博弈类型。在此之上试图建立其可扩展的特性以在未来能够灵活地兼容吸收其余的博弈类型。该框架将提供 `Lua` 与 `C` 语言的程序接口，以此为基础，无论是构建一个可用的前端程序，或是开发其他相关的应用都将能够轻松应对博弈论相关的模型建立、数据模拟、分析计算等工作。

本项目目前仍以跨平台为目标之一。

语言、数据格式与外部依赖
======

本项目目前使用动态语言 `Lua`（5.3）与静态语言 `C`（C11）开发。动态语言主要用于基本模型的表达、调用逻辑管理、上层接口导出、输入输出处理等功能实现；静态语言则实现博弈算法实现、数据模拟等功能。此外本项目将依赖与开源项目 _[Gambit](http://www.gambit-project.org/) (GPL)_ 所提供的一些成熟的均衡求解算法实现，这一部分的“胶水代码”以 `C++` 完成，其将 _Gambit_ 中适用的函数以 `Lua` 函数库的形式导出。

在基础 `Lua` 程序中，存在一下外部依赖：
* _[PenLight](https://github.com/stevedonovan/Penlight) (MIT)_ 一个通用 `Lua` 功能函数组件，提供一些在其它语言中常见的功能函数
* _[lua-stdlib](https://github.com/lua-stdlib/lua-stdlib) (MIT)_ 另一个通用 `Lua` 功能函数组件

本项目在部分输入输出上使用一些成熟的数据描述规范，如 `Yaml` 等。这带来了一些外部依赖。目前这些依赖有：
* _[lyaml](https://github.com/gvvaughan/lyaml) (MIT)_ 一个用于在 `Lua` 中序列化与反序列化 `Yaml` 格式数据文件的组件
* _[luatoml](https://github.com/Xiangsong-Guan/luatoml) (MIT)_ 一个用于在 `Lua` 中序列化与反序列化 `Toml` 格式数据文件的组件，该组件仅提供过时的有限支持

本项目所有的文档均由 `Markdown` 写成。

可替换外围工具
======

版本管理
------

本项目目前使用 _Git_ 进行版本管理。

构建
---

动态语言部分无需构建。`C/C++` 使用一些现代构建工具进行编译构建。目前使用的编译器前端是 _Clang (8.0.0)_，编译工具是 _Ninja_，并且使用 _CMake_ 配置编译。

IDE
---

本项目从开始到目前使用 _VScode_ 作为开发工具，配合插件 _CMake Tools_、_C/C++_、_vscode-lua_ 共同构成开发环境。此外还使用插件 _Markdown PDF_ 固化文档。

目录结构
======

项目中为受版本管理追踪的目录与文件一般都是自动生成的/外部的产物，抑或是可有可无、与个人高度相关的文件。这一类说明参见根目录下的 `.gitignore` 文件。

环境配置
------

> .vscode  
> .vscode/c_cpp_properties.json  
> .vscode/settings.json  
> .vscode/tasks.json

这些文件配置 _VScode_ 下的一些环境参数与构建/测试任务。

文档
----

> doc  
> doc/Dev-Man.en.md  
> doc/Dev-Man.zh.md  
> doc/Input-Game-Spec.en.md  
> doc/Input-Game-Spec.zh.md  
> doc/linterface.en.md  
> doc/linterface.zh.md

这些文件是本项目的各式文档。

测试与测试输入
------

> test  
> test-app.lua  
> test-unit.lua

_test_ 目录下存放所有在测试中需要的输入数据文件。`test-app.lua` 是功能测试代码，`test-unit.lua` 是单元测试代码。

源代码
-----

> tooru  
> tooru/gmod  
> tooru/restext.lua  
> tooru/restext.*.txt  
> tooru/src  
> tooru/third-party

源代码的具体组织见源代码编写章节。

_tooru_ 目录存放了所有的核心源代码。_gmod_ 目录下的源代码实现博弈模型，_src_ 目录下是 `C` 部分的源代码，_third-party_ 用于存放经过定制的外部依赖源代码文件，整个 _tooru_ 下的其他文件均是核心 `Lua` 源代码文件。

_res_ 目录下存放了程序需要的其他资源，目前仅限于文本。`text.lua` 是文本资源的提取代码，`text.*.txt` 是不同语言的文本资源（实际上同样以 `Lua` 数据格式组织）。

构建指令与参数
------------

> CMakeLists.txt  
> config.h.in

`CMakeLists.txt` 是 _CMake_ 指令文件。`config.h.in` 是供 _CMake_ 使用的构建参数配置文件。
