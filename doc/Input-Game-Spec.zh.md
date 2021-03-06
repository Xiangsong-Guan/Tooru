本文描述了在使用程序时的输入规范。本程序的输入主体是一个文本化、格式化且人类可读写的博弈定义。程序的参数不在本文的讨论范围内，相关内容请参考程序帮助。

输入博弈的定义建立在通行的一些数据描述格式之上，本文不会赘述这些格式的规范。当前支持的格式有：

* `toml` 仅经典静态博弈经过了测试，其他类型博弈不推荐使用
* `yaml` 最常用的格式，所有的博弈类型都经过了测试

接下来，本文将从最基本的博弈出发，逐类型解释数据设置规范与注意事项。

经典静态博弈
===========

经典静态博弈是所有博弈的基础，在这一部分中，我们将描述所有博弈的基本内容。

标题
----

一个可选字段，关键字是 `title`，值类型是`字符串`。

顾名思义，是一个博弈的标题。这个字段不会影响内部分析计算，它只被用于帮助使用者理解输出

评论
----

一个可选字段，关键字是 `comment`，值类型是`字符串`。

顾名思义，是对于一个博弈、文件、项目的进一步之描述。这个字段不会影响内部分析计算，它只被用于帮助使用者理解输出

博弈类型
--------

一个必需字段，关键字是 `game_type`，值类型是`字符串`。

顾名思义，是该博弈的类型。目前程序支持的博弈类型有：
  * 经典静态博弈（由 `csg` 指代）
  * 重复博弈（由 `rpg` 指代）
  * 进化博弈（由 `evo` 指代）
  * 随机博弈（）不完全分析计算支持
  * 经典动态博弈（）
  * 贝叶斯博弈（）

回报
---

一个必需字段，关键字是 `payoffs`，值类型是`列表`，数组元素值类型是`字符串`或以数组表示的`矩阵`。

列表决定了您可以定义复数个回报，将其关联到不同的参与者类型上。_`toml` 规范不支持非同质列表_。

字符串定义的回报意味着这是一个特定参与者的效用函数，这个字符串必须是一个合法的 `lua` 表达式（算式），因为它最终会被编译成可执行代码段。在经典静态博弈中，您可以使用 `CHOICE[x]` 来表示第 `x` 个参与者的决策/行为；您可以使用 `SELF` 来表示回报计算对象自身的索引。所有其他信息、内/外部模块都无法在这段算式中获得。如果您需要更加复杂的效用函数，请使用 `lua` 接口。另外请注意**供您使用的预设值是只读的，程序不会察觉算式的合法性，直到它得到执行之后**。

矩阵定义的回报意味着这是一个回报矩阵。**若是您提供（初始）全局回报矩阵，请务必将其置于回报列表的第一位**；当然您也可以提供某一类型参与者的回报矩阵。列表中回报值是按照博弈结果排序。

数值开关
---

一个必需字段，关键字是 `value_switch`，值类型是`整数`。

当改字段值为 `0` 时开关为关；否则开关打开。该开关影响到行为空间定义中的值类型：开关打开是行为空间以数值定义，该数值配合回报定义中的算式将参与到回报的计算中。但是当存在全局回报矩阵时，回报计算会以全局回报矩阵为准，直到在运行时回报定义被修改，此时回报将被重新计算；反之行为空间以标签定义，它只是行为的标注，回报一定由回报矩阵给出。

行为
---

一个必需字段，关键字是 `action_sets`，值类型是`列表`，数组元素值类型是`数组`，列表元素的值类型是`字符串`或`实数`，这取决于数值开关。

该列表表示了一个行为集合，被用于定义不同的参与者类型。

参与者类型
---

一个必需字段，关键字是 `types`，值类型是`数组`（`toml` 下是以空白字符分割的`字符串`）。

它有着特定的协议：一种类型以连续的四个元素表示，依次为标签（`字符串`）、是该类型的参与者数量（`整数`）、行为空间索引（`整数`）、回报索引（`整数`）。

重复博弈
======

重复博弈是对于经典静态博弈的扩展，本章仅描述这些扩展的部分。

重复时间
------

关键字是 `stop`，值类型是`整数`或`浮点`。

当其为`整数`值时，重复博弈将在进行这些次数后终止，`0` 意味着博弈没有结束。

`浮点`值表示折现因子，这个因子有几个可用的解释。总之，程序中的折现因子表征在每一次博弈后整个重复博弈继续进行的概率。

策略
---

关键字是 `strategies`，值类型是`列表`，列表元素根据情况有所不同。

这个字段的定义有一个特定的协议：一个策略由三个连续元素表示。按照顺序有标签（`string`），由空格分隔的注册表键值对列表（`string`）和策略源代码（`string`）。

注册表中的每一个键值对（`<hot>=<dog>`），`<hot>` 是注册项的名字。这个名字只可以由二十六个大写英文字母、小写英文字母、十个阿拉伯数字与下划线组成，`<dog>` 是注册项的初始赋值，这个值包含**除去空白字符之外**的所有字符。当它能够被解析为一个实数时，他将被视为实数时否则它就是一个字符串。值得注意的是单双引号不应该被用于包围字符串，这将导致它们也被解析为字符串的一部分。

策略源代码是 `lua` 源代码，且必须是合法的 `lua` 源代码。只有语法错误能够被程序检查，运行时错误只能在真正运行时被捕获并且会导致计算失败。这段代码只能够访问有限的全局变量：注册表项、博弈实例、参与者的全局索引以及 lua 中的数学计算库。关于博弈模型的内容参考文件 [linterface](linterface.zh.md)。

策略控制着参与者在整个重复博弈进行中的行为选择模式。

进化博弈
======

进化博弈是对重复博弈的扩展，不过它会删除重复博弈中对于策略字段的定义。

选择强度
------

关键字是 `selection_intensity`，值类型是`非负实数`。

选择强度影响自然选择的强度，强度越大意味着劣势群体越可能被淘汰，他们规模缩小的速度也可能会更快。

变异强度
-----

关键字是 `mutations_intensity`，值类型是`比例`。

变异强度越大意味着变异越有可能发生。

初始分布
-------

关键字是 `init_distri`，值类型是`列表`，元素值类型是`比例`或`整数`。

当元素值包含小数点时，它被认为是表示群体数量在总体中的比例；或它是一个整数，表示群体的数量。

模拟群体数量
---------

关键字是 `simulation_population`，值类型是`非负整数`。

顾名思义。`0` 意味着群体是无限的。