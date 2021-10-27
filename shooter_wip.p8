pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- main.


-- [todo]
-- array of booleans for bonus owned.
-- bonus timers in gui.
-- draw bonus from left to right.


function _init()
		pl_init()
		bullets_init()
		enemies_init()
		bonus_init()
		stars_init()
end

function _update60()
		pl_update()
		bullets_update()
		enemies_update()
		bonus_update()
		bullets_collision()
		pl_collision()
		stars_update()
		shake_update()
		ptcs_update()
end

function _draw()
		cls(0)
		stars_draw()
		bullets_draw()
		laser_draw()
		pl_draw()
		enemies_draw()
		bonus_draw()
		ptcs_draw()
		gui_draw()
end


function gameover()
		enemies_kill_all()
end
-->8
-- player.

function pl_init()
		pl_spd=1
		pl_healthmax=5
		pl_health=pl_healthmax
		pl_isdead=false
		pl_score=0
		
		pl_spdboost_incr=0.5
		pl_spdboost_dur=180
		
		pl={x=60,y=90,spd=pl_spd}
end

function pl_update()
		if (pl_isdead) return
		pl_move()
		pl_shoot()
end

function pl_draw()
		if (pl_isdead) return
		
		local _sprindex=1
		if bonus_owned[1]==1 then
				_sprindex=2
		elseif laser_on then
				_sprindex=3
		end
  
  spr(_sprindex,pl.x,pl.y)
end

function pl_move()
  -- [todo] normalize.
		if (btn(➡️)) pl.x+=pl.spd
	 if (btn(⬅️)) pl.x-=pl.spd
		if (btn(⬆️)) pl.y-=pl.spd
		if (btn(⬇️)) pl.y+=pl.spd

		-- clamp to screen.
		if (pl.x<0) pl.x=0
		if (pl.x>120) pl.x=120
		if (pl.y<7) pl.y=7
		if (pl.y>120) pl.y=120
end

function pl_shoot()
		if (pl_isdead) return
		
		if btnp(❎)
		and laser_on==false
		then
				bullets_add()
				
				for i=0,2 do
						ptcs_add(pl.x+4,
															pl.y-2,
															-2+rnd(4),
															-2+rnd(4),
															8,
															{10,9,8,2},
															rnd(3,6))
				end
		end
end

function pl_damage(_dmg)
		pl_health=max(0,pl_health-_dmg)
		
		-- game over.
		if pl_health==0 then
				pl_isdead=true
				gameover()
				
				for i=0,4 do
						ptcs_add(pl.x,
															pl.y,
															-8+rnd(16),
															-8+rnd(16),
															rnd(32)+32,
															{10,1,9,8,2,5,1},
															rnd(10,16))
				end
				
				shake_set(0.2)
				
		end
end

function pl_heal(_heal)
		pl_health=min(pl_healthmax,pl_health+_heal)
end

function pl_spdboost()
		pl.spd=pl_spd+pl_spdboost_incr
		bonus_timers[1]=pl_spdboost_dur
end

function pl_collision()
		-- enemies.
		for e in all(enemies) do
				if (abs(e.x-pl.x)<5)
				and (abs(e.y-pl.y)<5)
				then
						enemies_kill(e)
						shake_add(0.15)
						pl_damage(1)
						if (pl_health>0) then	
								pl.y+=2 -- recoil.
								for i=0,6 do
										ptcs_add(pl.x+2,
																	pl.y+2,
																	-3+rnd(6),
																	-3+rnd(6),
																	36,
																	{10,1,9,8,2,2,2,1},
																	rnd(8,16))
								end
						end
				end
		end
		
		-- bonus.
		for b in all(bonus) do
				if (abs(b.x-pl.x)<6)
				and (abs(b.y-pl.y)<6)
				then
						bonus_pickup(b)
				end
		end
end
-->8
-- shoot.

function bullets_init()
		bullets={}
		bullets_set_delay(6)
		
		bullets_spd=2.5
		bullets_spdboost_incr=2.5
		bullets_spdboost_dur=300
		
		laser_on=false
		laser_dur=180
		laser_sparkpts={}
end

function bullets_draw()
		for b in all(bullets) do
				local _sprindex=4
				if (b.spd>bullets_spd) _sprindex=5
				spr(_sprindex,b.x,b.y)
		end
end

function bullets_set_delay(_delay)
		poke(0x5f5c,_delay)
		poke(0x5f5d,_delay)
end

function bullets_update()
		for b in all(bullets) do
				b.y-=b.spd
				if (b.y<4) del(bullets,b)
		end
		
		laser_update()
end

function bullets_add()
		local _spd=bullets_spd
		if bonus_owned[2]==1 then
				_spd=bullets_spd+bullets_spdboost_incr
		end
		
		b={x=pl.x,y=pl.y-2,spd=_spd}
		add(bullets,b)
end

function bullets_spdboost()
		for b in all(bullets) do
				b.spd=bullets_spd+bullets_spdboost_incr
		end
		
		bonus_timers[2]=bullets_spdboost_dur
end

function laser_toggle(_state)
		laser_on=_state
		if (laser_on) bonus_timers[3]=laser_dur
end

function laser_update()
		if (laser_on==false) return
		
		for e in all(enemies) do
				if abs(e.x-pl.x)<4
				and e.y<pl.y
				then
						pl_score+=e.score
							enemies_kill(e)
							enemies_spawn()
							for i=0,6 do
									ptcs_add(e.x+4,
																		e.y-2,
																		-6+rnd(12),
																		-6+rnd(12),
																		40,
																		{3,1,11,2,13,3,1},
																		rnd(6,12))
							end
				end
		end

		shake_set(0.06)
		
		if	bonus_owned[3]==0 then
				laser_toggle(false)
		end
end

function laser_draw()
		if (laser_on==false) return
		
		laser_sparkpts={}
		local _yoffset=ceil(pl.y/10)+1
		local _yoffsetmax=(128/10)+1
		
		for i=0,_yoffset do
				local _pt={
						x=pl.x+(-2+rnd(12)),
						y=pl.y-_yoffsetmax*i}
						
				if (i==0) _pt.x=pl.x+4
				add(laser_sparkpts,_pt)
		end
		
		for i=1,#laser_sparkpts-2 do
				local _pt=laser_sparkpts[i]
				local _ptnext=laser_sparkpts[i+1]
				line(_pt.x,_pt.y,_ptnext.x,_ptnext.y,11)
		end
		
		rectfill(pl.x+2,pl.y+4,pl.x+5,0,11)
		rectfill(pl.x+3,pl.y+4,pl.x+4,0,7)
end

function bullets_collision()
	for b in all(bullets) do
	
			-- enemies.
			for e in all(enemies) do
					if (abs(e.x-b.x)<4)
					and (abs(e.y-b.y)<4)
					then
							pl_score+=e.score
							enemies_kill(e)
							enemies_spawn()
							bonus_try_add(e.x,e.y)
							if b.spd==bullets_spd then
									-- normal speed.
									del(bullets,b)
									shake_set(0.08)
									for i=0,3 do
											ptcs_add(b.x+4,
																				b.y-2,
																				-4+rnd(8),
																				-4+rnd(8),
																				24,
																				{7,8,4,2,1},
																				rnd(6,8))
									end
							else
									-- speed up.
									shake_set(0.12)
									for i=0,4 do
											ptcs_add(b.x+4,
																				b.y-2,
																				-4+rnd(8),
																				-4+rnd(8),
																				48,
																				{7,1,10,9,8,2,2,1},
																				rnd(8,12))
									end
							end
							
							goto continue
					end
			end
	
	::continue::
	end
end
-->8
-- enemies.

enemies={}

function enemies_init()
		for i=0,16 do
				enemies_spawn()
		end
end

function enemies_update()
		for e in all(enemies) do
				e.y+=e.spd
				if e.y>128 then
						del(enemies,e)
						enemies_spawn()
				end
		end
end

function enemies_draw()
		for e in all(enemies) do
				spr(e.sprindex,e.x,e.y)
		end
end

function enemies_spawn()
		e={
			x=8+rnd(112),
			y=-100+rnd(80),
			spd=0.5,
			sprindex=49,
			score=10
		}
						
		add(enemies,e)
end

function enemies_kill(_e)
		del(enemies,_e)
end

function enemies_kill_all()
		for e in all(enemies) do
				enemies_kill(e)
		end
end
-->8
-- bonus.

function bonus_init()
		bonus={}
		bonus_owned={0,0,0,0} -- booleans.
		bonus_timers={0,0,0,0}
		
		-- 0=health.
		-- 1=spd up.
		-- 2=piercing bullets.
		-- 3=laser.
		bonus_drop={0,1,1,2,2,3}
end

function bonus_update()
		for b in all(bonus) do
				b.y+=b.spd
				if (b.y>128) del(bonus,b)
		end
		
		-- timers.
		for i=1,#bonus_timers do
				if bonus_timers[i]>0 then
						bonus_timers[i]-=1
						if bonus_timers[i]==0 then
								bonus_owned[i]=0
						
								-- specific to each bonus.
								if (i==1) then
										pl.spd=pl_spd
										for i=0,3 do
												ptcs_add(pl.x+2,
																					pl.y+2,
																					-4+rnd(8),
																					-4+rnd(8),
																					24,
																					{10,1,9,12,1},
																					rnd(6,14))
										end
								end
						end
				end
		end
end

function bonus_draw()
		for b in all(bonus) do
			 spr(17+b.cat,b.x,b.y)
		end
end

function bonus_try_add(_x,_y)
		if (rnd(2)<1) return
	
		local _cat=bonus_rnd_drop()
		b={x=_x,y=_y,spd=0.75,cat=_cat}
		add(bonus,b)
end

function bonus_rnd_drop()
		return bonus_drop[ceil(rnd(#bonus_drop))]
end

function bonus_pickup(_b)
		if _b.cat==0 then
				-- health.
				pl_heal(1)
				for i=0,3 do
						ptcs_add(_b.x+2,
															_b.y+2,
															-4+rnd(8),
															-4+rnd(8),
															24,
															{8,2,1},
															rnd(8,10))
				end
		elseif _b.cat==1 then
				-- speed.
				pl_spdboost()
				for i=0,6 do
						ptcs_add(_b.x+2,
															_b.y+2,
															-8+rnd(16),
															-8+rnd(16),
															14,
															{10,9,10,9,12,1},
															rnd(4,12))
				end
				shake_add(0.07)
		elseif _b.cat==2 then
				-- bullets speed.
				bullets_spdboost()
				for i=0,4 do
						ptcs_add(_b.x+2,
															_b.y+2,
															-5+rnd(10),
															-5+rnd(10),
															22,
															{12,13,13,6,1,1},
															rnd(5,9))
				end
		elseif _b.cat==3 then
				-- laser.
				laser_toggle(true)
		end
		
		bonus_owned[_b.cat]=1
		del(bonus,_b)
end
-->8
-- stars.

function stars_init()
		stars={}
		stars_spd_mult=1
		
		-- slow stars.
		for i=1,20 do
				stars_add(rnd(128),
														rnd(128),
														rnd(0.5)+0.5,
														1)
		end
		
		-- fast stars.
		for i=1,8 do
				stars_add(rnd(128),
														rnd(128),
														rnd(1.5)+1.5,
														6)
		end
end

function stars_update()
		for s in all(stars) do
				s.y+=s.spd*stars_spd_mult
				if s.y>128 then
						s.x=rnd(128)
						s.y=0
				end
		end
end

function stars_draw()
		for s in all(stars) do
				pset(s.x,s.y,s.col)
		end
end

function stars_add(_x,_y,_spd,_col)
		s={x=_x,y=_y,spd=_spd,col=_col}
		add(stars,s)
end
-->8
-- feedback.

trauma=0
ptcs={}


function shake_set(_trauma)
		trauma=mid(0,_trauma,1)
end

function shake_add(_trauma)
		trauma=mid(0,trauma+_trauma,1)
end

function shake_update()
		local _x=(6-rnd(12))*trauma
		local _y=(6-rnd(12))*trauma
	
		camera(_x,_y)
	
		trauma*=0.95
		if (trauma<0.05) trauma=0
end


function ptcs_add(_x,_y,_dx,_dy,_agemax,_colseq,_size)
		local _p=
		{
				x=_x,
				y=_y,
				dx=_dx,
				dy=_dy,
				age=0,
				agemax=_agemax,
				col_seq=_colseq,
				size=_size,
				init_size=_size
		}
	
	add(ptcs,_p)
end

function ptcs_update()
		local _p
		for p=#ptcs,1,-1 do
			 _p=ptcs[p]
			 _p.age+=1
			 if _p.age>_p.agemax then
			  	del(ptcs,_p)
			 else
				 	_p.col=_p.col_seq[
				 		1+flr((_p.age/_p.agemax)*#_p.col_seq)]
		 	 	
				 	-- move particles.
				 	_p.x+=_p.dx
				 	if _p.t==3 then
						 	_p.y+=_p.dy
						 	_p.dy-=0.05
				 	else
						 	_p.y+=_p.dy
						 	--_p.dy+=0.15 -- gravity.
				 	end
				 	
				 	-- shrink.
				 	_p.size=(1-(_p.age/_p.agemax))*_p.init_size
			 	 
			 	 -- brake.
			 	 _p.dx*=0.75
			 	 _p.dy*=0.75
		 	end
		end
end

function ptcs_draw()
		for p in all(ptcs) do
				circfill(p.x,p.y,p.size,p.col)
		end
end
-->8
-- gui.

function gui_draw()
		gui_draw_rect()
		gui_draw_health()
		gui_draw_score()
		gui_draw_bonus()
end

function gui_draw_rect()
		rectfill(-4,-4,132,7,0)
end

function gui_draw_health()
  for i=1,pl_healthmax do
  		sprite=17
  		if (i>pl_health) sprite=33
  		spr(sprite,(i-1)*6+1,1)	
  end
end

function gui_draw_score()
		length=#tostr(pl_score)
		print(pl_score,124-(length-1)*4,1,7)
end

function gui_draw_bonus()
		for i=1,#bonus_owned do
				local _b=bonus_owned[i]
				if (_b==0) goto continue
				
				spr(17+i,40+8*i,1)
				
				::continue::
		end
end
__gfx__
00000000007007000070070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c00c0000a00a0000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700066006600760067007b00b7000700700000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000667c6d00767a6700737737000a00a00000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000666dd66677699677773bb37700900900000dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700d6666666777dd77777733777000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055115500ee99ee00553355000000000000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000d0000d00e0000e00500005000000000000cc00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000880880000aaa00000dd000000bbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888000aaa00000d7cd0000b773b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000088888000aaaa00001cc10000b773b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000888000000a0000001100000b33b30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008000000a0000001cc100000bb300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000220220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000556ee6550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555ee5550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000052002500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
