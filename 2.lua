-- helper utils

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

function cprintcj(text,x,y)
 return x-strwidth(tostr(text))\2,y
end

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

normpalette=arr0(0,split"1,2,3,4,5,6,7,8,9,10,11,12,13,14,15")
altpalette=arr0(0x80,split"0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f")
fade_pal=split"0,1,1,2,1,13,6,4,4,9,3,13,1,13,14"

function unpal(p)
 for k,v in pairs(p) do
  pal(k,k)
 end
end

function nocam(f)
 return function(...)
  local cx,cy=camera()
  f(...)
  camera(cx,cy)
 end
end

--
-- pico-8 stuff
--

_last_ust_time=0
function update_screenshot_title()
 function lpad(s,n)
  s=tostr(stat(s))
  while #s<n do
   s="0"..s
  end
  return s
 end
 if time()-_last_ust_time>=1 then
  _last_ust_time=time()
  extcmd("set_filename",qf("%_%_%_%T%_%_%",
   "deep",
   lpad(90,4),lpad(91,2),lpad(92,2),
   lpad(93,2),lpad(94,2),lpad(95,2)
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

function rndr(a,b)
 if b==nil then a,b=0,a end
 return rnd(b-a)+a
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

function build_palt(...)
 local bits=0
 for c in all{...} do
  bits|=1<<(15-c)
 end
 return bits
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
   print("\^c0\15")
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
  local t=mid(_fade_t or fade_t,1)
  local bwpoke="0x5f10,0,1,1,0x82,0x82,0x82,0x81,0x80,0x80,0x81,0x80,0x80,0x81,0x80,0x81,0x80"
  poke(unpack(split(
      t<0.16 and daypoke
   or t<0.32 and duskpoke
   or t<0.48 and nightpoke
   or bwpoke)))
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
