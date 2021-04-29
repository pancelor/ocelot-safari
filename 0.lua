-- ocelot safari
--  BY PANCELOR

-- dev=true
dev_pal_persist=dev
-- dev_fast_cycle=dev
dev_spawn_cat=dev
-- dev_spawn_gem=dev
-- dev_ghost=dev
-- dev_dev_marker=dev
-- dev_instawin=dev and 0
-- dev_rng={0x2f90.fd80,0xa4b8.8036}

show_intro=8 --8 player steps
f_mute=false

function dev_init()
 if dev_pal_persist then
  poke(0x5f2e,1)
 end

 if dev_rng then
  restore_rng(unpack(dev_rng))
 end
 local rng1,rng2=rng_state()
 pqf("{%,%}",tostr(rng1,1),tostr(rng2,1))
end

function _init()
 printh("---")
 -- music(0,1000)

 -- menuitem(2,"toggle music",function()
 --  f_mute=not f_mute
 --  if f_mute then
 --   music(-1,1000)
 --  else
 --   music(0,1000)
 --  end
 -- end)

 --screen palette
 daypoke="0x5f10,0x0,0x84,0x4,0x8c,0x86,0x6,0x87,0x7,0x8,0x89,0x8b,0xb,0x8a,0x82,0xd,0x83"
 duskpoke="0x5f10,0x0,0x82,0x84,0x83,0x85,0xd,0x9,0x6,0x88,0x4,0x3,0x8b,0xb,0x89,0xc,0x8c"
 nightpoke="0x5f10,0x0,0x80,0x82,0x81,0x85,0x8d,0x3,0xd,0x88,0x84,0x83,0x3,0x8b,0x4,0x7,0x8a"
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
 update_screenshot_title()
 upd()
end

function _draw()
 cls(2)
 drw()
 check_fade()
 if show_intro>0 then
  local text="ocelot safari"
  local x,y=cprintcj(text,64,64)
  oprint8(text,x+%0x5f28,y+%0x5f2a,6,9)
 end
end

function init_game()
 upd,drw=upd_game,drw_game
 actors,actors_toinit={},{}
 worldw,worldh=64,20
 do_z_sort=false
 load_actors()
 fade_t=1
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

function init_gover(won)
 upd,drw=upd_gover,drw_gover
 gover_won=won
 if gover_won then
  sfx(56)
 else
  poke(unpack(split(nightpoke)))
 end
end
function upd_gover()
 if btnp(5) then
  fadeout()
  extcmd("reset")
 end
end
function drw_gover()
 drw_game()
 local text=gover_won and "you win!" or "game over"
 local x,y=cprintcj(text,64,64)
 oprint8(text,x+%0x5f28,y+%0x5f2a,0,7)
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

