-- 2019.4.8
-- Project Tooru
-- Toml, gambit file processor

local u = require "tooru/u"

-- This is some pass-in args for loaded source code
local src_sgy_prefix = "local HISTORY,SELF = ...;"
local src_pf_prefix = "local CHOICE,SELF = ...;"
-- This is Gambie NFG game used txt
local nfg_prologue = 'NFG 1 R "%s - %s"'
local nfg_begin = "{ "
local nfg_end = "}"

--------------------------------------------------------------------------- MOD
local _mod = {
  loaders = {
    toml =nil,
    yaml = nil,
    luaraw = nil
  },
  serializors = {}
}

do -- _mod init

local ok
ok, _mod.loaders.toml = pcall(require, "toml")
if not ok then
  warn '"toml" mod not found, toml support disable'
  _mod.loaders.toml = function() error('toml support disabled') end
else _mod.loaders.toml = _mod.loaders.toml.load end
ok, _mod.loaders.yaml = pcall(require, "lyaml")
if not ok then
  warn '"yaml" mod not found, yaml support disable'
  _mod.loaders.yaml = function() error('yaml support disabled') end
else _mod.loaders.yaml = _mod.loaders.yaml.load end
_mod.loaders.luaraw = function(content)
  local ret
  if type(content) ~= 'string' then error('invalid content to load') end
  local good, msg = load('return '..content, 'game definition', 't', {})
  if not good then error('invalid game define in luaraw: '..ret) end
  ok, ret = pcall(good)
  if not ok then error('invalid game define in luaraw: '..ret) end
  return ret
end

end -- _mod init


----------------------------------------------------------------- Class diff fun
-- 由于各个博弈类型之间有着树形的相互包含关系，故从根开始（pre_process），这些预处理函数最后会检查
-- 该配置是否满足自己的子类型。如果满足则进一步细化处理。
local function read_evo(game)
  local init_distri = u.split(game.init_distri)
  game.init_distri = {}
  for _, s in ipairs(init_distri) do
    local k, v = u.keypairs(s)
    assert((k and v) and type(v) == "number", "game input error: invalid evo init_distri")
    game.init_distri[k] = v
  end

  assert(game.game_type:lower() == "evo", 'game input error: this game should be "evo" but not ' .. game.game_type)
  return game
end

local function read_rep(game)
  for i = 2, #game.strategies, 3 do -- !?
    local reg_strs = u.split(game.strategies[i])
    game.strategies[i] = {}
    for _, s in ipairs(reg_strs) do
      local k, v = u.keypairs(s)
      assert((k and v) and k:match("^[%a_]+[%w_]*"), "game input error: invalid upvalue request")
      game.strategies[i][k] = v
    end

    game.strategies[i + 1] = src_sgy_prefix .. game.strategies[i + 1] -- !?
  end

  if game.init_distri then
    return read_evo(game)
  end
  assert(game.game_type:lower() == "rpg", 'game input error: this game should be "rpg" but not ' .. game.game_type)
  return game
end

local function pre_process(game)
  assert(game.types and game.action_sets and game.payoffs, "game input error: incompleted game define")

  assert(#game.types > 0, "game input error: invalid types define")
  for i, x in ipairs(game.types) do
    game.types[i] = u.split(x)
    assert(#game.types[i] == 4, "game input error: invalid types define") -- !?
  end
  assert(#game.action_sets > 0, "game input error: invalid actions define")
  for i, s in ipairs(game.action_sets) do
    game.action_sets[i] = u.split(s)
    assert(#game.action_sets[i] > 0, "game input error: invalid actions define")
  end
  assert(#game.payoffs > 0, "game input error: invalid payoffs define")
  for i, p in ipairs(game.payoffs) do
    if type(p) == "string" then
      game.payoffs[i] = src_pf_prefix .. p
    end
  end

  if game.strategies then -- 重复博弈富于心计，夏亚算计我
    return read_rep(game)
  end
  assert(game.game_type:lower() == "csg", 'game input error: this game should be "csg" but not ' .. game.game_type)
  return game
end

------------------------------------------------------------------ MOD function
-- Gen a game ini according to content and loader name
function _mod.read(content, ln)
  if type(_mod.loaders[ln:lower()]) == "function" then
    local ok, ret
    ok, ret = pcall(_mod.loaders[ln], content)
    if not ok then
      return nil, "content load error: bad format data, " .. ret:match(".-%:% ([^\n]+)")
    end
    ok, ret = pcall(pre_process, ret)
    if not ok then
      return nil, ret:match(".-%:% ([^\n]+)")
    end
    return ret
  else
    return nil, "content load error: no such loader " .. ln
  end
end

function _mod.serializors.nfg_convertor(game)
  if game.attr.game_type ~= "csg" and game.attr.game_type ~= "evo" and game.attr.game_type ~= "rpg" then
    return nil, ("game type incompatible error: this kind of tool request game type %q, but got %q, abandoned\n"):format(
      "csg/evo/rep",
      game.attr.game_type
    )
  end
  -- local nfg_file = io.open(game.attr.title .. nfg_ext, 'w')
  local nfg = {}
  -- nfg_file:write(
  --   nfg_prologue:format(game.attr.title, game.attr.comment),
  --   '\n',
  --   nfg_begin,
  --   ' '
  -- )
  table.insert(nfg, nfg_prologue:format(game.attr.title, game.attr.comment))
  table.insert(nfg, "\n")
  table.insert(nfg, nfg_begin)
  for _, player in ipairs(game.players) do
    -- nfg_file:write(('%q'):format(player.label))
    table.insert(nfg, ("%q "):format(player.label))
  end
  -- nfg_file:write(nfg_end, '\n')
  table.insert(nfg, nfg_end)
  table.insert(nfg, nfg_begin)
  for _, p in ipairs(game.players) do
    table.insert(nfg, #(game.types[p.type].actions))
    table.insert(nfg, " ")
  end
  table.insert(nfg, nfg_end)
  table.insert(nfg, "\n")
  -- nfg_file:write(table.concat(game.PAYOFF_MTX, ' '), '\n')
  table.insert(nfg, table.concat(game.PAYOFF_MTX, " "))
  -- nfg_file:close()
  return table.concat(nfg)
end

return _mod
