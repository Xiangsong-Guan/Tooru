This article describes the input specifications when using a program. The input body of the program is a textual, formatted, and human readable and writable game definition. The parameters of the program are beyond the scope of this article. For related content, please refer to the program help.

The definition of the input game is based on some of the popular data description formats, and the specifications of these formats will not be described in this article. The currently supported formats are:

* `toml` Only classic static games have been tested, other types of games are not recommended
* `yaml` The most common format, all game types have been tested

Next, this article will start from the most basic game, explain the data setting specifications and precautions by type.

Classical Static Game
===================

The classical static game is the basis of all games. In this part, we will describe the basic content of all games.

Title
-----

An optional field, the keyword is `title`, and the value type is `string`.

As the name implies, it is the title of a game. This field does not affect internal analysis calculations, it is only used to help the user understand the output.

Comments
--------

An optional field, the keyword is `comment`, and the value type is `string`.

As the name suggests, it is a further description of a game, documents, and projects. This field does not affect internal analysis calculations, it is only used to help the user understand the output.

Game Type
--------

A required field. The keyword is `game_type`, and the value type is `string`.

As the name implies, it is the type of the game. The types of games currently supported by the program are:
  * Classic static game (represented with `csg`)
  * Repeat game (represented with `rgp`)
  * Evolutionary game (represented with `evo`)
  * Random game () incomplete analysis calculation support
  * Classic dynamic Game ()
  * Bayesian game ()

Payoff
--------

A required field, the keyword is `payoffs`, the value type is `list`, and the list element value type is `string` or `matrix` represented by an array.

An list determines that you can define multiple payoffs and associate them to different participant types. _The `toml` specification does not support non-homogeneous lists_.

The payoff of a string definition means that this is a utility function for a particular participant. This string must be a valid `lua` expression (algorithm) because it will eventually be compiled into an executable code segment. In the classic static game, you can use `CHOICE[x]` to represent the decision/action of the `x` participants; you can use `SELF` to represent the index of the payoff calculation object itself. All other information, internal/external modules, are not available in this calculation. If you need more complex utility functions, use the `lua` interface. Also note that **the default value for your use is read-only and the program will not notice the legitimacy of the algorithm until it is executed**.

The payoff of the matrix definition means that this is a payoff matrix. **If you provide a (initial) global payoff matrix, be sure to place it first in the payoff list**. Of course, you can also provide a payoff matrix for a certain type of participant. Payoff values are sorted according to the choice of the game.

Numerical Switch
--------

A required field, the keyword is `value_switch`, and the value type is `int`.

The switch is off when the field value is `0`; otherwise the switch is on. This switch affects the value type in the behavior space definition: switch opening is the behavior space defined by a numerical value, and the value in the match definition will participate in the calculation of the payoff. However, when there is a global reward matrix, the payoff calculation will be based on the global reward matrix until the payoff definition is modified at runtime, and the payoff will be recalculated; otherwise the behavior space is defined by the label, which is only the behavior of the label, the payoff must be Given by the reward matrix.

Action
--------

A required field, the keyword is `action_sets`, the value type is `list`, the list element value type is `array`, and the list elements' value type is `string` or `real number`, depending on the value switch.

Nested list represents a collection of actions that are used to define different participant types.

Type & Player
--------

A required field, the keyword is `types`, and the value type is `list` (`toml` is a `string` separated by a blank character).

It has a specific protocol: a type is represented by four consecutive elements, followed by a label (`string`), the number of participants of that type (`int`), a actional space index (`int`), a payoff index (`int`).

Repeat Game
==========

Repeat game is extention for CSG in some meanings. This part only describe extended fields.

Repeat Times
-------------

The keyword is `stop`, its value type is `int` or `float`.

Repeat game will has a termination which is the `int` value, or without termination when value is `0`.

A `float` value stand for a discount factor. This factor has some different kinds of explainations. All in all, actually this value will just be treated as probility about the game will continue after a particular turn.

Strategy
--------

The keyword is `strategies`, its value type is `list`. Elements in the list are vary.

It has a specific protocl: a strategy is represented by three consecutive elements. In orders, a label (`string`), a reg key-value pairs list splited by white space (`string`), and a stretegy code snap (`string`).

Each key-value pairs in reg list (`<hot>=<dog>`). `<hot>` replaced by the reg's name. This name only constructed with `[a-z]`, `[A-Z]`, `[0-1]`, `_`, and should not be start with `[0-1]` or `_`. `<dog>` is replaced by reg's initial value. This value can contain every char **excpet white space chars**. If value can be parse as a number, it is a number; or it is a string. It is noted that char `'` and `"` should not be used for surrond string, it will be parsed to a part of string.

Code snap is `lua` src code. It must be valid `lua` src code. Only syntex error can be detected. Runtime error will be captured when running and lead to program error. This code snap only has limited global var: var defined in reg list, game instance, player's global index, and lua math lib. Game instance content refer to [linterface](linterface.en.md).

Strategy controls player's action selection in the whole process of repeat game.

Evolutionary Game
=================

Evolutionary game is a extention for repeat game, but it will discard `strategies` field.

Selection Intensity
--------

The keyword is `selection_intensity` its value type is `real number >= 0`.

Selection intensity will affect nature selection intensity. Larger value means low payoff group die out faster and more likely happenning.

Mutations Intensity
-------------------

The keyword is `mutations_intensity`, its value type is `proportion`.

Mutations intensity will affect mutation intensity. Larger value means that mutation will be more likely happenning.

Initial Distribution
----------

The keyword is `init_distri`, its value type is `list`, element value type is `real number`.

When element contains decimal point, it stands for the group population proportion in the whole population; Or it is a `int`, stands for the group population number.

Simulation Population
---------------------

The keyword is `simulation_population`, its value type is `int >= 0`.

As name specialfies. `0` means infinity.
