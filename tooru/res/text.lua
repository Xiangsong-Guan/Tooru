-- 2019.4.17
-- Project Tooru
-- Load string file (lua)

local ok, text = pcall(dofile, "tooru/res/text." .. select(-1, ...) .. ".txt")
if not ok then
  _ENV.stderr:write("text res load warning; no " .. tostring(select(-1, ...)) .. " res and loading zh ver. res")
  text = dofile("tooru/res/text.zh.txt")
end

text.gs_version = "16.0.1"
text.gt_version = "0.2"

text.gs_gt_copyright =
  ("Gametracer %s %s, %s (C) 2002, Ben Blum and Christian Shelton"):format(
  text.version,
  text.gt_version,
  text.copyright
)
text.gs_copyright =
  ("Gambit %s %s, %s (C) 1994-2016, The Gambit Project"):format(text.version, text.gs_version, text.copyright)

text.banner = {}
text.banner.gnm =
  ("Gambit %s - gnm, %s.\n%s.\n%s.\n%s"):format(
  text.game_solve_tool,
  text.gnu_gpl,
  text.gs_gt_copyright,
  text.gs_copyright,
  text.gnne
)

return text
