-- game

buts={}
buts_del={}
btn_last=0x0
function update_btns()
 for b=0,3 do
  local mask=1<<b
  if btnp()&mask>0 then
   -- pq("press",b)
   add(buts,{b=b})
  end
 end

 local btnr=(btn()&btn_last)^^btn_last
 -- pq("btn(),btn_last,btnr\n",tobin(btn()),tobin(btn_last),tobin(btnr))
 for b=0,3 do
  local mask=1<<b
  if btnr&mask>0 then
   local ix=_recent_ix(b)
   if ix then
    if buts[ix].seen then
     -- pq("seen; release now",b)
     deli(buts,ix)
    else
     -- pq("not seen yet; release later",b)
     add(buts_del,buts[ix])
    end
   elseif dev then
    pq"=====BUTTON RELEASED SOMEHOW====="
   end
  end
 end
 btn_last=btn()
end
function _recent_ix(b)
 for i=#buts,1,-1 do
  if buts[i].b==b then
   return i
  end
 end
end
function poll_btns()
 -- pq(qa(buts))
 if #buts>0 then
  --find first unseen entry
  local entry=buts[#buts]
  for e in all(buts) do
   if not e.seen then
    entry=e
    break
   end
  end
  entry.seen=true
  -- delayed button release
  for e in all(buts_del) do
   -- pq("delayed release",e.b)
   del(buts,e)
  end
  buts_del={}
  -- pq(entry.b,"===")
  return rot_from_but[entry.b]
 end
end
function buts_waiting()
 for e in all(buts) do
  if not e.seen then
   return true
  end
 end
end

-- these are my tile numbers; drawing in the pico-8 map won't work
T_PATH=0 --special
T_PLAYER=1
T_MACHETE=2
T_VINE=3
T_TREE=5
T_AXE=13
T_ROCK=14
T_STONE=15
T_PICK=16
T_WATER=17 --todo animate with 18
T_FLINT=19
T_MAG=24
T_GEM=25
function tile_solid(t)
 return t==T_WATER or t==T_ROCK or t==T_VINE or t==T_TREE
end
function translate_tile(t)
 if t==T_AXE then
  return T_PATH,actor_axe
 elseif t==T_PICK then
  return T_PATH, actor_pick
 elseif t==T_MACHETE then
  return T_PATH, actor_machete
 elseif t==T_FLINT then
  return T_PATH, actor_flint
 elseif t==T_MAG then
  return T_PATH, actor_mag
 elseif t==T_GEM then
  return T_PATH, actor_gem
 elseif t==T_PLAYER then
  return T_PATH, actor_player
 elseif tile_solid(t) then
  return t
 end
 -- elseif t==T_ROCK then
 --  return get_11tile(t)
 -- elseif t==T_TREE then
 --  return get_11tile(t)
 -- elseif t==T_WATER then
 --  return get_11tile(t)
 -- elseif t==T_VINE then
 --  return get_11tile(t)
 -- end
end
-- function get_11tile(t8)
--  local y8,x8=divmod(t8,16)
--  local sx,sy=x8*8\_12,y8*8\_12
--  return sy*_12+sx
-- end

function hit_tile(x,y)
 local t=mget(x,y)
 return tile_solid(t) and t or nil
end

function load_map()
 for y=0,worldh-1 do
  for x=0,worldw-1 do
   local tile=mget(x,y)
   if tile~=0 then
    local ctor
    tile,ctor=translate_tile(tile)
    mset(x,y,tile)
    if ctor then
     ctor{x=x,y=y}
    end
   end
  end
 end
end

local DAY_LEN,DAY_AND_DUSK_LEN,TOTAL_LEN=100,120,160
local CLOCK_LEN=60
function load_actors()
 if dev_fast_cycle then
  DAY_LEN/=5
  DAY_AND_DUSK_LEN/=5
  TOTAL_LEN/=5
 end

 map_gen()
 load_map()

 hud=make_actor{
  z=-100,
  dayt=0,
  nohit=true,
  script=cocreate(function(self)
   while 1 do
    wait(CLOCK_LEN)
    emit"clock_tick"
    pq"clock_tick"
   end
  end),
  clock_tick=function(self)
   self.dayt+=1
   if self.dayt==DAY_LEN then
    poke(unpack(split(duskpoke)))
   elseif self.dayt==DAY_AND_DUSK_LEN then
    poke(unpack(split(nightpoke)))
    pl.nt_timer=0
   elseif self.dayt==TOTAL_LEN then
    self.dayt=0
    poke(unpack(split(daypoke)))
   end
  end,
  is_night=function(self)
   return self.dayt>=DAY_AND_DUSK_LEN
  end,
  draw=nocam(function(self)
   -- day meter
   local x,y1,w,h,y2=32,120,63,6,2
   rectfillwh(x+1,y1,w,h,1) --night (full)
   rectfillwh(x+1,y1,w*DAY_AND_DUSK_LEN/TOTAL_LEN,h,2) --dusk
   rectfillwh(x+1,y1,w*DAY_LEN/TOTAL_LEN,h,11) --day
   rectwh(x+1+self.dayt/TOTAL_LEN*w,y1,1,h,8) -- dayt marker
   rectwh(x,y1,w+2,h,0) --border
   for x=32,96,8 do
    pset(x,119,0) --ticks
   end

   -- hp meter
   if pl.hp<4 then
    rectfillwh(x+1,y2,w*pl.hp/4,h,8) --hp
    rectwh(x,y2,w+2,h,0) --border
    for x=32,96,16 do
     pset(x,y2+h,0) --ticks
    end
   end

   if dev_dev_marker then
    print("dev",0,0,7)
   end
  end),
 }
 cam=make_actor{
  nohit=true,
  z=1,
  vox=0,
  voy=0,
  shake=function(self,r)
   r=r or 6
   local a=rnd()
   self.vox,self.voy=r*cos(a),r*sin(a)
  end,
  update=function(self)
   local cx,cy=pl.x,pl.y

   -- update camera
   local spd=1
   if dev_ghost then
    spd=8
   end
   camera(
    approach(%0x5f28,mid(cx*_12-64,worldw*_12-128),spd)+self.vox,
    approach(%0x5f2a,mid(cy*_12-64,worldh*_12-128),spd)+self.voy
   )
   self.vox/=2
   self.voy/=2
  end,
  draw=function(self)
   -- local cx,cy=peek2(0x5f28,2)
   local top=128\_12+1
   for dy=0,top do
    for dx=0,top do
     local x,y=%0x5f28\_12+dx,%0x5f2a\_12+dy
     local t=mget(x,y)

     -- jitter
     local dx,dy=divmod((x*x+y*y)&0xf,4)
     function f(x) return x&1>0 and 0 or (x&2)-1 end
     dx,dy=f(dx),f(dy)

     if t~=0 then
      spr12(t,x*_12+dx,y*_12+dy)
     end
    end
   end
   if dev_grid then
    grid(10)
   end
  end,
 }
end

-- function fixedrng(f)
--  local rng0,rng1=rng_state()
--  return function(...)
--   local rnga,rngb=rng_state()
--   restore_rng(rng0,rng1)
--   f(...)
--   restore_rng(rnga,rngb)
--  end
-- end

function actor_player(...)
 pl=make_actor({
  z=-20,
  s=1,
  -- item=nil,
  lastrot=0,
  init=function(self)
   self.prevx,self.prevy=self.x,self.y
  end,
  update=function(self)
   update_btns()

   if do_voxy(self) then
    -- handle items
    if self.item and self.item.dead then
     self:set_item()
    end
    if btn(4) and not self.item then
     for dr in all{0,2,1,3} do
      local rot=(self.lastrot+dr)%4
      local item=hit(self.x+rotx[rot],self.y+roty[rot])
      if item and item.move then
       self:set_item(item)
       break
      end
     end
    end
    if not btn(4) and self.item then
     self:set_item()
    end

    -- move
    local rot=poll_btns()
    if rot then
     if dev_ghost then
      self.prevx,self.prevy=self.x,self.y
      self.x+=rotx[rot]
      self.y+=roty[rot]
     else
      self:move(rot)
     end
    end
   end
  end,
  nt_timer=4,
  hp=4,
  clock_tick=function(self)
   --night terrors
   self.nt_timer-=1
   if self.nt_timer<=0 then
    if hud:is_night() then
     self.nt_timer=4
     if self:fire_dist2()>5 then
      cam:shake()
      self.hp-=1
      sfx(61)
      if self.hp<0 then
       fadeout()
       init_gover()
      end
     end
    else
     -- recover during day
     self.nt_timer=16
     self.hp=min(self.hp+1,4)
    end
   end
  end,
  fire_dist2=function(self)
   local d2=1000
   for a in all(actors) do
    if a.is_fire then
     d2=min(d2,dist2(self.x-a.x,self.y-a.y))
    end
   end
   return d2
  end,
  set_item=set_item,
  move=function(self,rot)
   move(self,rot)

   if rot==0 then
    self.flpx=false
   elseif rot==2 then
    self.flpx=true
   end
  end,
 },...)
 return pl
end

function set_item(self,item)
 if self.item then
  self.item.holder=nil
 end
 self.item=item
 if item then
  item.holder=self
 end
end

function emit(key)
 for a in all(actors) do
  if a[key] then
   a[key](a)
  end
 end
end

function apply_event(self,name,name2,rot,x,y)
 local tile=hit_tile(x,y)
 if tile and self.bump_tile then
  self:bump_tile(tile,x,y) 
 end
 -- no tile change
 if tile==hit_tile(x,y) then
  local ob=hit(x,y)
  if ob and ob[name] then
   ob[name](ob,rot)
  elseif ob and ob[name2] then
   ob[name2](ob,rot)
  end
 end
 actor_x{x=x,y=y}
end

function actor_machete(...)
 return make_actor({
  z=-10,
  s=2,
  init=tool_init,
  move=move,
  swing=function(self,myrot,plrot,ignore_tiles)
   self:move(myrot,ignore_tiles)
   local plrot2=(plrot+2)%4
   -- for p in all{
   --  pack(plrot2,xy_from_rot(plrot2,self.prevx,self.prevy)),
   --  pack(plrot2,xy_from_rot(plrot2,self.x,self.y)),
   --  pack(myrot,xy_from_rot(myrot,self.x,self.y)),
   -- } do
   --  local r,x,y=unpack(p)
   --  local tile=tile_hit(x,y)
   -- end
   apply_event(self,"on_machete","move",plrot2,xy_from_rot(plrot2,self.prevx,self.prevy))
   apply_event(self,"on_machete","move",plrot2,xy_from_rot(plrot2,self.x,self.y))
   apply_event(self,"on_machete","move",myrot,xy_from_rot(myrot,self.x,self.y))
  end,
  bump_tile=function(self,tile,x,y)
   if tile==T_VINE then
    mset(x,y,T_PATH)
    actor_x{x=x,y=y}
   end
  end,
  update=do_voxy,
 },...)
end

function actor_axe(...)
 return make_actor({
  z=-10,
  s=13,
  init=tool_init,
  update=do_voxy,
  move=move,
  swing=function(self,myrot,plrot,ignore_tiles)
   self:move(myrot,ignore_tiles)
   local plrot2=(plrot+2)%4
   apply_event(self,"on_axe","move",myrot,xy_from_rot(myrot,self.x,self.y))
   apply_event(self,"on_axe","move",plrot2,xy_from_rot(plrot2,self.x,self.y))
   apply_event(self,"on_axe","move",myrot,xy_from_rot(myrot,xy_from_rot(plrot2,self.x,self.y)))
  end,
  bump=function(self,ob,rot)
   if ob.on_axe then
    ob:on_axe(rot)
   elseif ob.move then
    ob:move(rot)
   end
  end,
  bump_tile=function(self,tile,x,y)
   if tile==T_TREE then
    mset(x,y,T_PATH)
    actor_x{x=x,y=y}
    actor_wood{x=x,y=y}
   end
  end,
 },...)
end

function actor_pick(...)
 return make_actor({
  z=-10,
  s=16,
  init=tool_init,
  update=do_voxy,
  move=move,
  swing=function(self,myrot,plrot,ignore_tiles)
   self:move(myrot,ignore_tiles)
   local plrot2=(plrot+2)%4
   apply_event(self,"on_pick","move",myrot,xy_from_rot(myrot,self.x,self.y))
  end,
  bump=function(self,ob,rot)
   if ob.on_pick then
    ob:on_pick(rot)
   elseif ob.move then
    ob:move(rot)
   end
  end,
  bump_tile=function(self,tile,x,y)
   if tile==T_ROCK then
    mset(x,y,T_PATH)
    actor_x{x=x,y=y}
    actor_stone{x=x,y=y}
   end
  end,
 },...)
end

function actor_flint(...)
 return make_actor({
  z=-10,
  s=19,
  init=tool_init,
  update=do_voxy,
  move=move,
  bump=function(self,ob,rot)
   if ob.on_flint then
    ob:on_flint(self,rot)
   elseif ob.move then
    ob:move(rot)
   end
  end,
 },...)
end

function actor_mag(...)
 return make_actor({
  z=-10,
  s=24,
  init=tool_init,
  update=do_voxy,
  move=move,
  bump=function(self,ob,rot)
   if ob.on_mag then
    ob:on_mag(self,rot)
   elseif ob.move then
    ob:move(rot)
   end
  end,
 },...)
end

function actor_wood(...)
 return make_actor({
  z=-10,
  s=12,
  move=move,
  update=do_voxy,
  on_axe=die,
  bump_tile=function(self,tile,x,y)
   if tile==T_WATER then
    mset(x,y,T_PATH)
    die(self)
   end
  end,
  on_flint=function(self,ob,rot)
   die(self)
   actor_fire{x=self.x,y=self.y}
  end,
 },...)
end

function actor_fire(...)
 return make_actor({
  z=-30,
  is_fire=true,
  ttl=TOTAL_LEN-DAY_LEN,
  ani={
   20,21,
  },
  clock_tick=function(self)
   self.ttl-=1
   if self.ttl<=0 then
    die(self)
   end
  end,
 },...)
end

function actor_gem(...)
 return make_actor({
  z=-10,
  s=25,
  move=move,
  update=do_voxy,
  on_mag=function(self,rot)
   pq"winner"
  end,
 },...)
end

function actor_stone(...)
 return make_actor({
  z=-10,
  s=15,
  move=move,
  update=do_voxy,
  on_pick=die,
  bump_tile=function(self,tile,x,y)
   if tile==T_WATER then
    mset(x,y,T_PATH)
    die(self)
   end
  end,
 },...)
end

function actor_x(...)
 return make_actor({
  z=-100,
  nohit=true,
  s=4,
  script=cocreate(function(self)
   wait(5)
   self.pal=parse"8=5"
   wait(5)
   die(self)
  end),
 },...)
end

function tool_init(self)
 self.cat=actor_cat{tool=self}
 self.x0,self.y0=self.x,self.y
end

function actor_cat(...)
 return make_actor({
  z=-30,
  nohit=true,
  ani={
   36,37,
  },
  vox=0,
  voy=0,
  -- tool=ob,
  -- item=nil,
  -- init=function(self)
  --  --stub
  -- end,
  seek=function(self,rot)
   for dr in all(split"0,1,-1,2") do
    if rnd()<0.85 then
     local sig=self.x+self.y
     self:move((rot+dr)%4,true)
     if sig~=self.x+self.y then
      --we moved! yay, break
      break
     end
    end
   end
  end,
  move=function(self,rot,...)
   move(self,rot,...)
   if rot==0 then
    self.ani.flpx=false
   elseif rot==2 then
    self.ani.flpx=true
   end
  end,
  bump=noop, -- can't push anything
  clock_tick=function(self)
   self.timer-=1
   if self.timer==0 then
    if self.tool.x>=(dev_spawn_cat and 2 or 8) then
     self.x,self.y=self.tool.x,rnd{-1,worldh}
    else
     self.timer=6
    end
   end

   local SPOOK_D2=2
   self.spook=dist2(self.x-pl.x,self.y-pl.y)<=SPOOK_D2
  end,
  spookwait=function(self,t)
   for i=1,t do
    if self.spook then
     -- pq"spooked"
     return true
    end
    yield()
   end
  end,
  set_item=set_item,
  script=cocreate(function(self)
   local tool=self.tool
   ::start::
    self.x,self.y,self.timer=-1,-1,dev_spawn_cat and 1 or 32
    self:set_item()

    while self.timer>0 do
     --wait for timer
     yield()
    end
    
    for i=1,30 do
     --prowling
     -- pq("prowl",i,self.x,self.y)
     while not do_voxy(self) do 
      yield()
     end
     if self:spookwait(60) then
      break
     end
     if rnd()<0.1 and not dev_spawn_cat then
      -- pq"rest"
      local speed=self.ani.speed
      self.ani.s,self.ani.speed=38,1000
      wait(rnd(100)+300)
      self.ani.speed=speed
     end
     local rot,arrived=get_rot_from_diff(tool.x-self.x,tool.y-self.y)
     if arrived then
      self:set_item(tool)
      break
     else
      self:seek(rot)
     end
    end

    local i=3
    while i>0 do
     --run away
     -- pq("run!",i)
     while not do_voxy(self) do 
      yield()
     end
     wait(20)
     local rot=get_rot_from_diff(self.x-pl.x,self.y-pl.y)
     self:seek(rot)
     -- if not inbounds(self.x,self.y) then
     --  i=0
     -- else
     if offscreen(self.x,self.y) then
      i-=1
     else
      i=3
     end
    end

    -- drop tool at start
    if self.item==tool then
     while not offscreen(tool.x0,tool.y0) do
      yield()
     end
     local ob=hit(tool.x0,tool.y0)
     if ob then
      die(ob)
     end
     tool.x,tool.y=tool.x0,tool.y0
    end
   goto start
  end),
 },...)
end

-- function actor_swipe(...)
--  return make_actor({
--   z=-100,
--   nohit=true,
--   s=4,
--   script=cocreate(function(self)
--    wait(5)
--    self.ani.pal=parse"8=5"
--    wait(5)
--    die(self)
--   end),
--   draw=function(self)
--    local x0,y0=self.x,self.y
--    pal(self.ani.pal or {})
--    spr12(4,toscreen(xy_from_rot(self.rot1,x0,y0)))
--    spr12(4,toscreen(xy_from_rot(self.rot2+2,x0,y0)))
--    spr12(4,toscreen(xy_from_rot(self.rot1+2,xy_from_rot(self.rot2+2,x0,y0))))
--    unpal(self.ani.pal or {})
--   end,
--  },...)
-- end

function get_rot_from_diff(dx,dy)
 local ax,ay=abs(dx),abs(dy)
 local arrived=ax+ay==1
 if ay<ax then
  return (dx<0 and 2 or 0),arrived
 else
  return (dy<0 and 1 or 3),arrived
 end
end
function move(self,rot, ignore_tiles)
 local dx,dy=rotx[rot],roty[rot]
 local nx,ny=self.x+dx,self.y+dy

 local ob=hit(nx,ny)
 if ob then
  if self.bump then
   self:bump(ob,rot)
  elseif ob.move then
   ob:move(rot)
  end
 end

 local tile=hit_tile(nx,ny)
 if tile
 and ignore_tiles
 and tile~=T_WATER
 then
  tile=nil
 end
 if tile and self.bump_tile then
  self:bump_tile(tile,nx,ny)
 end

 if tile
 or hit(nx,ny)
 or (not ignore_tiles and not inbounds(nx,ny))
 then
  self.vox,self.voy=_12/2*dx,_12/2*dy
 else
  self.prevx,self.prevy,self.x,self.y=self.x,self.y,nx,ny
  self.vox,self.voy=-_11*dx,-_11*dy
 end
 self.lastrot=rot

 local item=self.item
 if item then
  local dx,dy=self.prevx-item.x,self.prevy-item.y
  for r=0,3 do
   if rotx[r]==dx and roty[r]==dy then
    if rot~=r and item.swing then
     item:swing(r,rot,true)
    else
     item:move(r,true)
    end
    return -- avoid set_item()
   end
  end
  self:set_item()
 end
end

-- moves self.vox->0 and self.voy->0
-- returns whether they are at 0
function do_voxy(self)
 local spd=buts_waiting() and 2
  or 1
 local done=true
 if self.vox then
  self.vox=approach(self.vox,0,spd)
  done=done and self.vox==0
 end
 if self.voy then
  self.voy=approach(self.voy,0,spd)
  done=done and self.voy==0
 end
 return done
end

---

function actor_(...)
 return make_actor({
  z=-10,
  s=0,
  init=function(self)
   --stub
  end,
  -- move=move,
  -- bump=function(self,ob)
  -- 
  -- end,
  -- bump_tile=function(self,tile,x,y)
  -- 
  -- end,
  update=function(self)
   if do_voxy(self) then
    --stub
   end
  end,
  script=cocreate(function(self)
   while 1 do
    --stub
    yield()
   end
  end),
  draw=function(self)
   --stub
   draw_s(self)
  end,
 },...)
end

function make_(...)
 return merge_into({
  --stub
 },...)
end
