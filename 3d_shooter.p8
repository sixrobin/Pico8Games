pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- main.

function _init()
  init_rects()
end

function _update()
  update_rects()
  update_ship()
  update_bullets()
end

function _draw()
  cls(1)
  draw_rects()
  draw_bullets()
  draw_ship()
end
-->8
-- rects.

rects={}
min_rect_t=4
rect_speed=0.8
rect_accel=10
rect_cols={13}
squash=0.7


function init_rects()
  --todo: init rects to fill the screen.
  add_rect()
end


function add_rect()
  add(rects,{t=min_rect_t+1})
end


function update_rects()
  local length=#rects
  
  for i=1,length do
    local r=rects[i]
    r.t+=(r.t/rect_accel)*rect_speed
    if i==length and r.t>13 then
      add_rect()
    end
  end

  --todo: del based on rect.t instead. 
  while #rects>10 do
    del(rects,rects[1])
  end
end


function draw_rects()
  local c=rect_cols[1]
  
  local rx0=64-min_rect_t
  local ry0=64-(min_rect_t*squash)
  local rx1=64+min_rect_t
  local ry1=64+(min_rect_t*squash)
  
  -- center rect.
  rect(rx0,ry0,rx1,ry1,c)
  
  -- diagonals.
  line(0,64-64*squash,rx0,64-(min_rect_t*squash),c)
  line(0,64+64*squash,rx0,64+(min_rect_t*squash),c)
  line(128,64-64*squash,rx1,64-(min_rect_t*squash),c)
  line(128,64+64*squash,rx1,64+(min_rect_t*squash),c)
  line(0,64,rx0,64,c)
  line(rx1,64,128,64,c)
  --line(64,ry0,64,64-64*squash,c)
  --line(64,ry1,64,64+64*squash,c)
  
  -- rects.
  for r in all(rects) do
    local t=r.t
    local rc=rect_cols[min(ceil(t/15),#rect_cols)]
    local x0=64-t
    local y0=64-(t*squash)
    local x1=64+t
    local y1=64+(t*squash)
    rect(x0,y0,x1,y1,rc)
  end
end
-->8
-- ship.

ship={x=64,y=100,spd=2.5}


function update_ship()
  --todo: normalize.
  if (btn(⬆️)) ship.y-=ship.spd
  if (btn(⬇️)) ship.y+=ship.spd
  if (btn(⬅️)) ship.x-=ship.spd
  if (btn(➡️)) ship.x+=ship.spd
  ship.x=mid(8,ship.x,120)
  ship.y=mid(8,ship.y,120)
  
  if (btnp(❎)) add_bullet()
end


function draw_ship()
  local ship_center={x=ship.x-64,y=ship.y-64}
  local a=atan2(ship_center.x,ship_center.y)-.5
  local a_abs=abs(a)
  print(a,7)

  --todo: black outline(?).

  --todo: tilted vertical sprite.
  local s=1
  if a_abs<.1 or a_abs>.4 then
    if a_abs<.07 or a_abs>.43 then
      s=3
    else
      s=7
    end
  elseif a_abs<.2 or a_abs>.3 then
    s=5
  end
  
  spr(s,ship.x-7,ship.y-7,2,2,a_abs>0.25,a<0)
end
-->8
-- bullets.

bullets={}
bullets_sprites={35,34,33}
bullets_lifetime=2


function update_bullets()
  foreach(bullets,update_bullet)
end


--todo: update bullet speed
--based on lifetime.
function update_bullet(b)
  local dir={x=64-b.x,y=64-b.y}
  
  -- normalization.
  local pow_x=dir.x^2
  local pow_y=dir.y^2
  local magn=sqrt(pow_x+pow_y)
  dir.x/=magn
  dir.y/=magn
  
  -- destroy once center reach.
  if magn<3 then
    del(bullets,b)
    return
  end
  
  b.magn=magn
  b.t+=(1/30)/bullets_lifetime
  
  local t=out_quint(b.t)
  b.x=lerp(b.x_init,64,t)
  b.y=lerp(b.y_init,64,t)
end


function add_bullet()
  add(bullets,{x=ship.x,
												  	y=ship.y,
													  x_init=ship.x,
													  y_init=ship.y,
												   magn=0,
												   t=0})
end


function draw_bullets()
  foreach(bullets,draw_bullet)
end


function draw_bullet(b)
  local spr_index=min(ceil(b.magn/20),#bullets_sprites)
  local s=bullets_sprites[spr_index]
  spr(s,b.x-4,b.y-4)
end
-->8
-- maths.

function lerp(a,b,t)
  return (a*(1-t))+(b*t)
end

function out_quad(x)
  return 1-(1-x)*(1-x)
end

function out_cubic(x)
  return 1-pow(1-x,3)
end

function out_quart(x)
  return 1-pow(1-x,4)
end

function out_quint(x)
  return 1-pow(1-x,5)
end

function pow(x,a)
  if (a==0) return 1
  if (a<0) x,a=1/x,-a
  local ret,a0,xn=1,flr(a),x
  a-=a0
  while a0>=1 do
    if (a0%2>=1) ret*=xn
    xn,a0=xn*xn,shr(a0,1)
  end
  while a>0 do
    while a<1 do x,a=sqrt(x),a+a end
    ret,a=ret*x,a-1
  end
  return ret
end
__gfx__
00000000000000000000000000000066000000000000000000000000000000660000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000d16000000000000000000000000000000116600000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000006d1166000000000000600000000000000dd1d660000000000000000000000000000000000000000000000000000000000000
000770000000060000600000000d88d1d660000000000dd000006000000068d1d66d600000000000000000000000000000000000000000000000000000000000
000770000000dd0000dd00000000dd11d66d000000006666660dd000000d8d11d16d000000000000000000000000000000000000000000000000000000000000
00700700000666666666600000000d11d16d600000066616166666000000dd11d660000000000000000000000000000000000000000000000000000000000000
000000000066616116166600000000d1d66000000006ddddd161666000000dd1d166000000000000000000000000000000000000000000000000000000000000
00000000006dddddddddd600000000d1d1600000066111111ddddd60000000dd1d16000000000000000000000000000000000000000000000000000000000000
000000006611111111111166000000d1d1600000061d11ddd11111160000000d1d66000000000000000000000000000000000000000000000000000000000000
00000000611d11dddd11d116000000d1d66000000ddd8d00dd11dd160000000d1d16d60000000000000000000000000000000000000000000000000000000000
000000000dd8dd0000dd8dd000000d11d16d60000068d0000ddd8d00000000d11d66d00000000000000000000000000000000000000000000000000000000000
000000000068d000000d86000000dd11d66d0000000d000000d8600000000d811d66000000000000000000000000000000000000000000000000000000000000
00000000000d00000000d000000d88d1d660000000000000000d00000000d8dd1660000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000006d11660000000000000000000000000006d16000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000d16000000000000000000000000000000d66000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088778800008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008722780008ee80000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000008722780008ee80000022000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000088778800008800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
