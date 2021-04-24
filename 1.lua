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

function load_actors()
 pl=make_actor{
  x=8,
  y=8,
  z=-10,
--  ani={
--   3,5,
--   w=2,h=2,px=6,py=13,
--   palt=build_palt(12),
--  },
  ani={1,2},
  update=function(self)
   if do_voxy(self) then
    local dx,dy=0,0
    if btnp(0) then dx-=1 self.ani.flp=true end
    if btnp(1) then dx+=1 self.ani.flp=false end
    if btnp(2) then dy-=1 end
    if btnp(3) then dy+=1 end
    
    if btnp(5) then
     fadeout()
     init_gover()
    end
    local nx,ny=self.x+dx,self.y+dy
    self.x,self.y=nx,ny
    self.vox,self.voy=-8*dx,-8*dy
   end
  end,
  draw=function(self)
   draw_s(self)
   rectfillwh(self.x*8,self.y*8,1,1,8)
  end,
 }
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
  draw=function(self)
   spr(self.s,self.x-1,self.y-1)
  end,
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
    approach(%0x5f28,mid(8,cx,worldw-8)*8-64),
    approach(%0x5f2a,mid(8,cy,worldh-8)*8-64)
   )
  end,
  draw=function(self)
   map()
  end,
 }
end

-- given a screenpos, return a worldpos
function ppi(x,y)
 return (x+%0x5f28)\8,(y+%0x5f2a)\8
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

function nocam(f)
 return function(...)
  local cx,cy=camera()
  f(...)
  camera(cx,cy)
 end
end

---

function actor_(...)
 return make_actor({
  z=0,
  init=function(self)
   --stub
  end,
  hitl=hitl_misc,
  hitf=hitf_samepos,
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
