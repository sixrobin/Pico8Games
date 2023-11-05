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
  update_bullets()
  update_ptcs()
end

function _draw()
  cls(7)
  clear_debug_line()
  draw_ground()
  draw_entities()
  draw_ptcs()
  draw_ui()
end


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


-- todo

-- fix rock friction (both axis)
-- enemies walk around rocks
-- bullets random aim
-- blood splashes
-- game over (restart app)
-- footsteps
-- snow particles
-->8
-- physics

function dist(_x1,_y1,_x2,_y2)
  x=_x2-_x1
  y=_y2-_y1
  return sqrt(x*x+y*y)
end

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

function blt_hit(_b,_x2,_y2,_h)
  return _b.x>=_x2-2
         and _b.x<=_x2+4
         and _b.y>=_y2
         and _b.y<=_y2+_h
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
end

function draw_entities()
  entities_draw={} -- clear list

  -- player
  local ply_spr=2
  if (ply_blink>0) ply_spr=4
  add_entity_draw(ply_spr,ply.x,ply.y,1,1,ply.last_dx<0)
  add_entity_draw(19,ply.x+3*ply.last_dx,ply.y+1,1,1,ply.last_dx<0)
  
  -- rocks
  for r in all(rocks) do
    add_entity_draw(1,r.x,r.y,1,1,r.f,false)
  end
  
  -- enemies
  for e in all(enms) do
    add_entity_draw(3,e.x,e.y,1,1,e.x-ply.x>0,false)
  end
  
  -- bullets
  for b in all(blts) do
    add_entity_draw(20,b.x,b.y,1,1,false)
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

function draw_ptcs()
		for p=1,#ptcs do
			 local ptc=ptcs[p]
				if ptc.t==0 then
					-- pixel particles.
					pset(ptc.x,ptc.y,ptc.col)
				elseif ptc.t==1 then
					-- sprite particles.
					spr(ptc.col,ptc.x,ptc.y)
				elseif ptc.t==2 then
					-- smoke circles particles.
					circfill(ptc.x,ptc.y,ptc.size,ptc.col)
				end
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
  if (btnp(❎)) fire_bullet()
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

function fire_bullet()
  add_bullet(ply.x+ply.last_dx*6,ply.y+3,ply.last_dx,0)
end
-->8
-- enemies

enms_cnt=10
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
-- bullets

blts={}


-- utils functions

function add_bullet(_x,_y,_dx,_dy)
  local b={x=_x,
           y=_y,
           dx=_dx,
           dy=_dy,
           spd=5}
  add(blts,b)
end

function del_bullet(_b)
  del(blts,_b)
end


-- update functions

function update_bullets()
  for i=#blts,1,-1 do
    update_bullet(blts[i])
  end
end

function update_bullet(_b)
  _b.x+=_b.dx*_b.spd
  _b.y+=_b.dy*_b.spd
  
  -- offscreen bullets
  if _b.x>128 or _b.x<-8 then
     del_bullet(_b)
     return
  end
  
  -- rocks collision
  for r in all(rocks) do
    if blt_hit(_b,r.x,r.y,4) then
      add_rock_ptcs(_b.x,_b.y)
      del_bullet(_b)
      return
    end
  end
  
  -- enemies collision
  for e in all(enms) do
    if blt_hit(_b,e.x,e.y,6) then
      respawn_enemy(e)
      add_blood_ptcs(_b.x,_b.y,3)
      del_bullet(_b)
      return
    end
  end
end
-->8
-- rocks

rocks_cnt=12
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
-- vfx

ptcs={}


-- utils functions

function out_quad(_t)
	 return _t*(2-_t)
end

function add_ptc(_x,_y,_dx,_dy,_t,_age_max,_cols,_s)
	 local ptc={x=_x,
													y=_y,
													dx=_dx,
													dy=_dy,
													t=_t,
													age=0,
													age_max=_age_max,
													col_seq=_cols,
													size=_s,
													init_size=_s }
	
	 if ptc.t==1 then
		  ptc.col=ptc.col_seq[1+flr(rnd(#ptc.col_seq))]
	 end
	
	 add(ptcs,ptc)
end

function add_blood_ptcs(_x,_y,_cnt)
  for i=1,_cnt do
    alpha=rnd()
		  add_ptc(_x,
		          _y,
				        sin(alpha)*3+rnd(),
				        cos(alpha)*3+rnd(),
				        2,
				        5+rnd(4),
				        {8,8,8,8,2,1},
				        4+rnd(4))
		end
end

function add_rock_ptcs(_x,_y)
  for i=1,3 do
    alpha=rnd()
		  add_ptc(_x,
		          _y,
				        sin(alpha)*3+rnd(),
				        cos(alpha)*3+rnd(),
				        2,
				        3+rnd(3),
				        {6,6,13,5,1},
				        3+rnd(2))
		end
end


-- update functions

function update_ptcs()
		for i=#ptcs,1,-1 do
			 local p=ptcs[i]
			 p.age+=1
			 
			 if p.age>p.age_max then
			  	del(ptcs,p)
			  	return
			 end
			 
			 if p.t==0 or p.t==2 then
			 		p.col=p.col_seq[1+flr((p.age/p.age_max)*#p.col_seq)]
			 end
			 	
		 	-- shrink and brake
		 	if p.t==2 then
			 	 p.size=(1-(p.age/p.age_max))*p.init_size
			 	 p.dx*=0.75
			 	 p.dy*=0.75
		 	end
		 	
		 	-- move particles
		 	p.x+=p.dx
		 	if p.t==3 then
				 	p.y+=p.dy
				 	p.dy-=0.05
		 	else
				 	p.y+=p.dy
				 	p.dy+=0.15 -- gravity
		 	end
		end
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
__gfx__
00000000001110000011111000111110008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000016661000122221001111110088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070016666710012fff1011181810088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770001d677d6101f8881011181810088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770001dddd66101ffff1001111110088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070011ddddd11411114101122100888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd11111d1144441111222110888888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd00151151001212100088888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000019a100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000199100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000111111011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd0000000001a99971000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddddddddd01a111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ddddddddddddddd011100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd00ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
