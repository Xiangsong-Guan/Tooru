Overview
===

The project is currently aimed at implementing a game theory calculation and analysis framework and trying to cover all common game types. On top of this, we try to build its scalable features to be flexible and compatible in the future to absorb the rest of the game types. The framework will provide a program interface for the `Lua` and `C` languages. Based on this, building a usable front-end program or developing other related applications will easily address game theory-related model building and data. Simulation, analytical calculations, etc.

The project is still one of the goals of cross-platform.

Language, data format and external dependencies
======

This project is currently developed using the dynamic language `Lua` (5.3) and the static language `C` (C11). Dynamic language is mainly used for basic model expression, call logic management, upper layer interface export, input and output processing, etc.; static language implements game algorithm implementation, data simulation and other functions. In addition, the project will rely on some mature equalization algorithms provided by the open source project _[Gambit](http://www.gambit-project.org/) (GPL)_. This part of the "glue code" is `C++`. Completed, which exports the functions available in Gambit as a `Lua` library.

In the basic `Lua` program, there is an external dependency:
* _[PenLight](https://github.com/stevedonovan/Penlight) (MIT)_ A generic `Lua` function component that provides some functional functions common in other languages
* _[lua-stdlib](https://github.com/lua-stdlib/lua-stdlib) (MIT)_ another generic `Lua` function component

This project uses some mature data description specifications on some input and output, such as `Yaml`. This brings up some external dependencies. Currently these dependencies are:
* _[lyaml](https://github.com/gvvaughan/lyaml) (MIT)_ A component for serializing and deserializing `Yaml` format data files in `Lua`
* _[luatoml](https://github.com/Xiangsong-Guan/luatoml) (MIT)_ A component for serializing and deserializing `Toml` format data files in `Lua`, which is only available for obsolescence Limited support

All documentation for this project is written by `Markdown`.

Replaceable peripheral tools
======

Version management
------

This project currently uses _Git_ for version management.

Construct
---

The dynamic language part does not need to be built. `C/C++` Compile builds using some modern build tools. The compiler front end currently used is _Clang (8.0.0)_, the compilation tool is _Ninja_, and compiled with _CMake_ configuration.

IDE
---

This project has used _VScode_ as a development tool from the beginning to the present, and the plug-in _CMake Tools_, _C/C++_, _vscode-lua_ together constitute the development environment. In addition, the plug-in _Markdown PDF_ is used to cure the document.

Directory Structure
======

The directories and files in the project that are tracked by version management are generally auto-generated/external artifacts, or files that are optional and highly relevant to individuals. See the `.gitignore` file in the root directory for a description of this class.

Environmental configuration
------

> .vscode  
> .vscode/c_cpp_properties.json  
> .vscode/settings.json  
> .vscode/tasks.json

These files configure some of the environment parameters and build/test tasks under _VScode_.

Document
----

> doc  
> doc/Dev-Man.en.md  
> doc/Dev-Man.zh.md  
> doc/Input-Game-Spec.en.md  
> doc/Input-Game-Spec.zh.md  
> doc/linterface.en.md  
> doc/linterface.zh.md

These documents are the various documents of this project.

Test and test input
------

> test  
> test-app.lua  
> test-unit.lua

The _test_ directory stores all the input data files needed in the test. `test-app.lua` is the function test code, and `test-unit.lua` is the unit test code.

Source code
-----

> tooru  
> tooru/gmod  
> tooru/res/text.lua  
> tooru/res/text.*.txt  
> tooru/src  
> tooru/third-party

The specific organization of the source code can be found in the source code writing chapter.

The _tooru_ directory holds all the core source code. The source code in the _gmod_ directory implements the game model. The _src_ directory is the source code of the `C` part. The _third-party_ is used to store the customized external dependent source code files. The other files under the _tooru_ are the core `Lua` source. Code file.

The _res_ directory holds other resources needed by the program and is currently limited to text. `text.lua` is the extraction code for text resources, and `text.*.txt` is a text resource for different languages ​​(actually organized in `Lua` data format).

Build instructions and parameters
------------

> CMakeLists.txt  
> config.h.in

`CMakeLists.txt` is the _CMake_ directive file. `config.h.in` is the build parameter configuration file for _CMake_.