-- rng

function map_gen()
 gen_rnd()
 gen_adjust()
 gen_player_area()
 if dev_spawn_gem then
  mset(5,10,T_GEM)
 else
  mset(worldw-5,rndr(worldh/4,worldh*3/4)\1,T_GEM)
 end
end

function gen_player_area()
 local r=2
 for y=0,worldh-1 do
  r=mid(4,r+rnd(split"0,1,-1"))
  for x=0,r-1 do
   mset(x,y,T_PATH)
  end
 end
 local x0,y0=1,rndr(5,worldh-5)
 stamp(T_PATH,x0,y0-1,-1)
 stamp(T_PATH,x0,y0+1,-1)
 mset(x0,y0,T_PLAYER)
 mset(x0-1,y0-3,T_PICK)
 -- mset(x0,  y0-2,T_MAG)
 mset(x0+1,y0-2,T_AXE)
 mset(x0-1,y0+3,T_FLINT)
 -- mset(x0,  y0+2,T_)
 mset(x0+1,y0+2,T_MACHETE)
end

function gen_rnd()
 memset(0x2000,0,0x1000)
 for y=0,worldh-1 do
  for x=0,worldw-1 do
   local r=rnd()
   local t=r<0.4 and T_VINE
    or r<0.9 and T_TREE
    or T_ROCK
   mset(x,y,t)
  end
 end
end

function stamp(tile,x,y,bits, chance)
 -- 0b000
 --   000
 --   000
 chance=chance or 1
 for i=0,8 do
  if bits&(1<<(8-i))>0 and rnd()<chance then
   mset(x+i%3-1,y+i\3-1,tile)
  end
 end
end

function drifter(p0,pmin,pmax)
 return {
  p=p0,
  pmin=pmin,
  pmax=pmax,
  get=function(self)
   local res=self.p
   local dp=(self.pmax-self.pmin)/10
   self.p=mid(
    self.pmin,self.pmax,
    self.p+rndr(-dp,dp)
   )
   -- pq(res)
   return res
  end
 }
end
 
function gen_adjust()
 local C_ROCK,C_WATER,C_PATH,C_VINE1,C_VINE2=0.3,0.8,0.5,0.35,0.4

 --rocks
 for cell in all(mapfindall(T_ROCK)) do
  stamp(T_ROCK,cell.x,cell.y,0b110110110,C_ROCK)
 end

 --paths
 for i=1,50 do
  local x,y=rnd(worldw),rnd(worldh)
  local rot=0
  for i=1,rnd(6)+rnd(6)+rnd(6) do
   mset(x,y,T_PATH)
   x+=rotx[rot]+rnd(split"0,0,0,0,0,0,-1,1")
   y+=roty[rot]+rnd(split"0,0,0,0,0,0,-1,1")
   rot+=rnd(split"0,0,0,0,1,-1")
   rot%=4
  end
 end

 --rivers
 local x=0
 while x<worldw do
  x+=(rndr(1,5)+rndr(1,5)+rndr(1,5)+rndr(12))\1
  local r=1
  local c=drifter(C_WATER,0.2,0.95)
  for y=0,worldh-1 do
   for dx=-r,r do
    if rnd()<c:get() then
     mset(x+dx,y,T_WATER)
    end
   end
   if rnd()<0.4 then
    x+=rndr(-1,3)\1
   end
   r+=rndr(-1,2)\1
   r=mid(1,r,4)
  end
 end

 --vines
 for cell in all(mapfindall(T_VINE)) do
  if rnd()<C_VINE1 then
   stamp(T_VINE,cell.x,cell.y,-1,C_VINE2)
  end
 end
end
  
--   for i=i0,i1 do
--    for d=1,d1 do
--     local x,y=x0+d*dirx[i],y0+d*diry[i]
--     if rnd()<C_SPREAD then
--      mset(x,y,t0)
--     end
--    end
--   end

function mapfindall(t)
 local res={}
 for y=0,worldh-1 do
  for x=0,worldw-1 do
   if mget(x,y)==t then
    add(res,{x=x,y=y})
   end
  end
 end
 return res
end

-- function countwalls(x,y,target, d)
--  local n=0
--  for i=0,7 do
--   local dx,dy=getdir(i)
--   for j=1,(d or 1) do
--    if mget(x+j*dx,y+j*dy)==target then
--     n+=1
--    end
--   end
--  end
--  return n
-- end

-- function mapbits(x,y,target)
--  local res=0
--  for i=0,7 do
--   if mget(x+dirx[i],y+diry[i])==target then
--    res+=1<<i
--   end
--  end
--  return res
-- end
