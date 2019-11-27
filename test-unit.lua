-- 2019.5.8
-- Project Tooru
-- Test

-- In favor of THE WIRED BUG, unit test is not able to test gambit gnm solver.
-- The details refer to file test-app.lua.
-- [[SOLVED]] We just do not use LuaUnit, test is not hard, written by ourselves.

local pp = require 'pl.pretty'
local u = require 'tooru/u'

local testl = io.open('_lost/unit-test.log', 'w')
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

local target, case, answ, good, msg, ok

prt 'Project Tooru Unit Test\n\n'
log 'Project Tooru Unit Test Resault Log\n\n'

do ------------------------------------------------------------ Target u
  prt 'Tooru/u function test begin:\n'
  local huawei = {}

  target = u.tieup
  prt 'Testing u.tieup...'
  case = target {_asd = 12, dsa = 32, [huawei] = 43, 12}
  assert(not case.ASD, 'tieup make new element for table... what a joke')
  assert(not case._asd, 'element start with underscore still seen')
  assert(not case[1], 'list element still seen')
  assert(not case[huawei], 'table-key element still seen')
  assert(case.dsa, 'normal element hidden')
  prt ' Done\n'

  target = u.freeze
  prt 'Testing u.freeze...'
  case, msg =
    target(
      {
        asd = {asd = {1, 2, 3}},
        dsa = 12,
        {1, 2, 3},
        [huawei] = 21
      },
      true
    ),
    'freezen table still can be modified'
  assert(
    not pcall(
      function()
        case.dsa = 12
      end
    ),
    msg
  )
  assert(
    not pcall(
      function()
        case.asd.asd[1] = 1
      end
    ),
    msg
  )
  assert(
    not pcall(
      function()
        case[1][1] = 12
      end
    ),
    msg
  )
  assert(
    not pcall(
      function()
        case[huawei] = 22
      end
    ),
    msg
  )
  assert(
    not pcall(
      function()
        table.insert(case, 12)
      end
    ),
    msg
  )
  assert(
    not pcall(
      function()
        table.remove(case)
      end
    ),
    msg
  )
  prt ' Done\n'

  target = u.clone
  prt 'Testing u.clone with easy case...'
  case, msg =
    {
      [huawei] = 'waway',
      1,
      2,
      3,
      {1, 2, 3},
      _asd = 123,
      {{{{'deep dark'}}}}
    },
    'cloned element not same'
  local case_clone = target(case)
  assert(case_clone[1] == case[1], msg)
  assert(case_clone[4] ~= case[4], 'cloned table is not in different mem')
  for i = 1, 3 do
    assert(case_clone[4][i] == case[4][i], msg)
  end
  assert(case_clone._asd == case._asd, msg)
  assert(case[5][1][1][1][1] == 'deep dark', msg)
  assert(
    case_clone[5][1][1][1][1] == case[5][1][1][1][1],
    'cloned element not same'
  )
  assert(case_clone[huawei] == case[huawei], msg)
  prt ' Done\n'
  prt '\tNow with hard case...'
  case = {}
  local caes, cesa, csea, csae, ceas = {}, {}, {}, {}, {}
  case.caes = caes
  caes.cesa = cesa
  cesa.csea = csea
  csea.csae = csae
  csae.ceas = ceas
  ceas.case = case
  csea.fantasy = {1, 2, 3}
  ok, case_clone = pcall(target, case)
  assert(ok, case_clone)
  assert(case.caes.cesa.csea.fantasy, 'cloned element disappeared')
  for i = 1, 3 do
    assert(
      case_clone.caes.cesa.csea.fantasy[i] == case.caes.cesa.csea.fantasy[i],
      msg
    )
  end
  assert(
    case_clone.caes.cesa.csea.fantasy ~= case.caes.cesa.csea.fantasy,
    'cloned table is not in different mem'
  )
  prt ' Done\n'

  target = u.beauty
  prt 'Testing u.beauty...'
  case =
    [[
                                    
          举身赴清池
          桃花潭水深千迟，不及汪伦送我情。

            南村群童欺我老无力，忍能对面为盗贼。
          难拾一叶得作伴，始见余晖满地红。
        终身履薄冰，谁知我心焦！


        ]] ..
    '\n'
  local beautycase = target(case, '>')
  assert(beautycase:find '举身赴清池', 'orignal content changed')
  assert(beautycase:sub(-1) == '\n', 'not end with \\n')
  assert(#beautycase == (#case + 10 + 1 - 1), 'len not right')
  for l in beautycase:gmatch('(.*)\n') do
    assert(l:sub(1, 1) == '>', 'line not start with prefix')
  end
  prt ' Done\n'

  target = u.split
  prt 'Testing u.split with normal case...'
  case =
    [[

        wowowowow
        采采卷耳 不盈倾筐
        皆我怀人，置彼周行。

        ？          
        ！
        ]]
  local ws = target(case)
  assert(#ws == 6, 'not enough words')
  for _, w in ipairs(ws) do
    assert(not w:find '%s', 'still blank in words: ' .. w)
  end
  prt ' Done\n'
  prt '\tNow with wrong case...'
  case = {1, 2, 3}
  local same = target(case)
  assert(same == case, 'non-string should be return as it is')
  prt ' Done\n'

  target = u.keypairs
  prt 'Testing u.keypairs with normal case...'
  case = {
    '_asd=_asd',
    'number=123.3',
    'poem=江月何年初照人',
    'sp="!@#$%^&*>{}"'
  }
  answ = {
    {'_asd', '_asd'},
    {'number', 123.3},
    {'poem', '江月何年初照人'},
    {'sp', '"!@#$%^&*>{}"'}
  }
  for i = 1, 4 do
    local k, v = target(case[i])
    assert(k == answ[i][1])
    assert(v == answ[i][2])
  end
  prt ' Done\n'
  prt '\tNow with wrong case...'
  case, msg = {'err=', '错误=?'}, 'wrong case should just return nil, but '
  local _, v = target(case[1])
  assert(not v, msg .. tostring(v))
  local k, _ = target(case[2])
  assert(not k, msg .. tostring(k))
  prt ' Done\n'

  prt 'Tooru/u function test passed!\n\n'
end ------------------------------------------------------ Target u finish

do --------------------------------------------------- Target game function
  prt 'Game function test begin:\n'
  local tooru = require 'tooru'
  local content, csgg

  prt 'Test case initializing...'
  log '\n* CSG game function test setup BEGIN\n'
  case =
    [[
      title: Test Case
      comment: This is a Tooru Unit Test case. This game reperesent does not contain anything meaningful.
      game_type: csg
      payoffs:
        - [12,-1,0,0,0,0,0,0,0,0,0,0,0,0, 1,1,0,0,0,0,0,0,0,0,0,0,0,0, 1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1, -1,12,0,0,0,0,0,0,0,0,0,0,0,0]
      types:
        - [Altman, 1, 1, 1]
        - [Gozira, 1, 2, 1]
        - [Kamen Rider, 12, 3, 1]
      value_switch: 0
      action_sets:
        - [Beam, SYAAAAAA]
        - [AWOOOO, Beam]
        - [Hensin]
    ]]
  assert(tooru.reader.read, 'load tooru mod failed')
  content, msg = tooru.reader.read(case, 'yaml')
  assert(content, msg)
  csgg, msg = tooru.game.new(content)
  assert(csgg, msg)
  log('\n* CSGG Game Dump:\n', pp.write(csgg))
  log '\n* CSG game function test setup END\n\n'
  prt ' Done\n'

  target = function(...)
    return csgg:copy_choice_label2lidx(...)
  end
  prt 'Testing csgg:copy_choice_label2lidx with normal case...'
  case = {
    {
      'Beam',
      'Beam',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin'
    },
    {'SYAAAAAA', 'AWOOOO'}
  }
  answ = {{1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {2, 1}}
  for i, c in ipairs(case) do
    case[i] = target(c)
    for j = 1, 14 do
      assert(
        case[i][j] == answ[i][j],
        'case #' .. i .. 'transform missed #' .. j
      )
    end
  end
  prt ' Done\n'
  prt '\tNow with wrong case...'
  case = {{'Hensin'}, {'YAAAAA', 'ERRRRRR'}, {1, 2, 1, 1, 2, 1}}
  for i, c in ipairs(case) do
    good = target(c)
    assert(not good, 'case' .. i .. 'how can you handld something wrong')
  end
  prt ' Done\n'

  target = function(...)
    return csgg:copy_choice_lidx2label(...)
  end
  prt 'Testing csgg:copy_choice_lidx2label with normal case...'
  answ = {
    {
      'Beam',
      'Beam',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin',
      'Hensin'
    },
    {'SYAAAAAA', 'AWOOOO'}
  }
  case = {{1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {2, 1}}
  for i, c in ipairs(case) do
    case[i] = target(c)
    for j = 1, 14 do
      assert(
        case[i][j] == answ[i][j],
        'case #' .. i .. 'transform missed #' .. j
      )
    end
  end
  prt ' Done\n'
  prt '\tNow with wrong case...'
  case = {{'Hensin'}, {'YAAAAA', 'ERRRRRR'}, {4123, 4125, 3, 747, 68, 58, 58}}
  for i, c in ipairs(case) do
    good = target(c)
    assert(not good, 'case' .. i .. 'how can you handld something wrong')
  end
  prt ' Done\n'

  prt 'Game function test passed!\n\n'
end --------------------------------------------- Target game function finsh

do ----------------------------------------------------------- Target solver
  prt 'Solver test begin:\n'
  local tooru = require 'tooru'
  local csgg, content, neq_render
  local gnm

  prt 'Test case initializing...'
  log '\n* Solver test setup BEGIN\n'
  case =
    [[
      title: Test Case
      comment: This is a Tooru Unit Test case. This game reperesent does not contain anything meaningful.
      game_type: csg
      payoffs:
        - [1,1,0,2,0,2,1,1,0,3,2,0]
      types:
        - [Pinky Pie, 1, 1, 1]
        - [Twlight Spark, 1, 2, 1]
      value_switch: 0
      action_sets:
        - [Party, Geege, Sing]
        - [Magic, Fly]
    ]]
  assert(tooru.reader.read, 'load tooru mod failed')
  content, msg = tooru.reader.read(case, 'yaml')
  assert(content, msg)
  csgg, msg = tooru.game.new(content)
  assert(csgg, msg)
  log('\n* CSGG Game Dump:\n', pp.write(csgg))
  neq_render, msg = tooru.render.new('outcome', 'raw', testl, true, 12)
  assert(neq_render, msg)
  gnm = tooru.calculator.new('gnm', {neq_render})
  log '* Solver test setup END\n\n'
  prt ' Done\n'

  target = gnm
  prt 'Testing gnm with normal case...'
  case = csgg
  -- [[SOLVED]] According to Gambit doc, should be
  -- answ = {1, 0, 2.99905e-12, 0.5, 0.5}
  -- while according to gambit-gnm tool (github master ver.) it is actually
  -- a '0'. That is not a matter, they are so closed numbers.
  -- Changing Precision can details the difference. Now we use 12 digitals.
  answ = {
    0.999999999997,
    0.000000000000,
    0.000000000003,
    0.500000000009,
    0.499999999991
  }
  log '* Gnm solving:\n'
  good, msg = target:solve(case)
  assert(good, msg)
  assert(
    #good == 1 and good[1].TAG == 'NE' and #good[1] == #answ,
    'got some corrupt answer'
  )
  for i, a in ipairs(answ) do
    assert(
      u.stupid_float_eq(a, good[1][i]),
      'wrong answer: ' .. good[1][i] .. ' to ' .. a
    )
  end
  prt ' Done\n'

  prt 'Solver test passed!\n\n'
end --------------------------------------------------- Target solver finsh

prt 'All test passed. Good Job!\nProject Tooru :)\n'
