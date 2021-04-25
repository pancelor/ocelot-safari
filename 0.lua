-- template
--  BY PANCELOR

--[[
this engine uses an actor-based
 system designed to be as simple
 as possible, not efficient.
replace when needed

todo:
 quitting out from upd_gover is hella borked for some reason
  it stalls during drw_game on the first frame...
  maybe b/c it doesn't get a chance to run upd_game that frame??
]]

--todo: t3:
-- print("\^c0\15")
-- fixedrng ?
-- use srnd instead of rng_state stuff
-- s/dot()/pset(), lol

dev=true
-- dev_dev_marker=dev
dev_pal_pick=dev --tab to swap colors
dev_pal_persist=dev
-- dev_grid=dev
-- dev_fast_cycle=dev
dev_spawn_cat=dev
-- dev_spawn_gem=dev
-- dev_ghost=dev
-- dev_rng={0x2f90.fd80,0xa4b8.8036}

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
 daypoke="0x5f10,0x0,0x81,0x8c,0xf,0x84,0x4,0x86,0xa,0x88,0x89,0x9,0x87,0x8a,0xb,0x8b,0x3"
 duskpoke="0x5f10,0x0,0x81,0x8c,0x83,0x89,0x4,0x85,0xa,0x8,0x84,0x9,0x8a,0x87,0x8d,0x3,0x8b"
 nightpoke="0x5f10,0x80,0x1,0x82,0x83,0x2,0x85,0x5,0x6,0x7,0x8,0xc,0xd,0xe,0x8d,0x8e,0x8f"
 poke(unpack(split(daypoke)))

 -- keyrepeat
 poke(0x5f5c,-1)

 dirx=arr0(-1,split"1,0,0,1,1,-1,-1")
 diry=arr0(0,split"0,-1,1,-1,1,1,-1")
 rot_from_but=arr0(2,split"0,1,3")
 rotx=arr0(1,split"0,-1,0")
 roty=arr0(0,split"-1,0,1")

 init_game()
 if dev then
  dev_init()
 end
end
function _update60()
 check_palpick()
 update_screenshot_title()
 upd()
end

function _draw()
 cls(4)
 drw()
 check_fade()
 -- nocam(draw_brb)()
end

function draw_brb()
 oprint8("break time!",40,40,3,0)
 oprint8("back in 10~20min",40,50,3,0)
end

function init_game()
 upd,drw=upd_game,drw_game
 actors,actors_toinit={},{}
 worldw,worldh=128,20
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
 local cx,cy=peek2(0x5f28,2)
 for ob in all(actors) do
  if ob.draw then
   ob:draw()
  elseif not offscreen(ob.x,ob.y) then
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

function hit(x,y, ignore)
 for ob in all(actors) do
  if ob~=ignore and not ob.nohit
  and ob.x==x and ob.y==y
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

