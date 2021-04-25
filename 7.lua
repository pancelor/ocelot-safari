-- rng

function pause()
 -- if dev_gen_pause then
 --  repeat
 --   drw_gen()
 --   flip()
 --   _update_buttons()
 --  until btn(5)
 -- end
end

-- function gen_mob(x,y,typ)
--  mset(x,y,mob_tile[typ])
--  return add_mob(typ,x,y)
-- end

function map_gen()
 gen_rnd()
 gen_adjust()
 local y=worldh\2
 mset(2,y,T_PLAYER)
 mset(1,y-2,T_AXE)
 mset(1,y-3,T_PICK)
 mset(2,y-2,T_MACHETE)
 mset(2,y-3,T_FLINT)
end

function gen_rnd()
 memset(0x2000,0,0x1000)
 for y=0,worldh-1 do
  for x=4,worldw-1 do
   local r=rnd()
   local t=r<0.5 and T_TREE
    or r<0.9 and T_VINE
    or T_ROCK
   mset(x,y,t)
  end
 end
end

function stamp(tile,x,y,bits, chance)
 -- 0b000
 --   000
 --   000
 for i=0,8 do
  if bits&(1<<(8-i))>0 and (not chance or rnd()<chance) then
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
   pq(res)
   return res
  end
 }
end
 
function gen_adjust()
 local C_ROCK,C_WATER=0.3,0.8

 -- rocks
 for cell in all(mapfindall(T_ROCK)) do
  stamp(T_ROCK,cell.x,cell.y,0b110110110,C_ROCK)
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

end
function foo()


 local N_SPREAD,C_SPREAD=75,0.9
 for i=1,N_SPREAD do
  local x0,y0=rndr(4,worldw)\1,rndr(worldh)\1
  local t0=mget(x0,y0)
  local i0,i1,d1=0,7,1
  -- if t0==T_WATER then
  --  d=2
  -- elseif t0==T_TREE then
  --  i0=4
  -- elseif t0==T_PATH then
  --  i1=3 -- straight only
  --  d=2
  -- elseif t0==T_ROCK then
  --  -- good to go
  -- elseif t0==T_VINE then
  --  -- good to go
  -- end
  
  for i=i0,i1 do
   for d=1,d1 do
    local x,y=x0+d*dirx[i],y0+d*diry[i]
    if rnd()<C_SPREAD then
     mset(x,y,t0)
    end
   end
  end
 end
end

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

--  --⧗
--  local density0,ca_to_floor,ca_to_wall,nca=0.5,-1,1,2
--  -- flip_threshhold: higher=more walls
--  local flip_threshhold,flip_chance=2,0.4
--  local grass_threshhold,grass_chance=4,0.35
--  local door_chance=0.3
--  local mob_chance=0.03

--  for y=0,map_size_m1 do
--   for x=0,map_size_m1 do
--    mset(x,y,rnd()<density0 and 2 or 1)
--   end
--  end
--  -- pause("rnd")

--  local m=new_map()
--  for ca=1,nca do
--   for y=0,map_size_m1 do
--    for x=0,map_size_m1 do
--     local nwall=countwalls(x,y)
--     local nfloor=8-nwall
--     local diff=nwall-nfloor
--     --⧗
--     m[y][x]=diff<=ca_to_floor and 1
--      or diff>=ca_to_wall and 2
--      or mget(x,y)
--  --   m[y][x]=diff<-2 and 1
--  --    or diff>2 and 2
--  --    or mget(x,y)
--    end
--   end
--   set_map(m)
--  end
--  -- pause("cell automata")

--  -- add noise walls in open spaces
--  for y=0,map_size_m1 do
--   for x=0,map_size_m1 do
--    local nwall=countwalls(x,y,2,2)
--    if nwall<=flip_threshhold and rnd()<flip_chance then
--     m[y][x]=18
--    end
--   end
--  end
--  set_map(m)
--  -- pause("noise")

--  -- fill border
--  for i=0,map_size_m1 do
--   mset(0,i,2)
--   mset(map_size_m1,i,2)
--   mset(i,0,2)
--   mset(i,map_size_m1,2)
--  end
--  -- pause("border")

--  -- find all separate map parts
--  local open=mapfindall(1)
--  shuffle(open)
--  local colmap=new_map()
--  local colstart={}
--  local next_color=1
--  for cell in all(open) do
--   local c=colmap[cell.y][cell.x]
--   if c==-1 then
--    work_enq("flood",job_distmap(cell.x,cell.y))
--    local flood=work_deq("flood",1).dmap
--    -- dbgmap=flood
--    -- pause("flooding")
--    for y=0,map_size_m1 do
--     for x=0,map_size_m1 do
--      if flood[y][x]>-1 then
--       colmap[y][x]=next_color
--      end
--     end
--    end
--    colstart[next_color]=cell
--    next_color+=1
--   end
--  end
--  -- dbgmap=colmap
--  -- pause("colmap")

--  -- connect map
--  for i=next_color-1,2,-1 do
--   local p0=colstart[i-1]
--   local x0,y0=p0.x,p0.y
--   local p1=colstart[i]
--   local x1,y1=p1.x,p1.y
--   -- pause(q("connecting",i-1,"to",i))
--   -- pq("con",i,p0,p1)
--   while x0~=x1 or y0~=y1 do
--    if rnd()<0.7 then
--     x0=approach(x0,x1)
--    elseif rnd()<0.7 then
--     y0=approach(y0,y1)
--    end
--    -- pq(x0,y0)
--    mset(x0,y0,1)
--    if colmap[y0][x0]>i then
--     -- if we've hit some already connected area, stop
--     pq("break")
--     break
--    end
--   end
--  end
--  -- pause("all connected")

--  -- place doors
--  for y=0,map_size_m1 do
--   for x=0,map_size_m1 do
--    local floors=mapbits(x,y,1)
--    local walls=mapbits(x,y,2)
--    if mget(x,y)==1
--    and (floors&3==3 or floors&12==12)
--    and (walls&3==3 or walls&12==12)
--    and rnd()<door_chance
--    then
--     mset(x,y,13)
--    end
--   end
--  end
--  -- pause("doors")

--  -- add grass
--  for y=0,map_size_m1 do
--   for x=0,map_size_m1 do
--    local nwall=countwalls(x,y,2,2)
--    if mget(x,y)==1
--    and nwall<=grass_threshhold
--    and rnd()<grass_chance then
--     mset(x,y,16)
--    end
--   end
--  end
--  -- pause("grass")
 
--  -- place player
--  local p0=colstart[1]
--  pl=gen_mob(p0.x,p0.y,1)
--  camera(pl.x*8-64,pl.y*8-64)

--  work_enq("pl_dmap",job_distmap(pl.x,pl.y,col_wall))
--  local dmap_res=work_deq("pl_dmap",1)
--  pl_dmap=dmap_res.dmap
--  -- dbgmap=pl_dmap
--  pause("player")

--  -- place exit
--  local cand={}
--  for y=0,map_size_m1 do
--   for x=0,map_size_m1 do
--    if mget(x,y)==1
--    and pl_dmap[y][x]>dmap_res.dst*3/4
--    then
--     add(cand,{x,y})
--    end
--   end
--  end
--  local bx,by=unpack(rnd(cand))
--  mset(bx,by,14)

--  --place slimes
--  for cell in all(mapfindall(1)) do
--   if rnd()<mob_chance then
--    gen_mob(cell.x,cell.y,2)
--   end
--  end

--  -- replace floor tiles (for map() perf)
--  for y=0,map_size_m1 do
--   for x=0,map_size_m1 do
--    if mget(x,y)==1 then
--     mset(x,y,0)
--    end
--   end
--  end
--  -- -- worms
--  -- while #mapfindall(2)>100 do
--  --  local x,y=rndi(map_size),rndi(map_size)
--  --  local list={}
--  --  while mget(x,y)==2 do
--  --   local dx,dy=getdir(rndi(4))
--  --   if not collide(x+dx,y+dy,col_oob) then
--  --    x+=dx
--  --    y+=dy
--  --    add(list,{x=x,y=y})
--  --   end
--  --  end
--  --  for p in all(list) do
--  --   mset(p.x,p.y,1)
--  --  end
--  --  pause()
--  -- end
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
