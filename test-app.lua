-- 2019.4.8
-- 2019.5.9 Reconstruct
-- Project Tooru
-- Test

-------------------------------------------------------------------- Initialize
io.write 'Project Tooru APP Test\n\n'
io.write '* Initialize...'

local testl = io.open('_lost/app-test.log', 'w')
local function prt(...)
  local good, msg = io.write(...)
  if good then
    io.flush()
  end
  return good, msg
end
local function log(...)
  return testl:write(...)
end
local function beauty(busu, prefix)
  local bijin = prefix .. busu:gsub('\n', '\n' .. prefix)
  if bijin:sub(-(#prefix)) == prefix then
    return bijin:sub(1, -(#prefix + 1))
  else
    return bijin .. '\n'
  end
end
local done = ' Done\n'

local args,
  good,
  msg,
  csg_content,
  csgg,
  evo_content,
  evog,
  rpg_content,
  rpgg,
  gnm_sl,
  render,
  ret

local USAGE =
  [[
Project Tooru, we make some calculation for world.
  -s,--save  Do not clear internal used tmp files, such as .nfg game file.
  -c,--cache (default 'game-cache') The dir hold all internal-used tmp file.
  -l,--lang  (default 'zh') The lang.
  <toml>     (default stdin) The game file in .toml format.
]]
args = require 'pl.lapp'(USAGE)
_G.args = args

-- When we use lu.prettystr, gambit gnm solver felt. That's a wired bug.
-- Not even call the lu.prettystr function, just require lu leads to bug.
-- For now we do not confirm this bug on others gambit solvers.
-- local pp = require 'luaunit'.prettystr
local pp = require 'pl.pretty'
local tooru = require 'tooru'

prt(done)
prt(beauty(USAGE, '| '))
prt('* Test log in "_lost/app-test.log"\n')
log('Project Tooru APP Test Resault Log\n\n')
log('* ARGS Dump:\n', pp.write(args), '\n')
prt('* ARGS Dump:\n', beauty(pp.write(args), '| '))

--------------------------------------------------------------------- CSG Test
prt '* Loading CSG game...'
csg_content, msg = tooru.reader.read(args.toml:read('a'), 'toml')
assert(csg_content, msg)
csgg, msg = tooru.game.new(csg_content)
assert(csgg, msg)
prt(done)
log('\n* CSG Game Dump:\n', pp.write(csgg), '\n')

--------------------------------------------------------------------- CSG Calc
do
  prt '* Initializing nash equilibrium render...'
  local render1, render2
  render1, msg = tooru.render.new('outcome', 'human_read', testl)
  assert(render1, msg)
  render2, msg = tooru.render.new('outcome', 'raw', testl)
  assert(render2, msg)
  prt(done)
  prt '* Solving Nash Eq for CSG game with gnm...'
  gnm_sl, msg = tooru.calculator.new('gnm', {render1, render2})
  assert(gnm_sl, msg)
  ret, msg = gnm_sl:solve(csgg)
  assert(ret, msg)
  log '\n* Solving ans:\n'
  ret, msg = render1:flush()
  assert(ret, msg)
  ret, msg = render2:flush()
  assert(ret, msg)
  prt(done)
end
-- prt '* Checking game cache...'
-- assert(
--   ret == csgg:nash_equilibrium(),
--   'csg game cache wrong, ret: ',
--   tostring(ret),
--   ' cache: ',
--   tostring(csgg:nash_equilibrium())
-- )
-- prt(done)

------------------------------------------------------------------- Repeat Test
prt '* Loading RPG game...'
rpg_content, msg =
  tooru.reader.read(io.open('test/rpg-in.yaml'):read('a'), 'yaml')
assert(rpg_content, msg)
rpgg, msg = tooru.game.new(rpg_content)
assert(rpgg, msg)
prt(done)
log('\n* RPG Game Dump:\n', pp.write(rpgg), '\n')

---------------------------------------------------------------------- Evo Test
prt '* Loading EVO game...'
evo_content, msg =
  tooru.reader.read(io.open('test/e-ev-in.yaml'):read('a'), 'yaml')
assert(evo_content, msg)
evog, msg = tooru.game.new(evo_content)
assert(evog, msg)
prt(done)
log('\n* EVO Game Dump:\n', pp.write(evog), '\n')
log '\n* EVO C Historys Dump:\n'
log 'choice:\n'
for i = 1, evog.attr.simulation_population do
  log(evog.historys:req(0, 'c', i), ', ')
end
log '\ndistri:\n'
for i = 1, #evog.actions do
  log(evog.historys:req(0, 'd', i), ', ')
end
log '\nfit:\n'
for i = 1, #evog.actions do
  log(evog.historys:req(0, 'f', i), ', ')
end
log(evog.historys:req(0, 'f', 'avg'))
log '\npayoff:\n'
for i = 1, evog.attr.simulation_population do
  log(evog.historys:req(0, 'p', i), ', ')
end

prt '* Make 10 evosim steps...\n'
log '\n* Evo Sim a step chance dump:\n'
for _ = 1, 10 do
  local changed, chance = evog:evo_step()
  if changed then
    prt(beauty('changed one is player #' .. changed, '| '))
    log(pp.write(chance, ''), '\n')
  else
    prt(beauty('no changed', '| '))
  end
end
prt('* ...' .. done)

--------------------------------------------------------------- evo render test
prt '* Initializing evo render...'
render, msg = tooru.render.new('evo_historys', 'plt', testl, true, 6, true)
assert(render, msg)
prt(done)
prt '* Make a complete evosim...'
evog:reset()
good, msg = evog:evo(10, 100, render)
assert(good == #evog.historys, msg)
prt(done)
prt '* Reset evo history and plot...'
evog:reset()
render.attr.is_ins = false
good, msg = evog:quick_evo(30, 1000, render)
assert(good == #evog.historys, msg)
good, msg =
  render:plot(
  '_lost/evosim data.dat',
  '_lost/evosim plot.plt',
  '_lost/evo fit.svg',
  {
    'fit-swim',
    'fit-fire',
    'fit-shoot',
    'fit-avg'
  }
)
assert(good, msg)
good, msg =
  render:plot(
  '_lost/evosim data.dat',
  '_lost/evosim plot.plt',
  '_lost/evo dis.svg',
  {
    'distribution-swim',
    'distribution-fire',
    'distribution-shoot'
  }
)
assert(good, msg)
prt(done)

prt '* Testing "is_nash" function...'
local isnash_s = tooru.calculator.quick_simple_naive_new('is_nash')
assert(isnash_s:solve(evog, {3, 3}), 'is_nash function error')
assert(
  isnash_s:solve(evog, {{.5, .0, .5}, {.5, .0, .5}}),
  'is_nash function error'
)
prt(done)

prt '* Testing "br" function...'
good, msg = tooru.render.new('strategy', 'human_read', testl)
assert(good, msg)
good, msg = tooru.calculator.new('best_response', good)
assert(good, msg)
log '\n* BR Function Ret:\n'
good, msg = good:solve(evog, {{.5, .0, .5}, {.0, .0, .0}}, 2)
assert(good, msg)
prt(done)

prt('\nAll test done. Good Job!\nProject Tooru :)\n')
log('\nAll test done. Good Job!\nProject Tooru :)\n')
testl:close()
os.exit(0)
