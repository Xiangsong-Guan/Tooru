-- 2019.4.17
-- Project Tooru
-- Repeat game

local csg = require "tooru/gmod/csg"
local ge = require "tooru/game-element"
local xtable = require "std.table"

local _mod = {
  WHO = "Repeat Game",
  SERIALIZORS = {},
  TYPE = "rpg"
}

----------------------------------------------------------------- INIT function
local function init(game, ini)
  -- 策略初始化
  for i = 1, #ini.strategies, 3 do -- !?
    local sgy_label, upvalue_req, sgy_fun_src = ini.strategies[i], ini.strategies[i + 1], ini.strategies[i + 2]
    -- upvalue may need more necessary function such as 'math'
    local sgy_fun = load(sgy_fun_src, "strategy calc function code", "t", upvalue_req)
    table.insert(game.strategies, ge.Strategy(sgy_label, upvalue_req, sgy_fun))
    game.strategies_by_label[sgy_label] = #game.strategies
  end

  for i = 1, #game.players do
    game.player[i].strategy = game.strategies_by_label[ini.player_strategies[i]]
  end

  return game
end

------------------------------------------------ *** RPG Game instance (2/2) ***
local _ex = {payoff_for_player = nil, payoff_with_discount = nil}
------------------------------------------------ *** RPG Game instance (2/2) ***

function _ex:evaluate_history()
  if self.attr.stop < 0 then
    -- infinity limit calculation need help from julia
    error "cannot calculate payoff for infinity continue rpg"
  end

  local historys = {{}}
  local strategies = self.strategies
  local players = self.players

  for j, p in ipairs(players) do
    historys[1][j] = strategies[p.strategy].reg.INIT
  end

  for i = 2, self.attr.stop do
    local choice = {}
    for j, p in ipairs(players) do
      choice[j] = strategies[p.strategy].func(historys, j)
    end
    historys[i] = choice
  end

  self.historys = historys
end

function _ex:payoff_for_player(strategies, target)
  local tpayoff = {}
  local tidx = self.players_by_label[target] or target
  local tplayer = self.players[tidx]

  if self.attr.stop < 0 then
    -- infinity limit calculation need help from julia
    error "cannot calculate payoff for infinity continue rpg"
  end

  for i = 1, self.attr.stop do
    local choice = {}
    for j = 1, #strategies do
      choice[j] = strategies[j][i] or strategies[j][0](self.historys)
    end
    tpayoff[i] = tplayer.payoff(choice)
  end

  return tpayoff
end

function _ex:payoff_with_discount(payoffs)
  local dp = {}
  local df = self.attr.discount_factor
  for i, p in ipairs(payoffs) do
    dp[i] = (df ^ (i - 1)) * p
  end
  return dp
end

------------------------------------------------ MOD function - repeat-game obj.
function _mod.new(ini)
  --------------------------------------------- *** RPG Game instance (1/2) ***
  local good, msg = csg.new(ini)
  if not good then
    return nil, msg
  end
  good.strategies = {}
  good.strategies_by_label = {}
  good.historys = {}
  good.player_strategies = {}
  good.attr.stop = ini.stop or 0
  good.attr.discount_factor = ini.discount_factor or 1
  --------------------------------------------- *** RPG Game instance (1/2) ***
  xtable.merge(good, _ex)
  return init(good, ini)
end

return _mod
