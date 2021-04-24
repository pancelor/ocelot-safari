-- custom tools

_12=12 --tile size (easily searchable)
_11=11 --tile size-1 (easily searchable)

function grid(c)
 for i=-1,127,_12 do
  rectfillwh(i,0,1,128,c)
  rectfillwh(0,i,128,1,c)
 end
end

function spr12(s,x,y,flp)
 local sy,sx=s\_12,s%_12
 palt()
 palt(0,false)
 sspr(sx*_12,sy*_12,_11,_11,x,y,_11,_11,flp)
end

-- x,y: 12-scaled world pos
-- vox,voy: 1-scaled visual offset
-- px,py: 1-scaled sprite pivot
function draw_s(self,s)
 local ani=self.ani or self
 palt(ani.palt)
 local s,flp=s or ani.s,ani.flp
 local x,y=
  self.x*_12+(self.vox or 0),
  self.y*_12+(self.voy or 0)
 spr12(s,x,y,flp)
 palt()
end

function xy_from_rot(rot, x,y)
 rot%=4
 return (x or 0)+rotx[rot],(y or 0)+roty[rot]
end
