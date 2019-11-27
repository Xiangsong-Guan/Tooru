-- 2019.5.17
-- Project Tooru
-- game dispatcher

local _mod = {}

function _mod.new(ini)
  if type(ini) ~= "table" then
    return nil, "input error: non-table input for initialize a game"
  end
  if type(ini.game_type) ~= "string" then
    return nil, "input error: invalid game type"
  end
  local ok, game_mod = pcall(require, "tooru/gmod/" .. ini.game_type)
  if not ok then
    return nil, "game mod loading error: no mod for game type " .. ini.game_type
  end

  local game, msg = game_mod.new(ini)
  if not game then
    return nil, msg
  end
  if #game_mod.SERIALIZORS > 0 then
    game.CONTENT = require "tooru/fp".serializors[game_mod.SERIALIZORS[1]](game)
    assert(
      game.CONTENT,
      ("game content serialize failed; game type: %s; game mod: %s"):format(ini.game_type, game_mod.WHO)
    )
  end
  game.attr.type_name = game_mod.WHO
  return game
end

return _mod
