-- template
--  BY PANCELOR

-- use this as a template when
-- starting a new project.
-- tab 0: engine code
-- tab 1: game code
-- tab 2: helper+debug functions.
-- tab 3: palette picker.
-- tab 4: dialogue boxes

-- other places to find tech:
--  collision: upgo.p8
--  2d vector: eh yunklops.p8? not polished
--  scrolling maps: upgo.p8. also remains.p8 was _super_ simple; probably better
--  entity handling system: pandc.p8? birthday? escalatorworld?
--  menu tech: escalatorworld.p8
--  persistent data: escalatorworld.p8
--  light/fading: lightdemo.p8, mai-chan, escalatorworld.p8
--  copy url stuff: escalatorworld.p8
--  rect intersect: ? pandc.p8?
--  actor/component system: mmash.p8. remains.p8 seems pretty good too
--  celeste-style fractional movement: remains.p8
--  particles: ew.p8
--  map sliding: pork.p8(token-optimized) remains.p8. puz.p8 upgo?
--  simple map "spritesheet packing": puz.p8 "init_level_loader"
--  easing/lerp animations: tech/easing.p8
--    scripts / scrlerp (lol)
--  timer code: linecook.p8 mothbear.p8
--  dynamic music: linecook.p8 has a good start. probably want next_music to be more of a "try to go here" not "definitely go here next"
--  rotated sprites: purplepaths.p8
--  90 degree rotations: crossed-wires.p8 (draw_s/sprdir)
--  ecs: ld47/ecs.p8
--    different flavor start point: crossed-wires.p8

--[[
this engine uses an actor-based
 system designed to be as simple
 as possible, not efficient.
replace when needed

todo: upd_game event order?
 script/update are currently
  iterleaved, all at once might be better
 quitting out from upd_gover is hella borked for some reason
  it stalls during drw_game on the first frame...
  maybe b/c it doesn't get a chance to run upd_game that frame??
]]

dev=true
dev_pal_pick=dev --tab to swap colors
-- dev_pal_persist=dev
--dev_rng={0x5438.c744,0xfe04.4447}

function dev_init()
 if dev_pal_persist then
  poke(0x5f2e,1)
 end
 poke(0x5f2d,1) --enable mouse
 
 if dev_rng then
  restore_rng(unpack(dev_rng))
 end
 local rng1,rng2=rng_state()
 pqf("{%,%}",tostr(rng1,1),tostr(rng2,1))
end

function _init()
 printh("---")
 --screen palette
 poke(unpack(split"0x5f10,0x0,0x1,0x2,0x3,0x89,0x5,0x8c,0x7,0x8,0x9,0x88,0xb,0x83,0xd,0xe,0xf"))

 -- font
 poke(0x5600,unpack(split"8,8,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,12,12,12,12,0,12,0,0,54,54,54,0,0,0,0,0,0,54,127,54,127,54,0,0,12,62,3,30,48,31,12,0,0,51,27,12,54,51,0,0,14,19,6,47,59,30,0,0,6,6,6,0,0,0,0,0,24,12,12,12,12,24,0,0,6,12,12,12,12,6,0,0,0,54,28,127,28,54,0,0,0,12,12,63,12,12,0,0,0,0,0,0,6,6,3,0,0,0,0,30,0,0,0,0,0,0,0,0,6,6,0,0,96,48,24,12,6,3,0,0,30,51,59,55,51,30,0,0,12,14,12,12,12,30,0,0,30,49,56,30,7,63,0,0,31,56,30,56,56,31,0,0,56,60,54,51,127,48,0,0,31,3,31,56,57,30,0,0,30,3,31,51,51,30,0,0,63,51,24,12,12,12,0,0,30,51,30,51,51,30,0,0,30,51,51,62,48,30,0,0,0,6,6,0,6,6,0,0,0,6,6,0,6,6,3,0,0,24,12,6,12,24,0,0,0,0,62,0,62,0,0,0,0,6,12,24,12,6,0,0,28,50,48,28,0,12,0,0,62,99,123,43,27,67,62,0,30,51,51,63,51,51,0,0,31,51,31,51,51,31,0,0,30,51,3,3,51,30,0,0,31,51,51,51,51,31,0,0,63,3,31,3,3,63,0,0,63,3,31,3,3,3,0,0,30,51,3,59,51,30,0,0,51,51,63,51,51,51,0,0,63,12,12,12,12,63,0,0,63,12,12,12,13,6,0,0,51,51,27,15,27,51,0,0,3,3,3,3,3,63,0,0,99,119,127,107,99,99,0,0,51,55,63,59,51,51,0,0,30,51,51,51,51,30,0,0,31,51,51,31,3,3,0,0,30,51,51,51,51,30,56,0,31,51,51,31,11,51,0,0,62,7,30,56,56,31,0,0,63,12,12,12,12,12,0,0,51,51,51,51,51,62,0,0,99,99,99,99,54,28,0,0,99,99,99,107,127,54,0,0,99,118,60,30,55,99,0,0,51,51,51,30,12,12,0,0,63,56,28,14,7,63,0,0,30,6,6,6,6,30,0,0,3,6,12,24,48,96,0,0,30,24,24,24,24,30,0,0,12,30,51,0,0,0,0,0,0,0,0,0,0,62,0,0,6,12,24,0,0,0,0,0,0,30,48,62,51,62,0,0,3,3,31,51,51,31,0,0,0,30,51,3,51,30,0,0,48,48,62,51,51,62,0,0,0,30,51,63,3,30,0,0,28,6,31,6,6,6,0,0,0,62,51,51,62,48,30,0,3,3,31,51,51,51,0,0,12,0,15,12,12,63,0,0,24,0,30,24,24,26,12,0,3,3,27,15,27,51,0,0,14,12,12,12,12,63,0,0,0,51,127,107,99,99,0,0,0,31,51,51,51,51,0,0,0,30,51,51,51,30,0,0,0,31,51,51,31,3,3,0,0,62,51,51,62,48,48,0,0,27,55,3,3,3,0,0,0,62,7,30,56,31,0,0,6,6,31,6,38,28,0,0,0,51,51,51,51,62,0,0,0,51,51,51,30,12,0,0,0,99,99,107,127,54,0,0,0,51,30,12,30,51,0,0,0,51,51,51,62,24,15,0,0,63,24,12,6,63,0,0,28,12,14,14,12,28,0,0,12,12,12,12,12,12,0,0,14,12,28,28,12,14,0,0,0,0,78,127,57,0,0,0,0,0,0,0,0,0,0,0,127,127,127,127,127,0,0,0,85,42,85,42,85,0,0,0,65,127,93,93,62,0,0,0,62,99,99,119,62,0,0,0,17,68,17,68,17,0,0,0,4,60,28,30,16,0,0,0,28,46,62,62,28,0,0,0,54,62,62,28,8,0,0,0,28,54,119,54,28,0,0,0,28,28,62,28,20,0,0,0,28,62,127,42,58,0,0,0,62,103,99,103,62,0,0,0,127,93,127,65,127,0,0,0,56,8,8,14,14,0,0,0,62,99,107,99,62,0,0,0,8,28,62,28,8,0,0,0,0,0,85,0,0,0,0,0,62,115,99,115,62,0,0,0,8,28,127,62,34,0,0,0,62,28,8,28,62,0,0,0,62,119,99,99,62,0,0,0,0,5,82,32,0,0,0,0,0,17,42,68,0,0,0,0,62,107,119,107,62,0,0,0,127,0,127,0,127,0,0,0,85,85,85,85,85,0,0,0"))
 poke(0x5f58,0x81)

 --keyrepeat
 poke(0x5f5c,9,4)
-- poke(0x5f5c,255) -- no keyrepeat

 dirx=arr0(-1,split"1,0,0,1,1,-1,-1")
 diry=arr0(0,split"0,-1,1,-1,1,1,-1")
 fade_pal=split"0,1,1,2,1,13,6,4,4,9,3,13,1,13,14"

 init_game()
 if dev then 
  dev_init()
 end
end
function _update60()
 check_palpick()
 update_mouse()
 update_screenshot_title()
 upd()
end

function _draw()
 cls(3)
 drw()
 check_fade()
end

function init_game()
 upd,drw=upd_game,drw_game
 actors,actors_toinit={},{}
 worldw,worldh=32,32
 do_z_sort=false
 load_actors()
 -- fade_t=1 --doesn't work with custom palettes
end

function upd_game()
 for ob in all(actors_toinit) do
  ob:init()
 end
 actors_toinit={}
 for ob in all(actors) do
  if ob.update then
   ob:update()
  end
  if ob.script then
   coupdate(ob.script,ob)
  end
  if ob.ani then
   update_ani(ob.ani)
  end
 end
 -- clean up dead actors
 for ob in all(actors) do
  if ob.dead then
   del(actors,ob)
  end
 end
 -- sort by depth
 if do_z_sort then
  sort(actors,function(ob)
   return -(ob.z or 0)
  end)
  do_z_sort=false
 end
end

function drw_game()
 for ob in all(actors) do
  if ob.draw then
   ob:draw()
  elseif ob.ani then
   draw_s(ob)
  end
 end
end

function init_gover()
 upd,drw=upd_gover,drw_gover
end
function upd_gover()
 if btnp(5) then
  fadeout()
  init_game()
 end
end
function drw_gover()
 cls()
 printcj("game over",64,64,7)
end

function make_actor(...)
 local ob=merge_into(...)
 if ob.init then
  add(actors_toinit,ob)
 end
 do_z_sort=true
 return add(actors,ob)
end

function die(self)
 if not self then return end
 self.dead=true
 if self.denit then
  -- todo should this maybe happen at end-of-frame?
  self:denit()
 end
end

hitl_ui=0x01
function hit(x,y, hitl,ignore)
 hitl=hitl or ~0
 for ob in all(actors) do
  if ob.hit
  and ob~=ignore
  and ob.hitl&hitl>0
  and ob:hit(x,y)
  then
   return ob
  end
 end
end

---- a complicated stateful iterator;
---- finds a fresh new collision every time through the loop
---- (so you can collide with things, respond by moving, and then collide with things at your new location)
---- also, keeps track and only collies with any individual actor once
--function m_play:iter_collisions(a1)
-- local seen={}
-- return function()
--  for i,a2 in ipairs(self.actors) do
--   if a1~=a2 and not seen[i]
--   and self:test_collision(a1,a2) then
--    seen[i]=true
--    return a2
--   end
--  end
--  return nil
-- end
--end
