pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- main.

function _init()
		pl_init()
		scr=0
		
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
		
		if not screenflash_draw() then
				stars_draw()
				bullets_draw()
				laser_draw()
				pl_draw()
				enemies_draw()
				bonus_draw()
				ptcs_draw()
		end
		
		gui_draw()
end

function gameover()
		enemies_killall()
		bonus_clear()
end
-->8
-- player.

function pl_init()
		pl_spd=1
		pl_healthmax=5
		pl_health=pl_healthmax
		pl_dead=false
		pl_spdboost_incr=0.5
		pl_dmgflash_timer=0
		
		pl={x=60,y=90,spd=pl_spd}
end

function pl_update()
		if (pl_dmgflash_timer>0) pl_dmgflash_timer-=1

		if (pl_dead) return
		pl_move()
		pl_shoot()
end

function pl_draw()
		if (pl_dead) return
		
		local _s=1
		if curr_bns[4] then
				_s=3
		elseif curr_bns[2] then
				_s=2
		end
  
  spr(_s,pl.x,pl.y)
end

function pl_move()
  -- [todo] normalize.
		if (btn(➡️)) pl.x+=pl.spd
	 if (btn(⬅️)) pl.x-=pl.spd
		if (btn(⬆️)) pl.y-=pl.spd
		if (btn(⬇️)) pl.y+=pl.spd

		-- screen clamp.
		pl.x=mid(0,pl.x,120)
		pl.y=mid(8,pl.y,120)
end

function pl_shoot()
		if (pl_dead) return
		
		if btnp(❎)
		and not curr_bns[4]
		then
				bullets_add()
				
				-- [todo] different ptcs per bullet type.
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

function pl_dmg(_d)
		pl_health=max(0,pl_health-_d)
		
		-- game over.
		if pl_health==0 then
				pl_dead=true
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
		
		pl_dmgflash_timer=2
end

function pl_heal(_h)
		pl_health=min(pl_healthmax,pl_health+_h)
end

function pl_spdboost()
		pl.spd=pl_spd+pl_spdboost_incr
end

function pl_collision()
		-- enemies.
		for e in all(enemies) do
				if (abs(e.x-pl.x)<5)
				and (abs(e.y-pl.y)<5)
				then
						del(enemies,e)
						shake_add(0.15)
						pl_dmg(1)
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
		for b in all(bns) do
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
		bls={}
		bls_setdelay(6)
		bls_spd=2.5
		bls_spdboost_incr=2.5
end

function bullets_draw()
		for b in all(bls) do
				local _sprindex=4
				if (b.spd>bls_spd) _sprindex=5
				spr(_sprindex,b.x,b.y)
		end
end

function bls_setdelay(_d)
		poke(0x5f5c,_d)
		poke(0x5f5d,_d)
end

function bullets_update()
		for b in all(bls) do
				b.y-=b.spd
				if (b.y<4) del(bls,b)
		end
		
		laser_update()
end

function bullets_add()
		local _spd=bls_spd
		if curr_bns[3] then
				_spd=bls_spd+bls_spdboost_incr
		end
		
		b={x=pl.x,y=pl.y-2,spd=_spd}
		add(bls,b)
end

function bullets_spdboost()
		for b in all(bls) do
				b.spd=bls_spd+bls_spdboost_incr
		end
end

function laser_update()
		if not curr_bns[4] then
				return
		end
		
		for e in all(enemies) do
				if abs(e.x-pl.x)<4
				and e.y<pl.y
				then
						scr+=e.scr
						del(enemies,e)
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
end

function laser_draw()
		if not curr_bns[4] then
				return
		end
		
		laser_sparks={}
		local _yoffset=ceil(pl.y/10)+1
		local _yoffsetmax=(128/10)+1
		
		for i=0,_yoffset do
				local _pt={
						x=pl.x+(-2+rnd(12)),
						y=pl.y-_yoffsetmax*i}
						
				if (i==0) _pt.x=pl.x+4
				add(laser_sparks,_pt)
		end
		
		for i=1,#laser_sparks-2 do
				local _pt=laser_sparks[i]
				local _ptnext=laser_sparks[i+1]
				line(_pt.x,_pt.y,_ptnext.x,_ptnext.y,11)
		end
		
		rectfill(pl.x+2,pl.y+4,pl.x+5,0,11)
		rectfill(pl.x+3,pl.y+4,pl.x+4,0,7)
end

function bullets_collision()
	for b in all(bls) do
	
			-- enemies.
			for e in all(enemies) do
					if (abs(e.x-b.x)<4)
					and (abs(e.y-b.y)<4)
					then
							scr+=e.scr
							del(enemies,e)
							enemies_spawn()
							bonus_try_add(e.x,e.y)
							if not curr_bns[3] then
									-- normal speed.
									del(bls,b)
									shake_set(0.08)
									for i=0,3 do
											ptcs_add(b.x+4,
																				b.y-2,
																				-4+rnd(8),
																				-4+rnd(8),
																				24,
																				{7,8,4,2,1},
																				3+rnd(3))
									end
							else
									-- speed up.
									shake_set(0.12)
									for i=0,4 do
											ptcs_add(b.x+4,
																				b.y-8,
																				-4+rnd(8),
																				-4+rnd(8),
																				48,
																				{7,1,12,13,1,1},
																				5+rnd(3))
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
		e={x=8+rnd(112),
					y=-100+rnd(80),
					spd=0.5,
					sprindex=49,
					scr=10}
						
		add(enemies,e)
end

function enemies_killall()
		for e in all(enemies) do
				del(enemies,e)
		end
end
-->8
-- bonus.

function bonus_init()
		bns={}
		curr_bns={false,false,false,false}
		bns_timers={0,0,0,0}
		bns_durs={0,180,300,180}
		
		-- 1=health.
		-- 2=spd up.
		-- 3=piercing bullets.
		-- 4=laser.
		bns_drop={1,2,2,3,3,4}
end

function bonus_update()
		for b in all(bns) do
				b.y+=b.spd
				if (b.y>128) del(bonus,b)
		end
		
		-- timers.
		for i=1,#bns_timers do
				if bns_timers[i]>0 then
						bns_timers[i]-=1
						if bns_timers[i]==0 then
								curr_bns[i]=false
						
								-- specific to each bonus.
								if (i==2) then
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
		for b in all(bns) do
			 spr(16+b.cat,b.x,b.y)
		end
end

function bonus_try_add(_x,_y)
		if (rnd(3)>1) return
	
		local _cat=bonus_rnd_drop()
		b={x=_x,y=_y,spd=0.75,cat=_cat}
		add(bns,b)
end

function bonus_rnd_drop()
		return bns_drop[ceil(rnd(#bns_drop))]
end

function bonus_clear()
		for i=2,#bns_timers do
			 bns_timers[i]=0
			 curr_bns[i]=false
		end
end

function bonus_pickup(_b)
		if _b.cat==1 then
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
		elseif _b.cat==2 then
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
		elseif _b.cat==3 then
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
		elseif _b.cat==4 then
				-- laser.
		end
		
		if (_b.cat>1) curr_bns[_b.cat]=true
		bns_timers[_b.cat]=bns_durs[_b.cat]
		del(bns,_b)
end
-->8
-- stars.

function stars_init()
		stars={}
		stars_spd_mult=1
		stars_clear_step=6
		stars_clear_timer=0
		
		-- slow stars.
		for i=1,20 do
				local _s={x=rnd(128),
														y=rnd(128),
														spd=rnd(0.5)+0.5,
														col=1}
							
				add(stars,_s)
		end
		
		-- fast stars.
		for i=1,8 do
				local _s={x=rnd(128),
														y=rnd(128),
														spd=rnd(1.5)+1.5,
														col=6}
							
				add(stars,_s)
		end
end

function stars_update()
		if (pl_dead) then
				stars_spd_mult*=0.98
				
				if stars_clear_timer==0 then
						del(stars,stars[ceil(rnd(#stars))])
						stars_clear_timer=stars_clear_step
				else
				  stars_clear_timer-=1
				end
		end

		local _lasermult=1
		if (curr_bns[3]) _lasermult=2

		for s in all(stars) do
				s.y+=s.spd*stars_spd_mult*_lasermult
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
-->8
-- feedback.

shake=0
ptcs={}


function shake_set(_s)
		shake=mid(0,_s,1)
end

function shake_add(_s)
		shake_set(shake+_s)
end

function shake_update()
		local _x=(6-rnd(12))*shake
		local _y=(6-rnd(12))*shake
		camera(_x,_y)
		shake*=0.95
		if (shake<0.05) shake=0
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
				colseq=_colseq,
				size=_size,
				init_size=_size
		}
	
	add(ptcs,_p)
end

function ptcs_update()
		local pt
		for p=#ptcs,1,-1 do
			 _p=ptcs[p]
			 _p.age+=1
			 if _p.age>_p.agemax then
			  	del(ptcs,_p)
			 else
				 	_p.col=_p.colseq[
				 		1+flr((_p.age/_p.agemax)*#_p.colseq)]
		 	 	
				 	-- move particles.
				 	_p.x+=_p.dx
				 	_p.y+=_p.dy
				 	
				 	-- shrink.
				 	_p.size=(1-(_p.age/_p.agemax))*_p.init_size
			 	 
			 	 -- brake.
			 	 _p.dx*=0.75
			 	 _p.dy*=0.75
		 	end
		end
end

function ptcs_draw()
		for pt in all(ptcs) do
				circfill(pt.x,pt.y,pt.size,pt.col)
		end
end


function screenflash_draw()
		if pl_dmgflash_timer>0 then
				cls(8)
				return true
		end
				
		if bns_timers[4]>=bns_durs[4] then
				if bns_timers[4]>=bns_durs[4]-1 then
						cls(7)
				else
						cls(3)
				end
				return true
		end
		
		return false
end
-->8
-- gui.

function gui_draw()
		rectfill(-4,-4,132,7,0)
		gui_draw_health()
		gui_draw_scr()
		gui_draw_bonus()
end

function gui_draw_health()
  for i=1,pl_healthmax do
  		local _s=17
  		if (i>pl_health) _s=33
  		spr(_s,(i-1)*6+1,1)	
  end
end

function gui_draw_scr()
		local l=#tostr(scr)
		print(scr,124-(l-1)*4,1,7)
end

function gui_draw_bonus()
		for i=2,#curr_bns do
				local _x=20+10*i
				if curr_bns[i] then
						spr(16+i,_x,1)
						
						-- timer.
						local _xa=_x-1
						local _xb=_x+5
						local _xend=lerp(
																		_xa,
																		_xb,
																		bns_timers[i]/bns_durs[i])
						
						line(_xa,7,_xend,7,6)
				else
						spr(21,_x,1)
				end
		end
end
-->8
-- tools.

function lerp(_a,_b,_t)
	 return _a*(1-_t)+_b*_t
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
0000000088888000aaaa00001cc10000b773b0000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000888000000a0000001100000b33b30000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
