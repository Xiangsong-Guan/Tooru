```text
Non-export modules do not support manual import, which may cause some necessary initialization work to be skipped.
```
```text
The index of all participants and behaviors (or strategies) is counted from the beginning. Their numbers are based on the order in which they appear in the input game definition text segment. These indexes are referred to herein as global indexes; in contrast, local indexes are indexes of the behaviors of specific participants themselves in the computing environment, and are also defined in order of appearance. When the behavior space of a certain type of participant is equal to the behavior space of the game as a whole, the two are the same; otherwise, the behavior space indexed by the local index must be a subset of the global index space.Local indexes are often used inside the program because it is easy to calculate the return; For input, using labels may be more intuitive. The global index provides a link to the "index-tag" transformation.
```
```text
In the case of non-special descriptions, the game elements mentioned in all methods and functions are referred to by their indexes, which is consistent with the internal implementation of the program. Please use the "tag-index" conversion method provided in the game instance to convert each other.
```

<a id="csg"></a> Game Model
==========

> `require'tooru'.game`
> * tooru/init.lua
> * tooru/game.lua
> * tooru/gmod
> * csg.lua Classic static game
> * evo.lua evolutionary game
> * rpg.lua repeated game

These source code implements the expression of common game models in memory. These source code make up a `lua` module. This module is used as a factory for making game instances. You can initialize it with a piece of game text that is read and organized by the program, such as the `yaml` format. This work is usually done with a text processing module, see [Text Processing](#text-process).

### `.new(formated_game_table) -> Game`

Create a new game instance. This game instance can be modified. All modifications can also be stored in the file system and loaded again later. `nil` and error message will be returned when an error occurs.

* `formated_game_table - table` is read by the program from the formatted game text segment and organized by the game content. It is usually loaded by other programs, or you can write it by hand. See [Text Processing](#text-process)

Game Instance
--------

This section describes the common fields and methods of all types of game instances.

### `PAYOFF_MTX - list`

Read-only field, the global return matrix of the game. In a game where the return of the random game will change, the field may be modified internally.

### `RAW - table`

A read-only field that retains the original input used to initialize the game instance, ie `formated_game_table`.

### <a id="game-content"></a> `CONTENT - string`

Read-only field, serialized game instance. Usually produced by [serializers](serialzors).

### `attr - table`

The usual attributes of the game. The detailed definition and value space of these attributes (including the extended part of the following text) can be found in [Game Definition Specification](Input-Game-Spec.en.md). It contains the following:

* `title - string` The title of the game
* `comment - string` for additional instructions on the game
* `value_switch - int` Whether the game starts numerical calculation, zero is no
* `game_type - string` The type of game, such as `csg/rpg/evo...`

### `:copy_choice_label2idx(choice_in_labels) -> list`

The combination of the game selection results represented by the labels is transformed into a combination represented by the index of the behavior, which is a global index. Invalid tags will be replaced with invalid indexes (less than `1`).

* `choice_in_labels - list` Game selection result combination, arranged by participant's index. Its behavioral choice is represented by the label of the behavior

### `:copy_choice_idx2label(choice_in_dix) -> list`

Contrary to the previous method, refer to it. Invalid indexes will be replaced with empty strings.

### `:best_response(others_choices, [update]) -> Answer`

Based on the choices given by other participants, the best possible countermeasures are given. It should be noted that this method is only for cache access. If you have never used [calculator](#calc) for calculations, then this method will always return `nil`. Depositing will use the second parameter, generally you don't need to care about these issues, because even the calculator will check the cache autonomously. All of the following methods with the `update` parameter are the same and will not be described again.

* `others_choices - list` According to the game selection result combination arranged by the global index, the calculation target selection can be set to zero index or negative index to mark the position of the calculation target
* `update - Answer` to refresh the cached value

### `:certain_payoff(choice, [update]) -> Answer`

According to the given game selection result combination, return the returns of the parties under the situation. Sort by global index of each party.

* `choice - list` Game selection result combination arranged by global index
* `update - Answer` to refresh the cached value

### `:<eq_nash|eq_quantal_response>([update]) -> Answer`

Give Nash/quantum response equalization.

* `update - Answer` to refresh the cached value

<a id="csg-content"></a> Classic Static Game
-----------------

> `require'tooru/gmod/csg’` non-export module
> * tooru/gmod/csg.lua

Classic static game, ie, Classic Static Game, ie, CSG. The basis of all game models. No special attributes or methods.

Repeated Game
-----------------

> `require'tooru/gmod/rpg‘` non-export module
> * tooru/gmod/rpg.lua

Repeat the game, ie, RePeat Game, ie, RPG.

### `history - list`

The history of the repeated game that is left in or after the process, in chronological order. Each of these items contains the following sections:

* `choice - list` Game results for each stage
* `payoff - list` return results for each stage

### `attr` extension

* `stop - number`
The time/round/number/stage number of the multi-stage repeated game. The value is considered to be the number of repetitions when the value is an integer; it is considered to be the discount factor when the value is between `0 and 1`

Evolutionary Game
---------

> `require'tooru/gmod/evo’` non-export module
> * tooru/gmod/evo.lua

Evolutionary game, ie, EVOlutionary game, ie, EVO.

### `history` extension

* `distri - list` The distribution statistics of the policies in the group, arranged by the policy global index. Each item gives the number of individuals who choose this strategy
* `fit - list` The `fitness` of different groups, the definition here is not consistent with the definition in evolutionary theory, but the return statistics for different groups. Each item gives the sum of the returns of the group that selected the strategy. Write a weighted average of the total return at `0`

### `attr` extension

* `selection_intensity` selection strength during evolution
* `mutations_intensity` mutation strength during evolution
* `simulation_population` When the evolution requires simulation, the number of groups in the simulation

### `:evo(when_stop,limit) -> int`

Evolutionary process models were used to simulate evolutionary process data. Returns the round when stopped. All simulation results will be written to `history` for query. Returns `nil` and an error message if an error occurs. **This must be a full simulation**, any uninitialization/reset found will result in an error.

* `when_stop - int` specifies the end of the simulation process when there are no changes in the population distribution after the end of the game
* `limit - int` specifies the upper limit of the simulation process

### `:evo_step() -> bool`

Perform a single-step simulation and return a Peugeot to indicate if a group change has occurred in this step. If an error occurs, it will return `nil` with the error message. When using single-step simulation continuous analysis, it is necessary for you to note that **the game instance is not subject to other modifications during the period**, otherwise the simulation results will be unpredictable.

Game Element
======

> `require'tooru/game-element'` non-export module
> * game-element.lua

These source code implements a structured definition of the game elements and is given as a function (factory). You usually don't need to call these functions to construct new game elements. For the construction of the game, please use the construction method of the corresponding game; for the modification of the game, please use the modified interface of the corresponding game instance.

### `Type(label, acts) - Type`

The types of participants in the game, which determine the participant's return definition and behavioral space. Due to implementation considerations, the return is specifically linked to the game object itself, rather than abstracted into the type. **This may be adjusted in the future**. But for input definitions, returns are still associated with the type. See [Game Definition Specification](Input-Game-Spec.en.md).

* `label - string` This type of tag/name, which is not used for internal calculations and representations, it is used to assist the user in understanding the output. The same below
* `acts - list` The behavior space owned by this type. Please pay attention here to distinguish between behavior space and strategy space

### `Player(label, type, payoff) -> Player`

Game participants are the decision-making subjects involved in the game.

* `label - string` The participant's tag/name/tag
* `type - Type` the type of the participant
* `payoff - function(choice)->number` The participant's return calculation. The method is required to give the participant's return under any legal game situation.

### `Action(label, [value]) -> Action`

Behavior in the game. Behavior refers specifically to the outcome of specific actions/executives implemented by participants in a one-round/round/static game.

* `label - string` the tag/name of the action
* `value - number` This parameter is required when [Numerical Calculation Switch](Input-Game-Spec.en.md) is turned on; otherwise it is ignored. This requirement does not trigger a check within this function. However, it may cause an abnormality in the calculation. This value is used for the specific calculation of the return

### `Strategy(label, reg, func) -> Strategy`

The strategy in the game. In static games and evolutionary games, strategies are usually equated with behavior (which means you may not need to use the strategy in these games). In other games, the strategy specifically refers to the behavior selection method that the participants take during the whole game. It is the only basis for participants to select specific behaviors in each round/one game.

* `label - string` the name of the policy

* `reg - table` The registers required in this strategy, note that the program does not specifically check whether these registers are used in your policy definition, nor does it check if the registers used in your policy definition are correctly defined. So it is your responsibility to ensure that the content is correct, especially when you customize the strategy function (parameter `func`) in the lua program, it is **very likely to capture the upper value you do not want it to use**. Of course, if you use other interfaces of the program, the program can guarantee that accidents will not occur except for register definition and usage errors

* `func - function(common_knowledge, self)->string` The policy itself is a state machine that can continuously generate behavior. It is represented here as a function that accepts the common knowledge defined in the multi-stage game and its own index, returning a label of the behavior. When you use other interfaces of the program, common knowledge is defined as a multi-stage game history and a collection of all game elements. See [Game Definition Specification](Input-Game-Spec.en.md) for details

### `Cache() -> Cache`

The cache instance in the game structure is not an element of the game, which is the need for internal implementation of the program. Because of its close integration with the game instance, it is defined in this module. It implements the caching function of all the items in the game that need to be solved and calculated. Because of the high cost of some game analysis calculations, the cache calculation results become a necessary task. In general, you don't need to consider the use of caching. This is done internally by the `solver` module in conjunction with the `game` instance. See `solver.lua`.

About Caching
---

### `:checkin(path, content) -> nil`

Writes the specified content to the cache based on the given cache path.

* `path - list` cache path. Since the cache is designed as a tree structure inside the program, the path list needs to be **reversed** to specify the intermediate nodes that pass through the root node in order. Of course, the first element in the list is the tag of the leaf node where the content is stored. However, these details need not be considered when used in conjunction with the game interface. From the perspective of the use of the game instance, these details are transparent
* `content - any` caches the contents of the write, which can be any type and value. This method does not check the destruction of the cache tree by the written table structure (this is very likely), so be careful not to write data to the intermediate node, nor to extend the leaf nodes. Again, these details need not be considered when used in conjunction with the game interface. From the perspective of the use of the game instance, these details are transparent

### `Cache:checkout(path) -> any`

Reads content from the cache based on the given cache path.

* `path - list` Same as above

<a id="text-process"></a> Text Processing
======

> `require'tooru'.reader`
> * tooru/init.lua
> * tooru/fp.lua

These source code implements the processing and reading and writing of game-related text content. It is a collection of functions and is a functional module.

### `.read_toml(toml_file) -> table`

```text
This format is no longer supported because `toml` does not support non-homogeneous arrays, unstable version changes, outdated interpreters, and so on. Using input in this format can cause unexpected results.
```

The game text in the `toml` format is read from an open input file and dumped to the internal representation format after processing. Usually a `lua table`. If an error occurs, `nil` and the error message will be returned.

* `toml_file - ifile` text input file handle, usually a text file opened in the file system or `stdin`

### `.read_yaml(yaml_file) -> table`

The game text in the `yaml` format is read from an open input file and transferred to the internal representation format after processing. Usually a `lua table`. If an error occurs, `nil` and the error message will be returned.

* `yaml_file - ifile` text input file handle, usually a text file opened in the file system or `sdtin`

<a id="serialzors"></a> Serialization
-----

> `require'tooru'.serialzors`
> * tooru/init.lua
> * tooru/fp.lua lua sub-mod fp.serializors

A collection of functions for serializing games in multiple formats. The result of serialization is usually used to store the game itself more compactly and sometimes used to communicate with external components. Usually all necessary serialization work will be done internally (stored in the `CONTENT` read-only field of the game instance), you don't need to call these functions manually.

### `.nfg_convertor(game) -> string`

Accept a game (usually a static game or a repeat game) and use _[Gambit/nfg](https://gambitproject.readthedocs.io/en/latest/formats.html#the-strategic-game-nfg-file-format-payoff-version)_ format is serialized.

* `game - game` Serialized object, a Gambit/nfg compatible game. An empty string is returned when serialization cannot be successful, and sometimes the warning prompts the reason for the failure.

<a id="calc"></a> Calculator
=====

> `require'tooru'.calculator`
> * tooru/init.lua
> * tooru/solver.lua

These codes implement the required solution functions. This module is often seen as a factory for all kinds of calculators. You can specify the calculator you need by solving the type and solving algorithm.

### `.new(render, type, name) -> Calculator`

Create a new calculator and customize the different calculators by submitting parameters.

* `render - render` The renderer that evaluates the result, which is just an output file handle at this stage. **It should be implemented as a renderer that defines the rendering format, the output method, and the type of the rendered result. The `type` parameter of the function can then be canceled**

* `type - string` Solve type, such as `eq_nash`. **It should be replaced by a full body renderer**

* `name - string` solving algorithm, the available solving algorithms are:

  * <a id="gnm-alg"></a> `gnm` used by _[Gambit](https://gambitproject.readthedocs.io/en/latest/tools.html#gambit-gnm-compute-nash-equilibria-In-a-strategic-game-using-a-global-newton-method)_ and _[Gametracer](http://dags.stanford.edu/Games/README.txt)_, a global Newton method
    > Govindan, Srihari and Robert Wilson. (2003) “A Global Newton Method to Compute Nash Equilibria.” Journal of Economic Theory 110(1): 65-86.

Calculator Instance
--------

The calculator instance is primarily used for calculations, along with the renderer to present the results of the calculation.

### `:solve(game) -> Answer`

Use the algorithm and renderer held by the calculator to solve and display the game. Returns `nil` with an error message when an error occurs. This solver automatically checks the cached content of the game to avoid double counting. It also automatically writes/refreshes the cache, so you don't have to worry about the details of the operations cached in the game instance. If an error occurs, `nil` and the error message will be returned.

* `game` Game instance to be solved

Gambit Binding
==========

> `require'libtooru.gs'`
> * tooru/src/gs.cc
> * tooru/src/tooru.h lua C mod load function: luaopen_libtooru_gs
> * libtooru.so

> McKelvey, Richard D., McLennan, Andrew M., and Turocy, Theodore L. (2016). Gambit: Software Tools for Game Theory, Version 16.0.1. http://www.gambit-project.org.

_[Gambit](http://www.gambit-project.org/)_ is a relatively mature and comprehensive game theory research tool written in `C++`. We have written some of the required `Lua` bindings for our project. The corresponding `Lua` module name is `ags` and refers to `Auto Gambit Solver`. This is a functional module that contains all the functions needed.

### `.gnm(game_content) -> string`

See _[gnm algorithm](#gnm-alg)_. It returns the result of the calculation as text, usually formatted by _csv_.

* `game_content - string` The text form of the game, see [game content in the game instance](#game-content)