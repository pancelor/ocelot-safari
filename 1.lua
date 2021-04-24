-- game

--[[
use actor_() as a template when
 making new actors
 
things the engine does:
 script
 ani (even without a draw call)
  w,h,palt,self.z,flp
 update
 init
 denit
 
other cool stuff:
 draw_s
 do_voxy

todo: collisions, hitl/hitf?
need to get more experience
 before baking it into a template
]]

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
 for b=0,3 do
  local mask=1<<b
  if btnr&mask>0 then
   local ix=_recent_ix(b)
   assert(ix,ix)
   if buts[ix].seen then
    -- pq("seen; release now",b)
    deli(buts,ix)
   else
    -- pq("not seen yet; release later",b)
    add(buts_del,buts[ix])
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

function load_actors()
 actor_machete{x=4,y=4}
 pl=actor_player{x=5,y=6}
 actor_vine{x=6,y=7}
 actor_vine{x=6,y=8}
 actor_vine{x=6,y=9}
 actor_vine{x=6,y=10}
 mouse=make_actor{
  x=0,
  y=0,
  s=16,
  z=-200,
  update=function(self)
   local lastx,lasty=self.x,self.y
   local mx,my,wheel=poll_mouse()
   self.x,self.y=mx,my
  end,
  draw=nocam(function(self)
   sspr(120,24,8,8,self.x-1,self.y-1)
  end),
 }
 hud=make_actor{
  z=-100,
  update=function(self)
  end,
  draw=nocam(function(self)
   if dev then
    print("dev",0,0,7)
   end
  end),
 }
 cam=make_actor{
  z=1,
  update=function(self)
   local cx,cy=pl.x,pl.y
   -- update camera
   camera(
    approach(%0x5f28,mid(cx*_12-64,worldw*_12-128)),
    approach(%0x5f2a,mid(cy*_12-64,worldh*_12-128))
   )
  end,
  draw=function(self)
   -- map()
   grid(10)
  end,
 }
end

function actor_player(...)
 return make_actor({
  z=-20,
  ani={
   1,
   palt=0,
  },
  -- item=nil,
  lastrot=0,
  init=function(self)
   self.prevx,self.prevy=self.x,self.y
  end,
  update=function(self)
   update_btns()

   if do_voxy(self) then
    -- handle items
    if btn(4) and not self.item then
     for dr in all{0,2,1,3} do
      local rot=(self.lastrot+dr)%4
      local item=hit(self.x+rotx[rot],self.y+roty[rot])
      if item and item.move then
       self.item=item
       break
      end
     end
    end
    if not btn(4) and self.item then
     self.item=nil
    end

    -- move
    local rot=poll_btns()
    if rot then
     self:move(rot)
    end
   end
  end,
  move=function(self,rot)
   move(self,rot)

   -- flp
   if rot==0 then
    self.ani.flpx=false
   elseif rot==2 then
    self.ani.flpx=true
   end

   local item=self.item
   if item then
    local dx,dy=self.prevx-item.x,self.prevy-item.y
    for r=0,3 do
     if rotx[r]==dx and roty[r]==dy then
      if rot~=r and item.swing then
       item:swing(r,rot)
      else
       item:move(r)
      end
      break
     end
    end
   end
  end,
 },...)
end

function apply_event(name,rot,x,y)
 local ob=hit(x,y)
 if ob and ob[name] then
  ob[name](ob,rot)
 end
 actor_x{x=x,y=y}
end

function actor_machete(...)
 return make_actor({
  z=-10,
  ani={
   2,
   palt=0,
  },
  init=function(self)
   --stub
  end,
  move=function(self,rot)
   move(self,rot)
  end,
  swing=function(self,myrot,plrot)
   self:move(myrot)
   apply_event("on_machete",myrot,xy_from_rot(plrot+2,self.prevx,self.prevy))
   apply_event("on_machete",myrot,xy_from_rot(plrot+2,self.x,self.y))
   apply_event("on_machete",plrot,xy_from_rot(myrot,self.x,self.y))
   -- actor_swipe{
   --  x=self.x,
   --  y=self.y,
   --  rot1=myrot,
   --  rot2=plrot,
   -- }
  end,
  bump=function(self,ob,rot)
   if ob.on_machete then
    ob:on_machete(rot)
    local x,y=xy_from_rot(rot,self.x,self.y)
    actor_x{x=x,y=y}
   elseif ob.move then
    ob:move(rot)
   end
  end,
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

function actor_vine(...)
 return make_actor({
  z=-10,
  on_machete=die,
  ani={
   3,
   palt=0,
  },
 },...)
end

function actor_x(...)
 return make_actor({
  z=-100,
  nohit=true,
  ani={
   4,
  },
  script=cocreate(function(self)
   wait(5)
   self.ani.pal=parse"8=5"
   wait(5)
   die(self)
  end),
 },...)
end

-- function actor_swipe(...)
--  return make_actor({
--   z=-100,
--   nohit=true,
--   ani={
--    4,
--   },
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

-- function move_towards(self,x,y)
--  local dx,dy=x-self.x,y-self.y
--  if abs(dy)<abs(dx) then
--   return self:move(dx<0 and 2 or 0)
--  else
--   return self:move(dy<0 and 1 or 3)
--  end
-- end
function move(self,rot)
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

 if hit(nx,ny) or not inbounds(nx,ny) then
  self.vox,self.voy=_12/2*dx,_12/2*dy
 else
  self.prevx,self.prevy,self.x,self.y=self.x,self.y,nx,ny
  self.vox,self.voy=-_11*dx,-_11*dy
 end
 self.lastrot=rot
end

-- given a screenpos, return a worldpos
function ppi(x,y)
 return (x+%0x5f28)\_12,(y+%0x5f2a)\_12
end

-- moves self.vox->0 and self.voy->0
-- returns whether they are at 0
function do_voxy(self,spd)
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
  ani={
   0,
   palt=0,
  },
  init=function(self)
   --stub
  end,
  -- move=move,
  -- bump=function(self,ob)
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
