-- palette picker

--[[
delete entirely to save space
once you've made your game palette

tab to enter/exit palette mode
every palette change is auto-copied to your
 clipboard -- paste it into your _init()
]]

function check_palpick()
 local activate=dev_pal_pick and upd~=upd_pal and btnp(4,1)
 if not activate then return end
 pq("activate")

 local old_upd,old_drw=upd,drw
 upd,drw=upd_pal,drw_pal

 palpick={
  mx=0,
  my=0,
  firstframe=true,
  pal={},
  hoveri=nil,
  init=function(self)
   local used={}
   for i=0,15 do
    local c=@(0x5f10+i)
    self.pal[i]=c
    assert(not used[c],"screen palette has duplicate colors")
    used[c]=true
   end
   -- pq("used",used)
   local leftovers={}
   for i=0,31 do
    local c=i
    if c>=16 then
     c=0x80|(0x0f&c)
    end

    if not used[c] then
     -- pq("unused",tostr(c,1))
     if self.pal[i] then
      add(leftovers,c)
     else
      self.pal[i]=c
     end
    end
   end
   -- pq("leftovers",qa(leftovers))
   local i=16
   for c in all(leftovers) do
    while self.pal[i] do
     i+=1
    end
    self.pal[i]=c
   end
   -- pq("self.pal",qa(self.pal))
   assert(i<32,i)

   -- init scaline palette
   poke(0x5f5f,0x10)
   self:set_pals()
   memset(0x5f7f,0xff,1)
  end,
  clipcode=function(self)
   local s="--screen palette\npoke(unpack(split\"0x5f10"
   for i=0,15 do
    local c=self.pal[i]
    s..=(c>=0x80 and ",0x8" or ",0x")..hex[c&0xf]
   end
   s..="\"))"
   printh(s,"@clip")
   return s
  end,
  set_pals=function(self)
   for i=0,15 do
    pal(i,self.pal[i],1)
   end
   for i=16,31 do
    pal(i&0xf,self.pal[i],2)
   end
  end,
  bounds=function(self,i,...)
   local row,col=i\16,i%16
   return col*8,112+row*8,8,8,...
  end,
  swap=function(self,i1,i2)
   -- pq("swap",i1,i2)
   self.pal[i1],self.pal[i2]=self.pal[i2],self.pal[i1]
   self:set_pals()
  end,
  reset_hb=function(self,...)
   return 1,104,23,7,...
  end,
  -- hoverreset=false,
  swap_hb=function(self,...)
   return 25,104,19,7,...
  end,
  -- hoverswap=false,
  update=function(self)
   self.mx,self.my=poll_mouse()

   -- exit
   if btnp(4,1) and not self.firstframe then
    poke(0x5f5f,0)
    self:clipcode()
    upd,drw=old_upd,old_drw
    return
   end

   -- hoveri, choicei
   local choicei
   self.hoveri=nil
   for i=0,31 do
    if rect_collide(self.mx,self.my,1,1,self:bounds(i)) then
     self.hoveri=i
     if mbtnr(lmb) then
      choicei=i
     end
    end
   end
   if not self.hoveri then
    local i=pget(self.mx,self.my)
    self.hoveri=i
    if mbtnr(lmb) then
     choicei=i
    end
   end

   -- buttons
   self.hoverreset=rect_collide(self.mx,self.my,1,1,self:reset_hb())
   if self.hoverreset and mbtnr(lmb) then
    for i=0,15 do
     self.pal[i]=i
    end
    for i=16,31 do
     self.pal[i]=0x80|(i&0xf)
    end
    self:set_pals()
    choicei=nil
   end
   self.hoverswap=rect_collide(self.mx,self.my,1,1,self:swap_hb())
   if self.hoverswap and mbtnr(lmb) then
    for i=0,15 do
     self.pal[i],self.pal[i+16]=self.pal[i+16],self.pal[i]
    end
    self:set_pals()
    choicei=nil
   end

   if choicei then
    if self.choicei then
     self:swap(self.choicei,choicei)
     self.choicei=nil
     self:clipcode()
    else
     self.choicei=choicei
    end
   end

   self.firstframe=nil
  end,
  draw=function(self)
   old_drw()
   -- colors
   rectfillwh(0,111,128,1,0)
   for i=0,31 do
    local fillc=i&0xf
    if self.hoveri==i or self.choicei==i then
     fillp(▒\1)
     fillc=(fillc<<4)|(fillc^^0x8) --shade with opposite color
    end
    rectfillwh(self:bounds(i, fillc))
    fillp()
   end

   -- reset
   rectfillwh(self:reset_hb( self.hoverreset and 8 or 0))
   local x,y=self:reset_hb()
   print("\015reset",x+2,y+1,7)
   -- swap
   rectfillwh(self:swap_hb( self.hoverswap and 8 or 0))
   local x,y=self:swap_hb()
   print("\015swap",x+2,y+1,7)

   -- crosshair
   for d=2,3 do
    for i=0,3 do
     local x,y=self.mx+d*dirx[i],self.my+d*diry[i]
     pset(x,y,pget(x,y)^^0x6)
    end
   end
   if self.my<111 then
    rectfillborder(self.mx+3,self.my+3,8,8, 1,0,self.hoveri)
   end
  end,
 }

 palpick:init()
end
function upd_pal()
 palpick:update()
end
function drw_pal()
 palpick:draw()
end
