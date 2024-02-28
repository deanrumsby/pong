pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- pong
-- by dean rumsby


-- winner --
------------

winner={
 name=nil,
 
 draw=function(self)
  local msg=self.name.." wins!"
  print(msg,65-(#msg*2),35,10)
 end
}


-- factory functions --
-----------------------

function make_paddle()
 local paddle={
  x=0,  -- x pos
  y=0,  -- y pos
  w=3,  -- width
  h=12, -- height
  s=0,  -- speed
  c=0,  -- color
 
  draw=function(self)
   rectfill(self.x,self.y,self.x+self.w-1,self.y+self.h-1,self.c)
  end
 }
 return paddle
end


-- scores --
------------

scores={
 player=0,
 com=0,
 
 draw=function(self)
  -- player score
  print("\^t\^w"..self.player,48,6,12)
  -- com score
  print("\^t\^w"..self.com,74,6,8)
 end 
}


-- player paddle --
-------------------

player=make_paddle()

player.init=function(self)
 self.x=0
 self.y=57
 self.s=1
 self.c=12
end

player.update=function(self)
 -- handle movement
 -- via up and down buttons
 if (btn(⬆️)) self.y-=self.s
 if (btn(⬇️)) self.y+=self.s
end


-- computer paddle --
---------------------

com=make_paddle()

com.init=function(self)
 self.x=125
 self.y=57
 self.s=1
 self.c=8
end

com.update=function(self)
 -- use paddle midpoint
 -- for comparisons
 local m=self.y+self.h/2
 -- if ball is headed away
 -- from com paddle then
 -- move back to center
 if ball.dx<=0 then
  if (m<49) self.y+=self.s
  if (m>79) self.y-=self.s
  return
 end
 -- if ball is headed toward
 -- com paddle then keep
 -- aligned 
 if (m>ball.y) self.y-=self.s
 if (m<ball.y) self.y+=self.s
end


-- playing court --
-------------------

court={
 top=0,    -- top wall y pos
 bot=127,  -- bottom wall y pos
 c=5,      -- color
 
 draw=function(self)
  -- top wall
  line(0,self.top,127,self.top,self.c)
  -- bottom wall
  line(0,self.bot,127,self.bot,self.c)
  -- dashed centre line
  local y=self.top+1
  while y<self.bot do
   line(63,y,63,y+1,self.c)
   y += 4
  end
 end
}


-- ball --
----------

ball={
 x=0,    -- x pos
 y=0,    -- y pos
 w=3,    -- width
 h=3,    -- height
 dx=0,   -- horizontal velocity
 dy=0,   -- vertical velocity
 s=0.1,  -- speedup per hit
 c=10,   -- color
 
 init=function(self)
  self.x=62
  self.y=62
  self.dx=rnd({-0.5,0.5})
  self.dy=rnd(2)-1
 end,
 
 update=function(self)
  -- update position
  self.x+=self.dx
  self.y+=self.dy
 end,
 
 draw=function(self)
  rectfill(self.x,self.y,self.x+self.w-1,self.y+self.h-1,self.c)
 end
}


-- game loop --
---------------

function _init()
 player:init()
 com:init()
 ball:init()
end

function _update60()
 -- game over
 if (winner.name) return
 
 -- position updates
 player:update()
 ball:update()
 com:update()
 
 -- collision updates
 resolve_collisions()
 
 -- scoring
 check_score()
 
 -- wins
 check_win()
end

function _draw()
 -- clear screen
 cls()
 
 -- draw entities
 court:draw()
 player:draw()
 com:draw()
 ball:draw()
 
 -- draw scores
 scores:draw()
 
 -- game over
 if winner.name then
  winner:draw()
 end
end


-- scoring functions --
-----------------------

function check_score()
 --player scored
 if ball.x>127 then
  scores.player+=1
  sfx(2)
  _init()
 end
 -- com scored
 if ball.x<0 then
  scores.com+=1
  sfx(3)
  _init()
 end
end

function check_win()
 -- player wins
 if scores.player==7 then
  winner.name="player"
  sfx(4)
 end
 -- com wins
 if scores.com==7 then
  winner.name="com"
  sfx(5)
 end
end


-- collision system --
----------------------

-- using axis aligned
-- bounding box collision
function collision(a,b)
 return (
  a.x<b.x+b.w
  and a.x+a.w>b.x
  and a.y<b.y+b.h
  and a.y+a.h>b.y
 )
end

function resolve_collisions()
	-- player paddle with walls
 player.y=mid(court.top+1,player.y,court.bot-player.h)
 
 -- com paddle with walls
 com.y=mid(court.top+1,com.y,court.bot-com.h)
 
 -- ball with walls
 if ball.y<=court.top+1 
 or ball.y+ball.h>=court.bot then
  ball.y=mid(court.top+1,ball.y,court.bot-ball.h)
  ball.dy*=-1
  sfx(1)
 end
 
 -- ball with player paddle
 if collision(player,ball) then
  ball.x=player.x+player.w
  ball.dx*=-1
  ball.dx+=ball.s
  
  -- add any ball control
  if btn(⬆️) then
   if ball.dy>0 then
    -- reduce angle and flip
    ball.dy-=2*ball.s
    ball.dy*=-1
   else
    -- increase angle
    ball.dy-=2*ball.s
   end
  end
  if btn(⬇️) then
   if ball.dy<0 then
    -- reduce angle and flip
    ball.dy+=2*ball.s
    ball.dy*=-1
   -- ball travelling down
   else
    -- increase angle
    ball.dy+=2*ball.s
   end
  end
  sfx(0)
 end
 
 -- ball with com paddle
 if collision(com,ball) then
  ball.x=com.x-ball.w
  ball.dx*=-1
  ball.dx-=ball.s
  sfx(0)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001b050000001a0001e000200002000021000200001e0001b00017000240003300014000140001600018000190001b0001b0001a000190001f000000000000000000000000000000000000000000000000
000100001205000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000e0000f050100501205015050190501d05023050290500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0003000000000260501e0501a05015050120500f0500f0500e0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001c0501f05022050270502c050310502b0002b0002b0003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000130500d050090500205002050020500200002000020000200008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
