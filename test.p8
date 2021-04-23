pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
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
dev_mouse=dev
dev_pal_persist=dev
--dev_rng={0x5438.c744,0xfe04.4447}

function dev_init()
 menuitem(2,"palette",init_pal)
 if dev_pal_persist then
  poke(0x5f2e,1)
 end
 if dev_mouse then
  poke(0x5f2d,1) --enable mouse
 end
 
 if dev_rng then
  restore_rng(unpack(dev_rng))
 end
 local rng1,rng2=rng_state()
 pqf("{%,%}",tostr(rng1,1),tostr(rng2,1))
end

function _init()
 printh("---")
-- m_pal.cols={[0]=
--  0x00,0x01,0x02,0x80,
--  0x04,0x05,0x06,0x07,
--  0x84,0x85,0x86,0x83,
--  0x0c,0x0d,0x8c,0x8d,
-- }
-- pal(m_pal.cols,1)

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

--
--function m_play:test_collision(a1,a2)
-- return rect_collide(
--  a1.x+a1.ox,a1.y+a1.oy, a1.w,a1.h,
--  a2.x+a2.ox,a2.y+a2.oy, a2.w,a2.h)
--end
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


-->8
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
 do_oxy

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
   if do_oxy(self) then
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
	   self.ox,self.oy=-8*dx,-8*dy
	  end
  end,
  draw=function(self)
		 draw_s(self)
   rectfillwh(self.x*8,self.y*8,1,1,8)
  end,
 }
 hud=make_actor{
  z=-100,
  update=function(self)
   self.x,self.y=poll_mouse()
  end,
  draw=nocam(function(self)
   if dev then
		  print("dev",0,0,7)
		 end
	  spr(16,self.x-1,self.y-1)
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

-- moves self.ox->0 and self.oy->0
-- returns whether they are at 0
function do_oxy(self,spd)
 local done=true
 if self.ox then
  self.ox=approach(self.ox,0,spd)
  done=done and self.ox==0
 end
 if self.oy then
  self.oy=approach(self.oy,0,spd)
  done=done and self.oy==0
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
   if do_oxy(self) then
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

-->8
-- helper utils

--[[
these can all be deleted individually
this is the best file :)
]]

-- needs to be defined first
function arr0(zero,arr)
 arr[0]=zero
 return arr
end

--
-- strings/debugging
--

-- quote a single argument
-- like tostr, but works on tables
function q1(x)
 return type(x)=="table" and qt(x)
  or tostr(x)
end

-- quotes and returns its arguments
-- usage:
--  ?q("p.x=",x,"p.y=",y)
function q(...)
 --#todo are there nil issues with this?
 -- args.n=count() might help
 -- https://pico-8.fandom.com/wiki/count
 local args=pack(...)
 local s=""
 for i=1,args.n do
  s..=q1(args[i]).." "
 end
 return s
end

-- quotes a table
function qt(t,sep)
 local s="{"
 for k,v in pairs(t) do
  s..=q1(k)
  s..="="..q1(v)..(sep or ",")
 end
 return s.."}"
end

-- quotes an array
function qa(t)
 local s="{"
 for v in all(t) do
  s..=q1(v)..","
 end
 return s.."}"
end

-- sorta like sprintf (from c)
-- usage:
--  ?qf("p={x=%,y=%}",p.x,p.y)
function qf(...)
 local args=pack(...)
 local fstr=args[1]
 local argi=2
 local s=""
 for i=1,#fstr do
  local c=sub(fstr,i,i)
  if c=="%" then
   s..=q1(args[argi])
   argi+=1
  else
   s..=c
  end
 end
 return s
end

function pq(...)
 printh(q(...))
end

function pqf(...)
 printh(qf(...))
end

function strwidth(s)
 local l=0
 for i=1,#s do
  l+=1+boolint(ord(s,i)>=128)
 end
 return l*4
end

-- print center justified
function printcj(text,x,y,col)
 text=tostr(text)
 local w=strwidth(text)
 print(text,x-w\2,y,col or color())
end

-- i is an in-between-chars pointer
-- this is not the same sort of
-- number sub() uses
function splice(str,i,n,new)
 return sub(str,1,i)..(new or "")..sub(str,i+n+1)
end
--assert(splice("hello",0,1,"b")=="bello")
--assert(splice("hello",1,1)=="hllo")
--assert(splice("hello",4,1,"b")=="hellb")
--assert(splice("hello",2,3,"at")=="heat")

function oprint(msg,x,y,cfront,cback)
 print(msg,x+1,y+1,cback or 0)
 print(msg,x,y,cfront or 7)
end

function oprint8(msg,x,y,cfront,cback)
 for i=0,7 do
  print(msg,x+dirx[i],y+diry[i],cback)
 end
 print(msg,x,y,cfront)
end

function ospr8(s,x,y,c)
 local paldata=pack(peek(0x5f00,16))
 for i=0,15 do
  pal(i,c)
 end
 for i=0,7 do
  spr(s,x+dirx[i],y+diry[i])
 end
 poke(0x5f00,unpack(paldata))
 spr(s,x,y)
end

function tobin(x,friendly)
 local s="0b"
 for i=15,-16,-1 do
  s..=x&(1<<i)==0 and "0" or "1"
  if i==0 then
   s..=friendly and "\n ." or "."
  elseif i%4==0 then
   s..=friendly and " " or ""
  end
 end
 return s
end

-- want strings, not numbers
hex=arr0("0",split("123456789abcdef","",false))

--
-- overrides / pico-8 things
--

function _rectbounds(x,y,w,h,...)
 return x,y,x+max(0,w-1),y+max(0,h-1),...
end
function rectfillwh(...)
 rectfill(_rectbounds(...))
end
function rectwh(...)
 rect(_rectbounds(...))
end

function rectfillborder(x,y,w,h,b,cborder,cmain)
 if b<0 then
  b*=-1
  x-=b
  y-=b
  w+=b*2
  h+=b*2
 end
 rectfillwh(x,y,w,h,cborder)
 rectfillwh(x+b,y+b,w-b*2,h-b*2,cmain)
end

function dot(x,y,c)
 rect(x,y,x,y,c)
end

-- e.g. enum"foo,bar,baz" sets
-- foo=1,bar=2,baz=3 (globally!)
-- returns a index/lookup table
function enum(str)
 local index={}
 for i,name in ipairs(split(str,"\n")) do
  _ENV[name]=i
  index[i]=name
 end
 return index
end

normpalette=arr0(0,split"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15")
altpalette=arr0(0x80,split"0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f")
palbw=arr0(0,split"1,1,5,5,5,6,7,13,6,7,7,6,13,6,7")

function unpal(p)
 for k,v in pairs(p) do
  pal(k,k)
 end
end

--
-- pico-8 stuff
--

_mouse_buttons=0
_mouse_buttons_last=0
function update_mouse()
 _mouse_buttons,
 _mouse_buttons_last
 =
 stat(34),
 _mouse_buttons
end
lmb=0x1
rmb=0x2
mmb=0x4
function mbtn(mb)
 return _mouse_buttons&mb~=0
end
function mbtnp(mb)
 return mbtn(mb)
  and _mouse_buttons_last&mb==0
end
function mbtnr(mb)
 return not mbtn(mb)
  and _mouse_buttons_last&mb~=0
end

function poll_mouse()
 -- returns x,y,wheel
 return stat(32),stat(33),stat(36)
end

btn_press,
btn_down,
btn_release=0x1,0x2,0x4
function mbtn_info(mb)
 return
  boolint(mbtnp(mb),btn_press)
  |boolint(mbtn(mb),btn_down)
  |boolint(mbtnr(mb),btn_release)
end

function pq_btn()
 local any=false
 for pl=0,1 do
	 for b=0,6 do
	  if btn(b,pl) then
	   if not any then
	    any=true
	    pq"pq_btn:"
	   end
	   pqf(" btn(%,%)",b,pl)
	  end
	 end
	end
end

_last_ust_time=0
function update_screenshot_title()
 if time()-_last_ust_time>=1 then
  _last_ust_time=time()
  extcmd("set_filename",qf("%_%_%_%t%_%_%",
   "drawcelot",
   stat(90),stat(91),stat(92),
   stat(93),stat(94),stat(95)
  ))
 end
end

--
-- math
--

function divmod(x,y)
 return x\y,x%y
end

function sgn0(x)
 return x==0 and 0 or sgn(x)
end

function approach(x,target,delta)
 delta=delta or 1
 return x<target and min(x+delta,target) or max(x-delta,target)
end

function xor(a,b)
 return (a or b) and not (a and b)
end

function boolint(b,v)
 return b and (v or 1) or 0
end

function lerp(a,b,t)
 return a+(b-a)*t
end

function ilerp(a,b,x)
 -- returns t such that x=lerp(a,b,t)
 return (x-a)/(b-a)
end

function ease_exp(t)
 return 2^(-10*t)
end

function ease_back(t)
 local c1=1.70158;
 local c3=c1+1;
 return c3*t^3-c1*t^2
end

function round(x)
 return (x+0.5)\1
end

function align(n,a)
 -- assert a is a power of 2
 -- assert n is an integer
 return n&~(a-1)
end
--assert(align(0,4)==0)
--assert(align(1,4)==0)
--assert(align(2,4)==0)
--assert(align(3,4)==0)
--assert(align(4,4)==4)
--assert(align(13,1)==13)
--assert(align(13,2)==12)
--assert(align(13,4)==12)
--assert(align(13,8)==8)
--assert(align(13,16)==0)

--
-- functionalish stuff
--

f_id=function(x) return x end
noop=function() end

function curry(f,...)
 local args0={...}
 return function(...)
  return f(unpack(concat(args0,{...})))
 end
end

function fmap(table,f)
 local res={}
 for i,v in pairs(table) do
  res[i]=f(v)
 end
 return res
end

-- arr could be a general table here
function filter(arr,f)
 local res={}
 for i,v in pairs(arr) do
  if (f(v)) add(res,v) 
 end
 return res
end

function _func_or_elem_finder(f)
 return type(f)=="function"
  and f
  or function(x) return x==f end
end

function fall(table,f)
 f=_func_or_elem_finder(f)
 for v in all(table) do
  if (not f(v)) return false
 end
 return true
end

function fany(table,f)
 f=_func_or_elem_finder(f)
 for v in all(table) do
  if (f(v)) return true
 end
 return false 
end

function find(arr,f)
 f=_func_or_elem_finder(f)
 for i,v in ipairs(arr) do
  if (f(v)) return v,i
 end
-- return nil,nil
end

--
-- table/array utils
--

includes=fany

-- concat two arrays together
function concat(...) 
 local t={}
 local args={...}
 for table in all(args) do
  for val in all(table) do
   add(t,val)
  end
 end
 return t
end

function merge_into(obj,...)
 -- careful that both inputs
 -- are either shallow or
 -- single-use!
 -- e.g. def={x={0}} is
 -- a bad idea because
 -- merge(def,{}).x[1]=1 will
 -- modify def.x too!
 local tables={...}
 for t in all(tables) do
  for k,v in pairs(t) do
   obj[k]=v
  end
 end
 return obj
end
function merge(...)
 return merge_into({},...)
end

clone=merge

function parse_into(obj,str,mapper)
 for str2 in all(split(str)) do
  local parts=split(str2,"=")
  assert(#parts==2)
  local k,v=unpack(parts)
  obj[k]=mapper and mapper(k,v) or v
 end
 return obj
end
function parse(...)
 return parse_into({},...)
end

function sum(arr)
 local res=0
 for v in all(arr) do
  res+=v
 end
 return res
end


function sort(arr,f)
 f=f or f_id
 for i=1,#arr do
  for j=i+1,#arr do
   if f(arr[j])<f(arr[i]) then
    arr[i],arr[j]=arr[j],arr[i]
   end
  end
 end
end

function shuffle(arr)
 -- fisher-yates
 for i=#arr,2,-1 do
  local j=1+rnd(i)\1
  arr[i],arr[j]=arr[j],arr[i]
 end
end

function choose_weighted(opts)
 -- given opts that looks like {
 --  ch_ground=0.3,
 --  ch_key=0.1,
 --  ch_ladder=0.6,
 -- }, returns a key,
 -- weighted based on vals
 local sum=0
 for k,v in pairs(opts) do
  sum+=v
 end
 local rng=rnd()*sum
 for k,v in pairs(opts) do
  rng-=v
  if rng<0 then
   return k
  end
 end
 assert(false)
end

function rect_collide(x0,y0,w0,h0,x2,y2,w2,h2)
 local x1,y1,x3,y3
 x0,y0,x1,y1=_rectbounds(x0,y0,w0,h0)
 x2,y2,x3,y3=_rectbounds(x2,y2,w2,h2)
 return has_overlap(x0,x1,x2,x3)
  and has_overlap(y0,y1,y2,y3)
end
function has_overlap(x0,x1,x2,x3)
 assert(x0<=x1)
 assert(x2<=x3)
 return x1>=x2 and x3>=x0
end

function rng_state()
 return peek4(0x5f44,2)
end
function restore_rng(...)
 poke4(0x5f44,...)
end

function clear_cartdata()
 memset(0x5e00,0,64)
end

function log_cartdata(msg,half)
 cls()
 color(7)
 if (msg) print(msg)
 s=""
 for i=0,half and 31 or 63 do
  s..=tostr(dget(i),1).." "
  if i%2==1 then
   ?qf("%%: %",i<10 and " " or "",i-1,s)
   s=""
  end
  if i%32==31 then
   stop()
  end
 end
end

function minimode(enable)
 if enable==nil then
  return peek(0x5f2c)&3==3
 else
  local val=enable and 3 or 0
  poke(0x5f2c,val)
 end
end

function lowpass(enable)
 -- set lowpass filter on music
 -- useful for pause menus
 poke(0x5f43,
  enable and 0b1111 or 0)
end

--
-- entity/sprite stuff
--

-- auto-animates any object with
-- a .s member, using its .ani array
function update_ani(ani)
 if not ani then return end
 ani.f=ani.f or 1
 ani.subf=ani.subf or 1
 ani.speed=ani.speed or 30
 ani.s=ani.s or ani[ani.f]

 ani.subf+=1
 if ani.subf>ani.speed then
  ani.subf=1
  ani.f=1+ani.f%#ani
  ani.s=ani[ani.f]
 end
end

-- x,y: 8-scaled world pos
-- ox,oy: 1-scaled animation offset
-- px,py: 1-scaled sprite pivot
function draw_s(self,s)
 local ani=self.ani or self
 palt(ani.palt)
 local s,w,h,flp=s or ani.s,ani.w or 1,ani.h or 1,ani.flp
 local hsw,hsh=4*w,4*h
 local px,py=ani.px or hsw,ani.py or hsh
 if flp then
  px=8*w-px
 end
 local x,y=
  self.x*8+(self.ox or 0)-(px-hsw),
  self.y*8+(self.oy or 0)-(py-hsh)
 spr(s,x,y,w,h,flp)
-- rectwh(x,y,w*8,h*8,8)
 palt()
end

function build_palt(...)
 local bits=0
 for c in all{...} do
  bits|=1<<(15-c)
 end
 return bits
end

--
-- benchmarking
--

function bench0()
 _bench0,_bench1,_bench2=stat(99),stat(1),stat(2)
 pq("bench start")
end
function bench1()
 local d0,d1,d2=stat(99)-_bench0,stat(1)-_bench1,stat(2)-_bench2
 pq("bench end")
 pq("  ",d0,"kb")
 pq("  ",d1*100\1,"% cpu")
 pq("  ",d2*100\1,"% cpu (sys)")
end

_cpu_flag=0
function cpu_flag(x)
 _cpu_flag+=1
 if x then
  _cpu_flag=0
  pq("===")
 end
 pq(_cpu_flag,"stat(1):",stat(1)*100)
end

--
-- scripting
--

scripts={}
function script_add(f)
 add(scripts,type(f)=="thread" and f or cocreate(f))
end
function script_update()
 for s in all(scripts) do
  coupdate(s)
  if costatus(s)=="dead" then
   del(scripts,s)
  end
 end
end

function coupdate(coro,...)
 if costatus(coro)=="suspended" then
  local _,msg=coresume(coro,...)
  if msg then
   cls(0)
   cursor(0,0)
   color(7)
   local fullmsg=trace(coro,msg)
   pq(fullmsg)
   stop(fullmsg)
   assert(false,"coroutine error")
  end
 end
end
function wait(n)
 for i=1,n do
  yield()
 end
end
function wait_btnp(b)
 while not btnp(b) do
  yield()
 end
 yield()
end
function wait_f(f)
 local i=0
 while not f(i) do
  yield()
  i+=1
 end
end
function wait_btnp_timeout(b,n)
 for i=1,n do
  if btnp(b) then
   return true
  end
  yield()
 end
 return false
end

--
-- fade
--

fade_t=0 --set this to 1 in init
function applyfade(mode,_fade_t)
 local p,kmax,col,k=flr(mid(_fade_t or fade_t,1)*100)
 for j=1,15 do
  col=j
  kmax=(p+j*1.46)\22
  for k=1,kmax do
   col=fade_pal[col]
  end
  pal(j,col,mode or 1)
 end
end
function check_fade(spd)
 if fade_t>0 then
  fade_t-=spd or 0.04
  applyfade()
 end
end
function fadeout(spd)
 while fade_t<1 do
  fade_t+=spd or 0.04
  applyfade()
  flip()
 end
end
function sleep(n)
 while n>0 do
  n-=1
  flip()
 end
end

-->8
-- palette picker

--[[
delete entirely to save space
once you've made your game palette

todo: update this to upd,drw method
]]

function init_pal()
-- upd,drw=upd_pal,drw_pal
end
function upd_pal()
end
function drw_pal()
end

m_palsel={
 x=0,
 y=0,
 alt=false,
 onenter=function(me)
  me:touchpalette()
  minimode(false)
 end,
 touchpalette=function(me)
  pal(me.alt and altpalette or normpalette,1)
 end,
 update=function(me)
  if btnp(4,1) then
   me.alt=not me.alt
   me:touchpalette()
  end
  if btnp(🅾️) then
   next_mode=m_pal
  end
  if btnp(❎) then
   m_pal:setcurrent(
    me:getcurrent())
   next_mode=m_pal
  end
  update_pal(me)
 end,
 draw=function(me)
  cls()
   printcj("color picker",64,4,7)
   print("❎ to choose",32,116)
   print("tab to change mood",32,122)
  
   local w=24
   local h=24
   for j=0,3 do
    for i=0,3 do
     local col=pal_index(i,j)
     local x=16+i*w
     local y=16+j*h
     rectfillwh(x,y,w,h,col)
     if i==me.x and j==me.y then
      rectwh(x,y,w,h,7)
      rectwh(x+1,y+1,w-2,h-2,1)
     end
    end
   end
 end,
 getcurrent=function(me)
  local base=me.alt and 0x80 or 0
  return base+pal_index(me.x,me.y)
 end,
}

m_pal={
 x=0,
 y=0,
-- cols=nil,--0 indexed; set in onenter
 xdown=false,
 dragging=false,
 onenter=function(me)
  if not me.cols then
   me.cols=clone(normpalette)
  end
  me:touchpalette()
  me.xdown=false
  me.dragging=false
  minimode(false)
 end,
 touchpalette=function(me)
  me:clipcode()
  pal(me.cols,1)
 end,
 update=function(me)
  if btnp(4,1) then
   init_game()
   return
  end
  if btnp(❎) then
   me.xdown=true
  elseif not btn(❎) then
   if me.xdown and not me.dragging then
    next_mode=m_palsel
   end
   me.xdown=false
   me.dragging=false
  end
  local old_i=pal_index(me.x,me.y)
  update_pal(me)
  local new_i=pal_index(me.x,me.y)
  
  if new_i~=old_i and me.xdown then
   me.dragging=true
   me.cols[old_i],me.cols[new_i]=
    me.cols[new_i],me.cols[old_i]
   me:touchpalette()
  end
 end,
 draw=function(me)
   cls()
   print("❎ to change, ❎+move to move",6,117,7)
   print("tab to return",6,123,7)
   local w=28
   local h=28
   for j=0,3 do
    for i=0,3 do
     local col=pal_index(i,j)
     local x=64-2*w+i*w
     local y=1+j*h
     rectfillwh(x,y,w,h,col)
     if i==me.x and j==me.y then
      rectwh(x,y,w,h,7)
      rectwh(x+1,y+1,w-2,h-2,1)
     end
    end
   end
 end,
 setcurrent=function(me,c)
  local i=pal_index(me.x,me.y)
  me.cols[i]=c
 end,
 clipcode=function(me)
  local s=" m_pal.cols={[0]="
  for i=0,15 do
   if i%4==0 then
    s=s.."\n  "
   end
   local c=me.cols[i]
   if c>=0x80 then
    s=s.."0x8"
    c-=0x80
   else
    s=s.."0x0"
   end
   s=s..hex[c]..","
  end
  s=s.."\n }\n"
  printh(s,"@clip")
  return s
 end,
}

function pal_index(x,y)
 return y*4+x
end

function update_pal(me)
 if btnp(⬅️) then me.x-=1 end
 if btnp(➡️) then me.x+=1 end
 if btnp(⬆️) then me.y-=1 end
 if btnp(⬇️) then me.y+=1 end
 me.x=mid(0,3,me.x)
 me.y=mid(0,3,me.y)
end

-->8
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

__gfx__
0000000000000000000cc000c22ccc22cccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000000000000000
00000000000cc00000ceee00244244442ccccccccc22ccc22ccccccc000000000000000000000000000000000000000000000000000000000000000000000000
0070070000ceee0000444400244444444cccccccc244244442cccccc000000000000000000000000000000000000000000000000000000000000000000000000
000770000044440000444400c24444444cccccccc244444444cccccc000000000000000000000000000000000000000000000000000000000700707007007007
000770000044440008b88b80cc44440440cccccccc24444444cccccc000000000000000000000000000000000000000007007000070007000777700707777070
0070070008b88b8000bbbb00ccc4444444ccccccccc44440440ccccc000000000000000000000000000000000000000007777000077770007171777071717770
0000000000bbbb0000b00b00ccc2444eeccccccccccc4444444ccccc000000000000000000000000000000000000000076767770767677700777777007777770
0000000000b00b0000b00b00cc442222ccccccccccc42444eecccccc000000000000000000000000000000000000000007777777077777770060707006070670
220000000020000000000000cc444444cccccccccc4442222ccccccc000000000000000000000000000000000000000000000000660000000000000000000000
272000000272000000000000c2424444cccccccccc442444cccccccc000000000000000000000000000000000000000006600000060660000000000000000000
277200000272222002222220c2424244ccccccccc2442424cccccccc000000000000000000000000000000000000000000606600600060000700700000000000
277620000272726202727262cc422444ccccccccc2444224cccccccc000000000000000000000000000000000000000006000600660600000777700007007000
276200002277766222777662ccc4442ccccccccccc444444cccccccc000000000000000000000000000000000000000006606000000660007676700707777070
022620002777776227777762ccc4422cccccccccccc2244ccccccccc000000000000000000000000000000000000000000006600000000000777770776767707
000200000222762002227620cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000067777707777777
000000000002762000027620cccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000067777000677770
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000070666670770656560000000000000000000557777700000000000000000000000044444444000000000000000000000000000000000000000000000000
00000770666667770656565000555ff0000fff00055577770000000000fff0000000000044344444000008000010000000000000000000000000000000000000
000067500ddd6d5006565650055555ff055ffff005555577000444000ff3ff0000f000004444443400008a8001e1000000000000000000000000000000000000
000666500dd65650005656500115555555ffff1f05555555004fff4003ffff0000f00000443443440000b800001b000000000000000000000000000000000000
0006665006665650065656501111155515555fff05555555004f4f4044f344400040000043344444000bb000000b000000000000000000000000000000000000
000656500656565006565650111111111555555f066666660044f440044434000240f00054444444b00b000000bb0b0000000000000000000000000000000000
0066565006565650065656001105111f115555550666666603344340044444000224ff00443454440b0b00b0b0b000b000000000000000000000000000000000
006656500656565006565650011055000111055000000000330330330443340002444f0044344444000000000000000000000000000000000000000000000000
00665650066656500000000000000000000000000000000000000000000fff0002444f00033333000000066000050660000000000fffffffffff6ff000000000
0666565000665650000000000000000000000000003420000000000000ffff0002444f0003338300057000600700000000400000ff6444446444674f00000f00
0666565000665650000000000000000000004400033044000000000000f43f000242440300313300566005006605606500400000f46444746444777f00000400
0666665006666650660000000444224444222444444224224422440000f3f4000244423333333333060665600005560500400000ff4447774444474f00000400
0d66665006666600666600004fff4444444444442444444444424440044444000444440f3834381300006060006755000044ff000fffff7ffffffff0004ff400
0dd666600dd6666066d550004f4f444442244444444442444444444000443440044244f033841833055000056000606700444f00002200000000220000444400
ddddd66dddddd66d66d666002fff4424444442444442444444442420004444002444444033144330066067606560655000420400004200000000420000420400
666666666666666666dd666d02222222222222222222222222222200044344402244240000044000000066000060000000400400704270000000420000400400
000000000000000000000000000000000055000000000000000000000000000002244f0000330030006600000700500011111111111111111111111111111111
0d666670000666700000ddd666677700005500000002444442444444424220000224240003833333070507505560057011111111111111111111111111111111
066776600676766000ddd77676755700555666000004400000042000000440000244440003331333655066660605700611dd1111111dd111111d111111ddd111
065555600655656000dd666666666600555555000004442444444444444440000242420001338330066000500006570611111111111111111111111111111111
066666600666666000665655565566000055000000094000000940000009200002424f003341831300005700000066001111dd111111ddd111111dd111111d11
065555d0065655d00066666556566600005100000009400000094000000940000222440033341383075066000570007011111111111111111111111111111111
66666666d6666666666666666666666605551500000940000009400000094000022424403334433006656550066606671d1111111dd1111111d111111d111111
dddd666666dd66dddddd666666ddddd6ddd55dd00000000000000000000000002202402203044000006006000000055011111111111111111111111111111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888888888888800000000000000000088888888888888000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888888888888888000000000000008888888888888888880000000000000000000000000000000000000000000000000000000000000000000000
00000008888888888888888888880000000000088888888888888888888800000000000000000000000000000000000000000000000000000000000000000000
00000888888888888888888888880000000008888888888888888888888800000000000000000000000000000000000000000000000000000000000000000000
0000088888888888cccccc88888880000000088888888888aaaaaa88888880000000000000000000000000000000000000000000000000000000000000000000
0000088888888800ccccccc8888880000000088888888800aaaaaaa8888880000000000000000000000000000000000000000000000000000000000000000000
000088888cccccc0ccccccc888888800000088888aaaaaa0aaaaaaa8888888000000000000000000000000000000000000000000000000000000000000000000
000088888cccccc0ccccccc888888800000088888aaaaaa0aaaaaaa8888888000000000000000000000000000000000000000000000000000000000000000000
000088888cccccc0ccccccc888888800000088888aaaaaa0aaaaaaa8888888000000000000000000000000000000000000000000000000000000000000000000
000088888cccccc00cccccc888888800000088888aaaaaa00aaaaaa8888888000000000000000000000000000000000000000000000000000000000000000000
000088888cccccc00000000888888800000088888aaaaaa000000008888888000000000000000000000000000000000000000000000000000000000000000000
00008888800000000000ccccc888800000008888800000000000aaaaa88880000000000000000000000000000000000000000000000000000000000000000000
00008888800000000000ccccc888800000008888800000000000aaaaa88880000000000000000000000000000000000000000000000000000000000000000000
0000888880000000000cccccc88800000000888880000000000aaaaaa88800000000000000000000000000000000000000000000000000000000000000000000
00008888cccccc0000ccccccc888000000008888aaaaaa0000aaaaaaa88800000000000000000000000000000000000000000000000000000000000000000000
00008888ccccccccccccccccc888000000008888aaaaaaaaaaaaaaaaa88800000000000000000000000000000000000000000000000000000000000000000000
00008888ccccccccccccccccc888000000008888aaaaaaaaaaaaaaaaa88800000000000000000000000000000000000000000000000000000000000000000000
00008888cccccccccccccccc8888000000008888aaaaaaaaaaaaaaaa888800000000000000000000000000000000000000000000000000000000000000000000
00008888cccccccccccccccc8880000000008888aaaaaaaaaaaaaaaa888000000000000000000000000000000000000000000000000000000000000000000000
0000888888ccccccccccccc8888000000000888888aaaaaaaaaaaaa8888000000000000000000000000000000000000000000000000000000000000000000000
000008888888ccccccccc88888800000000008888888aaaaaaaaa888888000000000000000000000000000000000000000000000000000000000000000000000
00000088888888888888888888000000000000888888888888888888880000000000000000000000000000000000000000000000000000000000000000000000
00000008888888888888888880000000000000088888888888888888800000000000000000000000000000000000000000000000000000000000000000000000
00000000088888888888888800000000000000000888888888888888000000000000000000000000000000000000000000000000000000000000000000000000
__label__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddmmdddmddddmdddddddmddddddddddmmddmdddmdddddddddddddddddddddmddddddddmdddddmmdmdddddddmdddmddmdddddddmdddddddddm
ddddddmddddmddddddmddddddddddddddmdmddddddmdddddmdddmdddddmddddddddddddddmdmddmdddmddddddddddmdddddddmdddddddddddmdmddmdmdddmdmd
dmdddddddmmddddddddddddddmdddddddmdddddddddmddmdddddddmddddmmddddddddddddmddddddmddddmddddmdddmddddddddddddmmdddddddddddmddddddd
mmdmdddddddmddddmddddmdmddddmdddddddddddddmddmmmmdddddmmdmddddddmdddmdddmddddddddddmdddddmmdmdmmddddddmddmmdddddddddmddddddddddm
dddddmddmddmddddddmmmdddddddddmdddmddddddmddddddmdmdddddddddddddmmddddddmddddddddmmddddddmdddddmdddmmdmddddmdmdmddmdddmddddddddm
ddddddddmdmmddmddddddddmdmdddmddmdmdddddddddddmddddmddddddddddddmddddmdddddddmddddddddddddmdddddmddddddmddddmddddddddddddmdddddd
ddddddddddddddddmddddmddddddddmddmddddmdddddddddddddddddddmdddddddddddddddddmddmdddmddddddmddddmmdddddddmddmmdmdddddddmddddddddd
mmddmdmdddddmddddddmdddddmdddddddddddddddddmddddmdddmdmddmdmmdddddmmdddddddddddmdmmddmddddddddddmmdmdmddmddddddddddddmmmddmddddd
dmdmdddddddddmddmdddddmddddddddddmddmdmdddddmmddmdddmdddddddmddddmdddddddddddddddddmmddddddddddddddmdddddddmdddddddddmdmddmmdmdd
ddmdddddddddmmddddmdddddddddddmddddddmdddddddmddmddddddmddddmdmddddmmdmmmmddddmdmddmddmdmdddmmddmmdddmmdmmddmdddddmdmdddddmdmddd
dddmddddddddmmddddmdddmmddmddddddddddddddmdddmmddddmddddddddddddddmddmdddddmdddddddmddmddmdddddddmdmdmddddddmddmddddddmmdddddddd
dddmdmdddddmddddmddmddmddddddddddmdddddmdddddmdddddmddmddddmddmddddddddddmdmddmdmdddmdmdddddmdddddddmdmddmmdmdddmdddddmddddddddd
dddddmdmdddddddddddmmddddddmdddmddddmddmddddmddddddddmdddmdddddmmddddddmddmdddddmdddddddmddmddddmddmmddddddddmdmdddddmddmddddddm
ddddmmdmddddmmdddmmdmdmddddddddddddddddddmdmddddmdddddmdmddddmddmdddddddddddddmddddddmddddddddmdddddddddmddmdmddddddddmdddmddddd
mdmdddmddmdddddmddmddddddddddddddddmdddmdmdddddmdddmddmddddddddddddmddddddddddddddmdmddddddddmdddddddmdmddddddddmddddddddddddmdd
ddddmdmdddmdmdmdmdddddmdddddddddddddddmddddmdddddddddddmddmddddddmdmmddddddmdddddddddddddddmddddddddddddddddmddddmddddddmmdmdddd
dmdmddddmddmddmdmdddddddmddddddddddddddddddddddmmddmdmddddddddddddddmddddmddddddddddmddddmdddddmddmdddmddddddmdddddmmmmdmddmdmdm
dmmmmdmddmddddmddddddddddmddddddmdmdddddddddddddddddmddddddddddmddddddmdddddmdddmmddddmdddmddddddmddddddddmmdddddddddmdddddmdddd
ddddmdmmdmdmdddddmddddmddddmddmmddddmddddddddmdddddmddddmdddddddddddddddmddmddddddmddddddddddddddmdmdddddddmddddmdddddmdddddmddd
ddddddmdmdddmddddddddmdddddddddddmdddddmdmdddddddddddddmmddmdddddddmdddddddddddddmmmdddmdddddmdddddddddmdddmdddmdddddmdmddmmdddd
dmddddmmdddddddddddddmddmdddddddddmdddmddddmddmddddddddddddddmddddmdddddddmmddddddmddddddddddddddmmddmmdddmddmdddddddddddmddmddd
ddddmdmddmdmdddddddddddmddddddddmddddddddddddddmdddddddddddddddddddmddmddddmdmdddddddddmmddddmdmddmdmmdddddddmdmdmddmddddddddddd
dmddddmmddmddddddddddddddmmddddddddddddmdddmddddddddmddddddmddmddmddddddddddddddddmmdddmmdddddddmdddddmmmdddmddmdddddmdddddddddd
ddddddmddddmddddddddddddddddddddmdmmdmdddddddddddddmmdddmdddmdddddmddddddddmddmmddddddmddddddmmddddmdmdddddmdddmmdddmmdddddmddmd
dddmddddddmddddddddddddmdmddmmdddddmdmddddddddmdddmdddddmddddddmddddddmdddddddddddddmdddddmdddddddddddddddddddddddmdddddmdmddddd
ddddddddddmddddmddddmdddddddmddddddddddddddddddddddddddddddddddmddmdddddmddmdddddddddmdmdddddddmdmddddddddddddmddddddddmdddddddd
ddddddmddmddmddddmddddmmddddddmdmddddmddddddddddddddmdddmddddmdddddddddddddddmdmdmmddddmddddddmddddddmdddmdmddddmddmdmdddddmddmd
dddddddddddddddddddmddddddddddddddddddddddddddddmdddddmddddddddddmdddddddmddddmddmdddddddddmddddddddddddddddddmdddddmdddddmmdmdd
dddmdddmddmddmdddmddddddddddddmmddddddddddddddddddddddddmddmdmdmddmmddddddddddmmddddddddddmdddddmmdddmmddddmddddmdmmdddddddmmddd
ddddddddmdddddddddmdddddmddmmddddddmdddmddddddddddmdmdddddmddddddmdddddddddmdddmdddddmdddddddddmmdddddddddmdmddmdddmmdddddddmddm
dddddddddddmddddddmdddmdmmdddddddddddddddddddddddddddmdddddmddddddddddddddddmdddmddmddmddddmddddddddddddddddddddddmddmddddddddmd
ddddmddmddddddmddddddddddddmmddddddddddmdmddmddddddmddmddmdddddddmdmddddmddddddmmdddddddddmddmddddddddmddddmddddmdddddmddddddddd
dddddddmdddddddmdddmmddddddddddddddmmdddmddddddddddddddddmdddddmdddddddmdddddmdmddddddddmmddddmddddddddmdddmddddmdddddddmddddddm
dddmdmddddddddmddmmdmdmdmddddddmdddmdmdddmddddddmddddddddddddddmdddmdddddddddddddddddmddddddddmdddddddddddddddddmmddddddddmddmdd
ddddmmdddmdddmdddddddddddddddddddddddddddddmddmmmddddddddddddmddmddmmdddddddddmdmdddmdmdmdmddddddddddddddddddmddddmdddddddddddmd
dddddddmddmddddddddddmddddddddddddddddddmddddddddddmddddddmdddmdmddmdddddddddddddddddddddmddmddmdmdddddddddddddddmdmmdddddmddddd
ddddddddddddddddddddmdmdmddmdmdddddddddmddddmddddddmdddddddmdddmdddmdddddddddmdmdddmddmdddddddddmdddddddmddmddddddmddddmmddddmdd
ddmdddddmddmddddmmmdddddmddddddmmddddddddddddmddddmddddmdddddddddddmdmddmdddmddddmdddddddmdmmdddddddddddddmdmdddmddddddddddddmdd
dmdddddddddddmddddmddddddddmmdddddddddddmddmmddddddmddddddddmdddddmdmmddddmddddddddmdddddddddddddddddddddddddddddddmddddddmmdddm
dddddmddmdmddmdddddddmdddddddmmdddddddddddddmmmdmdddmddmddddddddddmmmdddddddddmdddddmdddddddddmddmmmddddmdmmdmdddddmdddmmdddmddd
ddddddddddmddmmdmdmddddmddddddmdddddmmddddmdddmddmddddddddddddddddddmmdddmmdddddmddmddddmmdmdddddmddddddddddddddddddddmddmdddddd
dddddddddmdddmdmdddddddddddddmddddddddmddddddmdddddddddmdmddddddmdddddddmddddddmddddmdddddddddddddddddddmddmmddddmdddddmdddddmdd
dddddddddddddddddmmmddmddddmddddmdddddddddddddddmdddmdddmdddddddmddddmdddddmddddddmdddmddddmdmdmddddddmddddddddddddmddddmddddddd
mdddmdddmdddmddddddddddddddddddddddddddmddddddddmdddmddddddddddmdmdddddddddmdddddddmmdmdddddddddddddddddddddddddmdmdddmdddddmddd
dddddddmdddddddddddddddmdddddddmddddmddddddmdddddddmdddddddddddmdmddmmddddddddddmdmdddddddddddddmddmdddddmddmddddmddddddmddmdddd

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000053006a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000006a6a000063656466000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6a6a6a00000000006a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000006a6a0000006a6a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006a000000006a6a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000006a6a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6a6a6a6a6a0059000000006a6a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005959595959006a6a6a6a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5900540054000059595959595959000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000059595959595900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
