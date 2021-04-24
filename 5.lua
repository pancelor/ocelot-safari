-- custom tools

_12=12 --tile size (easily searchable)
_11=11 --tile size-1 (easily searchable)

function grid(c, ox,oy)
 ox,oy=ox or 0,oy or 0
 local w,h=worldw*_12,worldh*_12
 for i=-1,w,_12 do
  rectfillwh(i+ox,0,1,h,c)
  rectfillwh(0,i+oy,w,1,c)
 end
end

function spr12(s,x,y,flpx,flpy)
 local sy,sx=s\_12,s%_12
 sspr(sx*_12,sy*_12,_11,_11,x,y,_11,_11,flpx,flpy)
end

-- x,y: 12-scaled world pos
-- vox,voy: 1-scaled visual offset
-- px,py: 1-scaled sprite pivot
function draw_s(self,s)
 local ani=self.ani or self
 local pal_=ani.pal or {}
 palt(ani.palt)
 pal(pal_)
 local s,flpx,flpy=s or ani.s,ani.flpx,ani.flpy
 local x,y=
  self.x*_12+(self.vox or 0),
  self.y*_12+(self.voy or 0)
 spr12(s,x,y,flpx,flpy)
 palt()
 unpal(pal_)
end

function xy_from_rot(rot, x,y)
 rot%=4
 return (x or 0)+rotx[rot],(y or 0)+roty[rot]
end

function toscreen(x,y)
 return x*_12,y*_12
end

function inbounds(x,y)
 return 0<=x and x<worldw
    and 0<=y and y<worldh
end
