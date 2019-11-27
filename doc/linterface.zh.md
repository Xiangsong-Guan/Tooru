```text
非导出模块不支持手工导入，这可能会导致一些必要的初始化工作被跳过。
```
```text
所有参与者与行为（或策略）的索引均从一开始计数。他们的编号统一依据他们在输入博弈定义文本段中的出现顺序。这些索引我们在本文中称之为全局索引；与之相对的，局部索引是计算环境中针对的特定参与者自身所拥有的行为之索引，同样按照出现顺序定义。当某类型参与者的行为空间等于博弈整体的行为空间时，二者相同；否则局部索引所索引到的行为空间一定是全局索引空间的子集。在程序内部通常使用局部索引，因为这样便于回报的计算；而对于输入内容来说，使用标签可能更为直观。全局索引为“索引-标签”转换提供了链接。
```
```text
非特殊说明的情况下，所有方法、函数中提到的博弈元素均以其索引指代，这与程序内部的实现保持了一致。请使用博弈实例中提供的“标签-索引”转换方法来进行相互转换。
```

<a id="csg"></a> 博弈模型
==========

> `require'tooru'.game`
> * tooru/init.lua
> * tooru/game.lua
> * tooru/gmod
>   * csg.lua 经典静态博弈
>   * evo.lua 进化博弈
>   * rpg.lua 重复博弈

这些源代码实现了常见博弈模型在内存中的表达。这些源代码组成了一个 `lua` 模块。这个模块被用作制造博弈实例的工厂。您可以以一段被程序读取并整理的博弈文本段来初始化它，例如 `yaml` 格式。这个工作通常有文本处理模块完成，参见[文本处理](#text-process)。

### `.new(formated_game_table) -> Game`

新建一个全新的博弈实例。这个博弈实例可以接受修改。所有的修改也可以被存储到文件系统中并在之后再次加载。出现错误时将返回 `nil` 与错误信息。

* `formated_game_table - table` 被程序读取自格式化博弈文本段并整理的博弈内容。它通常被其他程序载入，您也可以手工写入。参见[文本处理](#text-process)

博弈实例
--------

本节描述所有类型的博弈实例的公共字段与方法。

### `PAYOFF_MTX - list`

只读字段，博弈的全局回报矩阵。在随机博弈这样回报会发生变化的博弈中，该字段可能在内部接受修改。

### `RAW - table`

只读字段，保留了被用于初始化该博弈实例的原始输入，即 `formated_game_table`。

### <a id="game-content"></a> `CONTENT - string`

只读字段，序列化的博弈实例。通常由[序列器产生](serialzors)。

### `attr - table`

博弈的通常属性。这些属性（包括后文的扩展部分）的详细定义与取值空间可参考[博弈定义规范](Input-Game-Spec.zh.md)。其中包含以下内容：

* `title - string` 博弈的题目
* `comment - string` 对于该博弈的额外说明
* `value_switch - int` 博弈是否开启数值计算，置零为否
* `game_type - string` 博弈的类型，如 `csg/rpg/evo...`

### `:copy_choice_label2idx(choice_in_labels) -> list`

将以标签表示的博弈选择结果组合变换为以行为的索引表示的组合，这个索引是全局索引。无效的标签将被替换为无效的索引（小于 `1`）。

* `choice_in_labels - list` 博弈选择结果组合，按照参与者的索引排列。其行为选择以行为的标签表示

### `:copy_choice_idx2label(choice_in_dix) -> list`

与上一方法正相反，参考之。无效的索引将被替换为空字符串。

### `:best_response(others_choices, [update]) -> Answer`

根据给出的其他参与者的选择，给出可行的最佳对策。需要注意的是该方法只是在进行缓存存取。如果从未使用[计算器](#calc)进行过计算，那么该方法将一直返回 `nil`。存入将使用到第二个参数，一般来说您不需要关心这些问题，因为即便是计算器也会自主检查缓存。所有下述的，带有 `update` 参数的方法都如此，不再赘述。

* `others_choices - list` 按照全局索引排列的博弈选择结果组合，计算目标的选择可置为零索引或者是负索引以标记计算目标的位置
* `update - Answer` 用以刷新缓存的值

### `:certain_payoff(choice, [update]) -> Answer`

根据给出的博弈选择结果组合，返回该局面下各方的回报。以各方全局索引排序。

* `choice - list` 按照全局索引排列的博弈选择结果组合
* `update - Answer` 用以刷新缓存的值

### `:<eq_nash|eq_quantal_response>([update]) -> Answer`

给出纳什/量子响应均衡。

* `update - Answer` 用以刷新缓存的值

<a id="csg-content"></a> 经典静态博弈
-----------------

> `require'tooru/gmod/csg‘` 非导出模块
> * tooru/gmod/csg.lua

经典静态博弈，即，Classic Static Game，即，CSG。所有博弈模型的基础。无特殊属性或方法。

重复博弈
-----------------

> `require'tooru/gmod/rpg‘` 非导出模块
> * tooru/gmod/rpg.lua

重复博弈，即，RePeat Game，即，RPG。

### `history - list`

重复博弈在进行过程中或结束之后留下的历史记录，按时间顺序排列。其中每一项包含以下几个部分:

* `choice - list` 每一个阶段的博弈结果
* `payoff  - list` 每一个阶段的回报结果

### `attr` 扩展

* `stop - number`
多阶段重复博弈所持续的时间/轮数/次数/阶段数。当值为一个整数时被认为是重复的次数；当值在 `0～1` 之间时被认为是折现因子

进化博弈
---------

> `require'tooru/gmod/evo’` 非导出模块
> * tooru/gmod/evo.lua

进化博弈，即，EVOlutionary game，即，EVO。

### `history` 扩展

* `distri - list` 群体中策略的分布状况统计，以策略全局索引排列。每一项都给出了选择该策略的个体数量
* `fit - list` 不同群体的 `fitness`，这里的定义不与进化理论中的定义一致，只是针对不同群体的回报统计。每一项给出了选择该策略之群体的回报总和。`0` 处写入全体回报的加权平均值

### `attr` 扩展

* `selection_intensity` 进化过程中的选择强度
* `mutations_intensity` 进化过程中的突变强度
* `simulation_population` 进化需要模拟时，模拟中的群体数量

### `:evo(when_stop，limit) -> int`

使用进化过程模型进行进化过程数据模拟。返回停止时的轮次。所有的模拟结果将被写入 `history` 中以供查询。若出现错误则返回 `nil` 与错误信息。**这一定是一次完整的模拟**，任何发现的未初始化/重置将导致错误。

* `when_stop - int` 指定当连续多少次博弈结束后群体分布无变化时结束模拟过程
* `limit - int` 指定模拟过程的持续上限

### `:evo_step() -> bool`

进行单步模拟，并返回一个标致指示本步中是否产生了群体变化。如果发生错误将返回 `nil`与错误信息。使用单步模拟持续分析时您**有必要注意博弈实例在期间不受其他修改**，否则模拟结果将不可预测。

博弈要素
======

> `require'tooru/game-element'` 非导出模块
> * game-element.lua

这些源代码实现了博弈要素的结构化定义，并且以函数的形式给出（工厂）。您通常**并不需要**调用这些函数来构造新的博弈要素。针对博弈的构建，请使用对应博弈的构造方法；针对博弈的修改，请使用对应博弈实例的修改接口。

### `Type(label, acts) - Type`

博弈中参与者的类型，这些类型决定了参与者的回报定义与行为空间。由于实现的考虑，回报被具体的关联到了博弈对象本身，而不是抽象到类型中。**这一点可能会在未来得到调整**。但是对于输入定义，回报依旧被关联到类型上。参见[博弈定义规范](Input-Game-Spec.zh.md)。

* `label - string` 该类型的标签/名字，该内容不会用于内部的计算与表示，它用于辅助使用者理解输出。下同
* `acts - list` 该类型所拥有的行为空间。这里请注意区分行为空间与策略空间

### `Player(label, type, payoff) -> Player`

博弈参与者，是参与到博弈当中的决策主体。

* `label - string` 该参与者的标签/名字/标记
* `type - Type` 该参与者的类型
* `payoff - function(choice)->number` 该参与者的回报计算。该方法被要求在任意合法的博弈局面下给出该参与者的回报

### `Action(label, [value]) -> Action`

博弈中的行为。行为特指一次/轮/静态博弈中参与者实施的具体行动/执行的决策结果。

* `label - string` 该行为的标签/名字
* `value - number` 当[数值计算开关](Input-Game-Spec.zh.md)被打开时，该参数是必须的；反之则是被忽略的。该项要求不会在此函数内触发检查。但在计算时可能会引起异常。该值被用于回报的具体计算

### `Strategy(label, reg, func) -> Strategy`

博弈中的策略。在静态博弈与进化博弈中，策略通常被等同于行为（这意味着您可能不太需要在这些博弈中使用策略这个对象）。而在其他博弈中，策略特指参与者在整个博弈过程中采取的行为选择方法。是每一轮/一次博弈中参与者挑选具体行为的唯一依据。

* `label - string` 该策略的名称

* `reg - table` 该策略中所需要的寄存器，注意程序不会特意检查您的策略定义中是否使用了这些寄存器，也不会检查您的策略定义中使用的寄存器是否得到了正确的定义申请。所以您有责任保证这些内容的正确性，尤其是当您在 lua 程序中自定义策略函数（参数 `func`）时，该函数**很有可能捕获到您所不希望它使用的上值**。当然如果您使用程序的其他接口，程序可以保证除寄存器定义与使用错误之外其它意外不会发生

* `func - function(common_knowledge, self)->string` 策略本身是一个可以不停地产生行为的状态机。在这里以函数形式表示，其接受多阶段博弈中被定义的共同知识（common knowledge）与自身的索引，返回一个行为的标签。在您使用程序的其他接口时，共同知识被定义为多阶段博弈历史记录与所有的博弈要素之集合。详见[博弈定义规范](Input-Game-Spec.zh.md)

### `Cache() -> Cache`

博弈结构中的缓存实例并不属于博弈的要素，这是程序内部实现的需要。由于其与博弈实例的密切结合，故将其定义在该模块中。它实现了博弈中所有需要求解与计算的项目之缓存功能。由于一些博弈分析计算的成本较高，故缓存计算结果成为了必要的工作。通常来说，您并不需要考虑缓存的使用，这项工作由 `solver` 模块配合 `game` 实例在内部实现。参见 `solver.lua`。

关于缓存
---

### `:checkin(path, content) -> nil`

根据给出的缓存路径向缓存中写入指定的内容。

* `path - list` 缓存路径。由于缓存在程序内部被设计为树形结构，故路径列表需要**倒序**指定从根节点出发后依次经过的中间节点。当然，列表中的第一个元素即是内容所存储的叶子节点的标记。不过在配合博弈接口使用时并不需要考虑这些细节，从博弈实例使用的角度来看，这些细节是透明的
* `content - any` 缓存写入内容，可以是任意的类型与值。该方法不会检查写入的表结构对缓存树的破坏（这是很有可能的），所以注意不要向中间节点写入数据，也不要扩展叶子节点。同样，在配合博弈接口使用时并不需要考虑这些细节，从博弈实例使用的角度来看，这些细节是透明的

### `checkout(path) -> any`

根据给出的缓存路径从缓存中读取内容。

* `path - list` 同上

<a id="text-process"></a> 文本处理
======

> `require'tooru'.reader`
> * tooru/init.lua
> * tooru/fp.lua

这些源代码实现了对于博弈相关的文本内容的处理与读写。它是一个函数集合，是一个功能模块。

### `.read_toml(toml_file) -> table`

```text
由于 `toml` 不支持非同质数组、版本变更不稳定、解释器陈旧等原因，该格式不再支持。使用该格式的输入可能会造成意外的结果。
```

从一个打开的输入文件中读取 `toml` 格式的博弈文本，在进行处理后转存为内部表示格式。通常都是一个 `lua table`。如果发生错误，将返回 `nil` 与错误信息。

* `toml_file - ifile` 文本输入的文件句柄，通常是一个文件系统中打开的文本文件或是 `stdin`

### `.read_yaml(yaml_file) -> table`

从一个打开的输入文件中读入 `yaml` 格式的博弈文本，在进行处理后转存为内部表示格式。通常都是一个 `lua table`。如果发生错误，将返回 `nil` 与错误信息。

* `yaml_file - ifile` 文本输入的文件句柄，通常是一个文件系统中打开的文本文件或是 `sdtin`

<a id="serialzors"></a>序列化
-----

> `require'tooru'.serialzors`
> * tooru/init.lua
> * tooru/fp.lua lua sub-mod fp.serializors

一个函数集合，用于以多种格式将博弈序列化。通常序列化的结果用以更加紧凑地存储博弈本身，有时也会被用于与外部组件交流。通常所有必要的序列化工作将在内部自动完成（存储在博弈实例的 `CONTENT` 只读字段中），您不需要手工调用这些函数。

### `.nfg_convertor(game) -> string` 

接受一个博弈（通常是静态博弈或重复博弈），将其以 _[Gambit/nfg](https://gambitproject.readthedocs.io/en/latest/formats.html#the-strategic-game-nfg-file-format-payoff-version)_ 格式进行序列化。

* `game - game` 序列化对象，一个 Gambit/nfg 兼容的博弈。当无法成功序列化时将返回空字符串，有时会打印警告提示失败原因。

<a id="calc"></a> 计算器
=====

> `require'tooru'.calculator`
> * tooru/init.lua
> * tooru/solver.lua

这些代码实现了需要的求解功能。这个模块常被看作是各式计算器的工厂，您可以通过求解类型与求解算法来指定您需要的计算器。

### `.new(render, type, name) -> Calculator`

新建一个计算器，通过提交参数来定制不同的计算器。

* `render - render` 计算结果的渲染器，现阶段只是一个输出文件句柄。**它应该被实现为一个渲染器，其中定义了渲染格式、输出方法以及渲染的结果之类型。此后该函数的 `type` 参数可以被取消**

* `type - string` 求解类型，如 `eq_nash` 等。**它应该由完全体的渲染器来取代**

* `name - string` 求解算法，现在可用的求解算法有：

  * <a id="gnm-alg"></a> `gnm` _[Gambit](https://gambitproject.readthedocs.io/en/latest/tools.html#gambit-gnm-compute-nash-equilibria-in-a-strategic-game-using-a-global-newton-method)_ 与 _[Gametracer](http://dags.stanford.edu/Games/README.txt)_ 使用，一种全局牛顿方法
    > Govindan, Srihari and Robert Wilson. (2003) “A Global Newton Method to Compute Nash Equilibria.” Journal of Economic Theory 110(1): 65-86.

计算器实例
--------

计算器实例主要被用于计算，顺带通过渲染器展示计算的结果。

### `:solve(game) -> Answer`

利用计算器本身持有的算法与渲染器来求解并展示博弈。当出现错误时返回 `nil` 与错误信息。这个求解器会自动检查博弈的缓存内容以避免重复计算。它也会自动写入／刷新缓存，因此您完全无需考虑博弈实例中缓存的操作细节。如果发生错误，将返回 `nil` 与错误信息。

* `game` 待求解的博弈实例

Gambit 绑定
==========

> McKelvey, Richard D., McLennan, Andrew M., and Turocy, Theodore L. (2016). Gambit: Software Tools for Game Theory, Version 16.0.1. http://www.gambit-project.org.

> `require'libtooru.gs'`
> * tooru/src/gs.cc
> * tooru/src/tooru.h lua C mod load function: luaopen_libtooru_gs
> * libtooru.so

_[Gambit](http://www.gambit-project.org/)_ 是一个较为成熟、全面的博弈论研究工具，由 `C++` 写成。我们为其项目编写了部分需要的 `Lua` 绑定。对应的 `Lua` 模块名称为 `ags` 代指 `Auto Gambit Solver`。这是一个功能模块，包含了所有需要的函数。

### `.gnm(game_content) -> string`

参见 _[gnm 算法](#gnm-alg)_。它会以文本形式返回计算的结果，通常被 _csv_ 格式化。

* `game_content - string` 博弈的文本形式，参见[博弈实例中的博弈内容](#game-content)
