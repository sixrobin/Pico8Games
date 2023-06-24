pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
-- core

function _init()
  init_player()
  init_rocks()
  init_enemies()
end

function _update60()
  update_player()
  update_enemies()
end

function _draw()
  cls(7)
  clear_debug_line()
  draw_ground()
  draw_entities()
  draw_ui()
end
-->8
-- physics

function collision(_x1,_y1,_x2,_y2)
  local dx=abs(_x2-_x1)
  local dy=abs(_y2-_y1)
  return {x=dx,y=dy}
end

function ply_collision(_x,_y)
  return collision(ply.x,ply.y,_x,_y)
end

function ply_dist(_x,_y)
  return dist(ply.x,ply.y,_x,_y)
end
-->8
-- draw

entities_draw={}
ply_blink=0


-- utils functions

function add_entity_draw(_s,_x,_y,_sx,_sy,_fx)
		local d={s=_s,x=_x,y=_y,sx=_sx,sy=_sy,fx=_fx}
	 add(entities_draw,d)
end

function sort_entities_draw()
  sort(entities_draw, function(_a,_b) return _a.y>_b.y end)
end


-- draw functions

function draw_ground()
  -- player blob
  spr(17,ply.x,ply.y+2)
  
  -- enemies blobs
  for e in all(enms) do
    spr(18,e.x,e.y+2)
  end
  
  -- blob shadows
  -- footsteps
  -- blood
end

function draw_entities()
  entities_draw={} -- clear list

  -- player
  ply_spr=2
  if (ply_blink>0) ply_spr=4
  add_entity_draw(ply_spr,ply.x,ply.y,1,1,ply.last_dx<0)
  
  -- rocks
  for r in all(rocks) do
    add_entity_draw(1,r.x,r.y,1,1,r.f,false)
  end
  
  -- enemies
  for e in all(enms) do
    add_entity_draw(3,e.x,e.y,1,1,false,false)
  end

  sort_entities_draw()

  for d in all(entities_draw) do
    spr(d.s,d.x,d.y,d.sx,d.sy,d.fx,false)
  end
end

function draw_ui()
  draw_player_health()
end

function draw_player_health()
local w_full=45
  local w_one=45/ply.hlt_max
  local hlt_miss=ply.hlt_max-ply.hlt
  
  rectfill(2,2,w_full+4,8,0)
  rectfill(4,4,47,6,1)
  
  if ply.hlt>0 then
    rectfill(4,4,49-(w_one*hlt_miss)-2,6,8)
  end
  
  for i=1,ply.hlt_max-1 do
    local c=2
    if (ply.hlt<i) c=0
    local x=4+(w_one*i)-1
    rectfill(x,4,x,6,c)
  end
end
-->8
-- player

ply=nil


-- init functions

function init_player()
  ply={x=60,
       y=60,
       spd=0.75,
       last_dx=1,
       hlt_max=5,
       hlt=5}
end

-- utils functions

function dmg_player(_dmg)
  ply.hlt-=_dmg
  ply_blink=8
end


-- update functions

function update_player()
  move_player()
  if (ply_blink>0) ply_blink-=1
end

function move_player()
  local x=ply.x
  local y=ply.y
  local dx,dy=0,0
  
  if (btn(0)) dx-=1
  if (btn(1)) dx+=1
  if (btn(2)) dy-=1
  if (btn(3)) dy+=1
  
  -- normalization
  if dx*dx+dy*dy>1 then
    d=sqrt(dx*dx+dy*dy)
    dx/=d
    dy/=d
  end
  
  dx*=ply.spd
  dy*=ply.spd
  
  if abs(dx)>0 then
    ply.last_dx=dx
  end
  
  -- screen collisions
  if x+dx<0 or x+dx>121 then
    dx=0
  end
  if y+dy<0 or y+dy>121 then
    dy=0
  end
  
  -- entites collisions
  for r in all(rocks) do
		  local cx=collision(x+dx,y,r.x,r.y)
		  local cy=collision(x,y+dy,r.x,r.y)

		  if cx.x<7 and cy.y<4 then
				  if cx.x<7 then
				    dx=0
				    cx=collision(x+dx,y,r.x,r.y)
				  end
				  if cx.x<7 and cy.y<4 then
				    dy=0
				  end
		  end
  end
  
  ply.x=x+dx
  ply.y=y+dy
end
-->8
-- enemies

enms_cnt=3
enms={}


-- init functions

function init_enemies()
  for i=1,enms_cnt do
    local e=init_enemy()
    add(enms,e)
  end
end

function init_enemy()
  local p=get_spawn_pos()
  local e={x=p.x,y=p.y,spd=0.15}
  add(enms,e)
end


-- utils functions

function get_spawn_pos()
  local r=rnd(4)
  
  -- right rect
  local x=132+rnd(32)
  local y=rnd(128)
  
  if r<1 then -- left rect
    x=-32+rnd(24)
  elseif r<2 then -- up rect
    x=rnd(128)
    y=-32+rnd(24)
  elseif r<3 then -- down rect
    x=rnd(128)
    y=132+rnd(32)
  end
  
  return {x=x,y=y}
end

function respawn_enemy(_e)
  local p=get_spawn_pos()
  _e.x=p.x
  _e.y=p.y
end


-- update functions

function update_enemies()
  for e in all(enms) do
    update_enemy(e)
  end
end

function update_enemy(_e)
  local pc=ply_collision(_e.x,_e.y)
  if pc.x<7 and pc.y<4 then
    respawn_enemy(_e)
    dmg_player(1)
    return
  end
  
  local dx=ply.x-_e.x
  local dy=ply.y-_e.y
  
  -- normalization
  d=sqrt(dx*dx+dy*dy)
  dx/=d
  dy/=d
  
  -- collisions
  for r in all(rocks) do
		  local cx=collision(_e.x+dx,_e.y,r.x,r.y)
		  local cy=collision(_e.x,_e.y+dy,r.x,r.y)
		  
		  if cx.x<7 and cy.y<4 then
				  if cx.x<7 then
				    dx=0
				    cx=collision(_e.x+dx,_e.y,r.x,r.y)
				  end
				  if cx.x<7 and cy.y<4 then
				    dy=0
				  end
		  end
  end
  
  _e.x+=dx*_e.spd
  _e.y+=dy*_e.spd
end
-->8
-- rocks

rocks_cnt=18
min_rocks_spacing=16
min_ply_dist=32
rocks={}


-- init functions

function init_rocks()
  for i=1,rocks_cnt do
    local f=rnd(64)<32
    local x=4+rnd(108)
    local y=4+rnd(108)
    
    while rock_spawn_valid(x,y)==false do
      x=4+rnd(108)
		    y=4+rnd(108)
    end
    
    r={x=x,y=y,f=f}
    add(rocks,r)
  end
end


-- utils functions

function rock_spawn_valid(_x,_y)
  -- too close to player
  if ply_dist(_x,_y)<min_ply_dist then
    return false
  end

  -- too close to another rock
  if #rocks>0 then
    c=closest_rock(_x,_y)
    if dist(c.x,c.y,_x,_y)<min_rocks_spacing then
      return false
    end
  end

  -- valid coordinates
  return true
end

function closest_rock(_x,_y)
  local c=nil
  local m=1000
  for r in all(rocks) do
    local d=dist(r.x,r.y,_x,_y)
    if d<m then
      c=r
      m=d
    end
  end
  return c
end
-->8
-- utils

function sort(_a,_f)
  for i=1,#_a do
    local j=i
    while j>1 and _f(_a[j-1],_a[j]) do
      _a[j],_a[j-1]=_a[j-1],_a[j]
    j-=1
    end
  end
end

function dist(_x1,_y1,_x2,_y2)
  x=_x2-_x1
  y=_y2-_y1
  return sqrt(x*x+y*y)
end
-->8
-- debug

dbg_line=0


function clear_debug_line()
  dbg_line=0
end

function draw_debug(msg)
  rectfill(0,dbg_line*8,#msg*4,dbg_line*8+6,0)
  print(msg,1,dbg_line*8+1,7)
  dbg_line+=1
end
-->8
-- todo

-- fix rock friction (both axis)
-- enemies look at player
-- enemies walk around rocks
-- blood splashes
-- game over (restart app)
-- snow footsteps
__gfx__
00000000001110000011111000111110008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000016661000122221001111110088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070016666710012fff1011181810088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770001d677d6101f8881011181810088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770001dddd66101ffff1001111110088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070011ddddd11411114101122100888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd11111d1144441111222110888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd00151151001212100088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd00ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
