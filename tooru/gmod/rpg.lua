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
    local good, msg = load(sgy_fun_src, "calc function for strategy "..sgy_label, "t", upvalue_req)
    if not good then warn('game define error: invalid strtegies, ', msg); return nil end
    table.insert(game.strategies, ge.Strategy(sgy_label, upvalue_req, good))
    game.strategies_by_label[sgy_label] = #game.strategies
  end

  -- sometimes rep game player not follow certain strategy
  if #ini.strategies == 0 then return game end
  if #ini.player_strategies ~= #game.players then warn 'game define error: player amount not equ with their strategies amount'; return nil end
  game.historys[1] = {}
  for i, p in ipairs(game.players) do
    p.strategy = game.strategies_by_label[ini.player_strategies[i]]
    game.historys[1][i] = game.strategies[p.strategy].reg.INIT
  end

  return game
end

------------------------------------------------ *** RPG Game instance (2/2) ***
local _ex = {payoff_for_player = nil, payoff_with_discount = nil}
------------------------------------------------ *** RPG Game instance (2/2) ***

function _ex:evaluate_history()
  if self.attr.stop < 1 then
    -- infinity limit calculation need help from julia
    warn "cannot calculate payoff for infinity continue rpg"
    return false
  end

  local historys = {{}}
  local strategies = self.strategies
  local players = self.players

  for j, p in ipairs(players) do
    -- what does a plyaer choose to perform in first turn must be apart of
    -- the strategy
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
  return true
end

function _ex:payoff_for_player(strategies, target)
  if self.attr.stop < 1 then
    -- infinity limit calculation need help from julia
    warn "cannot calculate payoff for infinity continue rpg"
    return nil
  end

  local tpayoff = {}
  local tidx = self.players_by_label[target] or target
  local tplayer = self.players[tidx]

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
  if not df then
    warn 'rpg payoff with discount warning: no discount factor defined'
    return nil
  end
  for i, p in ipairs(payoffs) do
    dp[i] = (df ^ (i - 1)) * p
  end
  return dp
end

------------------------------------------------ MOD function - repeat-game obj.
function _mod.new(ini)
  --------------------------------------------- *** RPG Game instance (1/2) ***
  local good = csg.new(ini)
  if not good then return nil end
  good.strategies = {}
  good.strategies_by_label = {}
  good.historys = {}
  good.player_strategies = {}
  good.attr.stop = tonumber(ini.stop) or 0
  good.attr.discount_factor = tonumber(ini.discount_factor) or 1
  --------------------------------------------- *** RPG Game instance (1/2) ***
  xtable.merge(good, _ex)
  return init(good, ini)
end

return _mod
