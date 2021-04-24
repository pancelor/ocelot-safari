-- pancelor dialogue boxes

--[[
delete if you don't need them
(this is not the official copy;
update pdb/pdb.p8 instead)

todo: change rectfill
]]

-- doing the obvious minifications gets this lib down to
-- ~435 tokens (not including coupdate/wait etc)

-- initialize the state for pdb.
-- call this once, during __init
function pdb_init()
  -- state
  pdb_cmd_queue={} -- a list of {cmd,arg} virtual machine commands. see pdb_script
  pdb_draw_state={} -- list of <=pdb_nlines strings, each of legal width

  -- constants
  pdb_flash_t=30
  pdb_nlines=3 -- number of lines to display
  pdb_max_line_w=30
  pdb_wait_times=parse".=6,?=6,!=6"
  pdb_wait_times[","]=6
  pdb_wait_newline=6
  pdb_sfx=0
  -- to change the button from ❎ to 🅾️:
  -- * search for btnp and change both 5's to 4's
  -- * search for ❎ and change it to 🅾️ (in pdb_draw)
  pdb_col_bg=0
  pdb_col_fg=7
  pdb_col_border=1
  pdb_col_flash0=1
  pdb_col_flash1=7

  -- this script interprets the vm commands in pdb_cmd_queue
  -- and executes them, modifying pdb_draw_state
  pdb_script=cocreate(function()
    while true do
      while not pdb_active() do
        yield()
      end

      -- hack: popping _before_ processing only works b/c each pdb_add
      -- adds a pdb_cmd_cls to the very end, so pdb_active() happens to
      -- still be accurate
      local cmd,arg=unpack(deli(pdb_cmd_queue,1))
      if cmd=="pdb_cmd_cls" then
        -- clear the screen
        pdb_draw_state={}
      elseif cmd=="pdb_cmd_print" then
        -- scroll first if necessary
        if #pdb_draw_state==pdb_nlines then
          deli(pdb_draw_state,1)
        end
        add(pdb_draw_state,"")
        -- add one line of text to the draw state
        local skip_to_eol=false
        for i=1,#arg do
          local char=sub(arg,i,i)
          pdb_draw_state[#pdb_draw_state]..=char
          if not skip_to_eol then
            sfx(pdb_sfx)
            skip_to_eol=wait_btnp_timeout(5,pdb_wait_times[char] or 1)
          end
        end
        wait(pdb_wait_newline)
      elseif cmd=="pdb_cmd_wait_btn" then
        -- wait for button press
        pdb_wait_t=0
        while not btnp(5) do
          yield()
          pdb_wait_t+=1
        end
        yield()
        pdb_wait_t=nil
      end
    end
  end)
end

function pdb_update()
  coupdate(pdb_script)
end

-- draw whatever's in pdb_draw_state at the moment
function pdb_draw()
  if pdb_active() then
    local m=2 --border distance
    local h=7 -- line height
    local far=128-m-1
    local y=far-h*pdb_nlines-1

    -- little minification:
    -- for i=-1,1 do
    --   rectfill(m+i,y-i,far-i,far+i,pdb_col_border)
    -- end
    -- rectfill(m,y,far,far,pdb_col_bg)

    rectfill(m-1,y+1,far+1,far-1,pdb_col_border)
    rectfill(m+1,y-1,far-1,far+1,pdb_col_border)
    rectfill(m,y,far,far,pdb_col_bg)
    for i,s in ipairs(pdb_draw_state) do
      print(s,m+2,y+2+h*(i-1),pdb_col_fg)
    end
    if pdb_wait_t then
      local col=pdb_wait_t\pdb_flash_t%2<1
        and pdb_col_flash0
        or pdb_col_flash1
      print("❎",far-8,far-6,col)
    end
  end
end
-- minified version for pdb_nlines=3: (saves ~60 tokens alone)
-- function pdb_draw()
--   -- draw whatever's in pdb_draw_state at the moment
--   if pdb_active() then
--     rectfill(2,100,125,126,1)
--     rectfill(1,101,126,125,1)
--     rectfill(2,101,125,125,0)
--     for i,s in ipairs(pdb_draw_state) do
--       print(s,4,96+7*i,7)
--     end
--     if pdb_wait_t then
--       print("❎",117,119,pdb_wait_t\30%2<1 and 1 or 7)
--     end
--   end
-- end

-- returns whether pdb is currently active
function pdb_active()
  return #pdb_cmd_queue>0
end

-- for use during coroutines; see the example.
-- if you prefer callback-based events, that shouldn't be too hard
--   to add to this library -- add a new vm command called
--   "pdb_cmd_callback" to pdb_add and pdb_script
function pdb_yield()
  while pdb_active() do
    yield()
  end
end

-- todo is this the best version of this idea?
function pdb_add_yield(str)
  pdb_add(str)
  pdb_yield()
end

-- this is the most complicated function.
-- it takes an input string and breaks it down into vm commands
--   that it pushes onto pdb_cmd_queue, which pdb_script will
--   interpret later
function pdb_add(str)
  local line_i=1 -- first char of next line
  local line_w=0 -- how long the current line is
  local break_i=-1 -- best place to break. -1 means none found
  local break_w=0 -- line_w at break_i
  local break_skip=0 -- how many chars to skip after the break
  _pdb_enqueue_cmd("pdb_cmd_cls")
  local nlines_added=0
  for i=1,#str do
    local char=sub(str,i,i)
    local char_w=ord(char)<128 and 1 or 2
    if char==" " then
      break_i=i-1 -- break just before this character
      break_skip=1
      break_w=line_w
    end
    if char=="\n" then
      break_i=i-1 -- break just before this character
      break_skip=1
      line_w=pdb_max_line_w -- hack: force line break on this loop iteration
      break_w=line_w
    end
    -- pq{
    --   char=qf("\"%\"",char),
    --   break_i=break_i,
    --   break_w=break_w,
    --   line_i=line_i,
    --   line_w=line_w,
    --   strn=#str,
    -- }
    -- stop()
    local is_pause_line=(nlines_added+1)%pdb_nlines==0
    if line_w+char_w>pdb_max_line_w+(is_pause_line and -2 or 0) then
      if break_i==-1 then
        -- no available breaks found;
        -- insert one automatically
        break_i=i-1 -- break just before this character
        break_skip=0
        break_w=line_w
      end
      _pdb_enqueue_cmd("pdb_cmd_print",sub(str,line_i,break_i))
      nlines_added+=1
      if is_pause_line then
        _pdb_enqueue_cmd("pdb_cmd_wait_btn")
      end
      line_w-=break_w
      line_i=break_i+1+break_skip
      break_w=line_w
      break_i=-1 -- reset to "no break found"
    end
    line_w+=char_w
    if char=="-" then
      break_i=i -- break just *after* this character
      break_skip=0
      break_w=line_w
    end
  end
  if line_i<=#str then
    _pdb_enqueue_cmd("pdb_cmd_print",sub(str,line_i))
    -- nlines_added+=1
  end
  if pdb_cmd_queue[#pdb_cmd_queue][1]~="pdb_cmd_wait_btn" then
    _pdb_enqueue_cmd("pdb_cmd_wait_btn")
  end
  _pdb_enqueue_cmd("pdb_cmd_cls")
  -- _pdb_printh_cmd_queue()
end

-- function _pdb_printh_cmd_queue()
--   for blob in all(pdb_cmd_queue) do
--     local cmd,arg=unpack(blob)
--     printh(cmd..": "..tostr(arg))
--   end
-- end

function _pdb_enqueue_cmd(...)
  add(pdb_cmd_queue,{...})
end
