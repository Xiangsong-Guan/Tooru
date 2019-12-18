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
  for _, s in ipairs(ini.strategies) do
    -- upvalue may need more necessary function such as 'math'
    local good, msg = load(s.sgy_fun_src, "calc function for strategy "..s.sgy_label, "t", s.upvalue_req)
    if not good then
      warn('game define error: invalid strtegies "', tostring(s.sgy_label), '": ', msg)
      return nil
    end
    table.insert(game.strategies, ge.Strategy(s.sgy_label, s.upvalue_req, good))
    game.strategies_by_label[s.sgy_label] = #game.strategies
  end

  -- NO NEED FOR THIS
  -- sometimes rep game player not follow certain strategy
  -- if #ini.strategies == 0 and #ini.player_strategies == 0 then return game end
  -- if #ini.player_strategies ~= #game.players then
  --   warn 'game define error: player amount not equ with their strategies amount'
  --   return nil
  -- end
  -- game.historys[0] = {}
  -- for i, p in ipairs(game.players) do
  --   p.strategy = game.strategies_by_label[ini.player_strategies[i]]
  --   if not p.strategy then
  --     warn('no strategy "', tostring(ini.player_strategies[i]), '" for player #"', tostring(i), '"')
  --     return nil
  --   end
  --   game.historys[0][i] = game.strategies[p.strategy].reg.INIT
  -- end

  return game
end

------------------------------------------------ *** RPG Game instance (2/2) ***
local _ex = {evaluate_history = nil; payoff_for_player = nil, payoff_with_discount = nil}
------------------------------------------------ *** RPG Game instance (2/2) ***

function _ex:evaluate_history(choices)
  if self.attr.stop < 1 then
    -- infinity limit calculation need help from julia
    warn "cannot calculate payoff for infinity continue rpg"
    return false
  end

  local historys = {{}}
  local strategies = self.strategies

  if #strategies < 1 then
    warn 'this game is not for strategy research'
    return false
  end

  for pi, si in ipairs(choices) do
    -- what does a plyaer choose to perform in first turn must be apart of
    -- the strategy
    historys[1][pi] = strategies[si].reg.INIT
  end

  for i = 2, self.attr.stop do
    local outcome = {}
    for pi, si in ipairs(choices) do
      local ok
      ok, outcome[pi] = pcall(strategies[si].func, historys, pi)
      if not ok then
        warn('error when computing strategy ', strategies[si].label, ': ', outcome[pi])
        return false
      end
    end
    historys[i] = outcome
  end

  self.historys = historys
  return true
end

function _ex:payoff_for_player(target)
  local tpayoff = {}
  local tplayer = self.players[target]

  for i = 1, #self.historys do
    local ok
    ok, tpayoff[i] = pcall(tplayer.payoff, self.historys[i])
    if not ok then
      warn('error when computing player ', tplayer.label, "'s payoff: ", tplayer[i])
      return nil
    end
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
