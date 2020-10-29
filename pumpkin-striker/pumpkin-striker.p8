pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- pumpkin slasher.
-- robin six.

------------------------

-- todo.

-- ! play again.

-- main menu:
-- -- animate background.
-- -- fade in play pk / fx.
-- -- top panel comes down.
-- -- values reset.
-- -- reset knf_py on start.

-- anim ui texts.

-- ld.
-- -- ? bonus lvls full of pk.

-- wishlist.
-- -- spider ropes in half
-- -- for better offset effect.
-- -- cuttable spider.
-- -- full knife rotation anim.
-- -- pk rotation.
-- -- candles interactions.
-- -- more control on lvls gen.

------------------------


function _draw()
	cls(0)
	fade_pal(fade_perc)
	
	if gstate=="mainmenu" then
		draw_knife()
		draw_mainmenu()
	elseif gstate=="playing" then
		draw_pk_light()
		draw_enviro()
		draw_knife_clamps()
		draw_knife_scope()
		draw_pk()
		draw_knife()
		draw_gui()
	 draw_gover()
	end
	
	draw_ptcs()
	draw_txts_displays()
	
	-- debug.
	--line(pk_px+8,pk_py+10,knf_px+8,knf_py,11)
 --print(flr(pk_px).."/"..flr(pk_py),40,11,11)
 --print(gover_timer,40,11,11)
end

function _init()
	init_lvls()
 init_sparks_ptcs()
	next_pk()
	fade_perc=1
end

function _update()
	timer+=1
	
	if gstate=="mainmenu" then
		update_knife()
		update_mainmenu()
	elseif gstate=="playing" then
	 timer_playing+=1
	 update_start_countdown()
		update_lvlup()
		update_gover()
		update_knife()
		update_pk()
		update_candle_ptcs()
		update_sparks_ptcs()
		update_ropes_offset()
		update_top_panel()
	end
	
	update_fade()
	update_ptcs()
	update_shake()
	update_txts_displays()
end
-->8
-- variables.

gstate="mainmenu"
timer=0
timer_playing=0


------------------------
-- main menu.
------------------------

mainmenu_timer=0
mainmenu_pk_cut=false
mainmenu_play_pk_cut=false
mainmenu_play_pk_on=false

mainmenu_title_h=10
mainmenu_title_wave=0

mainmenu_play_timer=-1

------------------------
-- levels.
------------------------

game_started=false

cur_lvl=nil
cur_lvl_index=1
cur_lvl_pk_counter=0

lvls={}

lvl_1={
 pk_count=4,
 bad_pk_perc=0,
 malus=0,
 pk_base_vely=-9,
 rnd_add_vely=2,
 grav=0.35}
 
lvl_2={
 pk_count=10,
 bad_pk_perc=0.25,
 malus=10,
 pk_base_vely=-10.5,
 rnd_add_vely=2.5,
 grav=0.4}
 
lvl_3={
 pk_count=15,
 bad_pk_perc=0.35,
 malus=15,
 pk_base_vely=-11,
 rnd_add_vely=3,
 grav=0.5}
 
lvl_4={
 pk_count=25,
 bad_pk_perc=0.4,
 malus=15,
 pk_base_vely=-11,
 rnd_add_vely=3,
 grav=0.5}
 
lvl_5={
 pk_count=25,
 bad_pk_perc=0.4,
 malus=15,
 pk_base_vely=-11,
 rnd_add_vely=3,
 grav=0.5}

last_lvl_done=false


------------------------
-- pumpkin.
------------------------

pk_sprs={1,33,35}
-- rest in generate_pk().


------------------------
-- knife.
------------------------

knf_vely=0
knf_minh,knf_maxh=30,85
knf_input_pressed=false

knf_spr_seq={97,99,101,103}
knf_spr_timer=-1
knf_px,knf_py=0,87
knf_dir,knf_speed=1,14
knf_anim_on=false
knf_hit_smth=false
knf_flipx=true
knf_hitpause=-1

knf_borders_col_seq={8,2,2,1,1,1,1,1,1,1,1,1}


------------------------
-- scoring.
------------------------

score,combo=0,0
cut_pk,cut_bad_pk,max_combo=0,0,0


------------------------
-- gui.
------------------------

fade_perc,fade_target_perc=0,0
fade_timer=0

start_msg_timer=-1
start_msg_dur=30
start_msg_col_seq={1,2,8,9,7,7,7,7,8,5,2,1}

lvlup_timer=-1
lvlup_dur=30
lvlup_col_seq={1,2,8,10,7,7,7,7,8,8,2,1}

gover_timer=-1
gover_msg_dur=24
gover_msg_col_seq={1,2,8,9,7,7,7}

top_panel_h=0
top_panel_gover_h=-11
top_panel_gover_timer=48


------------------------
-- feedback.
------------------------

cur_trauma=0
ptcs,txts_displays={},{}


------------------------
-- enviro.
------------------------

dust_ptcs={}
candle_ptcs_timer=0
candle_ptcs_col_seq={7,10,9,8,5,1,0}
spider_ropes_offset=-1
spider_ropes_offset_seq=
{3,-2,-2,1,1,1,-0.5,-0.5,0.5,0}
fire_anim_seq={11,12,43,44,75,76}
-->8
-- punctual functions.

------------------------
-- levels.
------------------------

function init_playing_state()
	gstate="playing"
	fade_target_perc=0
end

function next_lvl()
	cur_lvl_index+=1
	last_lvl_done=cur_lvl_index>#lvls
	
	if last_lvl_done then
	 cur_lvl_index-=1
	else
		cur_lvl=lvls[cur_lvl_index]
		cur_lvl_pk_counter=cur_lvl.pk_count
	
		lvlup_timer=lvlup_dur
		add_lvlup_ptcs()
	end
end


------------------------
-- pumpkin.
------------------------

function next_pk()
	if cur_lvl_pk_counter==0 then
	 next_lvl()
	 pk_px,pk_py=-50,-50
	else
		generate_pk()
	end
end

function generate_pk()
	pk_px=20+rnd(80)
	pk_py=128
	
	pk_velx=rnd(1.5)*sgn(60-pk_px)
	pk_vely=cur_lvl.pk_base_vely+rnd(cur_lvl.rnd_add_vely)

	pk_isbad=rnd()<cur_lvl.bad_pk_perc
	if pk_isbad then
		pk_spr=3
	else
		pk_spr=pk_sprs[1+flr(rnd(#pk_sprs))]
	end
	pk_flip=rnd()<0.5
	
	cur_lvl_pk_counter-=1
end


------------------------
-- gui.
------------------------

function add_gover_msg_ptcs()
 local alpha
 for s=0,4+flr(rnd(2)) do
	 alpha=rnd()
		add_ptc(65,18,
		 sin(alpha)*3+rnd(),
		 cos(alpha)*3+rnd(),
		 2,7+rnd(5),{5,9,8,2,5,2,2,1},5+rnd(6))
	end
end

function add_gover_stat_ptcs(_y)
 local alpha
 for s=1,6+flr(rnd(3)) do
	 alpha=rnd()
		add_ptc(64,_y,
		 sin(alpha)*10+rnd(3),
		 cos(alpha)*2+rnd(3),
		 2,10+rnd(5),{7,6,13,5,1},3+rnd(4))
	end
end

function add_lvlup_ptcs()
 local alpha
 -- pixel particles.
 for p=0,5+rnd(3) do
 	alpha=rnd()
 	add_ptc(63,22,
 		sin(alpha)*(2+rnd()),
 		cos(alpha)*(2+rnd()),
 		0,12,{7,8,2})
 end
 
 -- smoke particles.
 for s=0,4+flr(rnd(2)) do
	 alpha=rnd()
		add_ptc(63,22,
		 sin(alpha)*3+rnd(),
		 cos(alpha)*3+rnd(),
		 2,10+rnd(15),{4,2,5,2,1},5+rnd(6))
	end
end


------------------------
-- feedback.
------------------------

function add_bad_pk_cut_ptc()
 local alpha
 -- pixel particles.
 for p=0,10+rnd(5) do
 	alpha=rnd()
 	add_ptc(pk_px+8,pk_py+8,
 		sin(alpha)*(1+rnd(5)),
 		cos(alpha)*(1+rnd(5)),
 		0,12,{8,8,10,2})
 end
 
  -- smoke particles.
 for s=0,4+flr(rnd(2)) do
	 alpha=rnd()
		add_ptc(pk_px+8,pk_py+8,
		 sin(alpha)*4+rnd(2),
		 cos(alpha)*4+rnd(2),
		 2,30+rnd(15),{4,2,5,1},5+rnd(6))
	end
  
 for s=0,6+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(pk_px+8,pk_py+8,
		 sin(alpha)*8+rnd(2),
		 cos(alpha)*8+rnd(2),
		 2,10+rnd(8),{11,8,9,4,3,2},5+rnd(6))
	end
end

function add_bad_pk_lost_ptc()
	local alpha
 for s=0,4+flr(rnd(2)) do
	 alpha=rnd()
		add_ptc(pk_px+8,pk_py-4,
		 sin(alpha)*4+rnd(4),
		 cos(alpha)*4+rnd(4),
		 2,30+rnd(15),{4,2,5,1},5+rnd(6))
	end
  
 for s=0,6+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(pk_px+8,pk_py-4,
		 sin(alpha)*8+rnd(4),
		 cos(alpha)*8+rnd(4),
		 2,10+rnd(8),{11,8,9,4,3,2},5+rnd(6))
	end
end

function add_knf_land_ptc()
	local angle
	
	-- pixel particles.
	for p=0,5+rnd(4) do
  angle=rnd()
 	add_ptc(knf_px+8,knf_py,
 		cos(angle)*(3+(rnd(4))),
 		sin(angle)*(3+(rnd(2))),
 		0,6,{7})
 end
 
 -- smoke particles.
 for s=1,4+flr(rnd(2)) do
	 alpha=rnd()
		add_ptc(knf_px+8,knf_py,
		 sin(alpha)*4+rnd(3),
		 cos(alpha)*4+rnd(3),
		 2,10+rnd(5),{7,6,13,5,1},2+rnd(3))
	end
end

function add_knf_throw_ptc()
	local alpha
	for s=1,2+flr(rnd(1)) do
	 alpha=rnd()
		add_ptc(knf_px+8,knf_py,
		 sin(alpha)*2+rnd(1),
		 cos(alpha)*2+rnd(1),
		 2,10+rnd(5),{7,6,13,5,1},2+rnd(3))
	end
end

function add_main_credits_ptc(_y)
 local alpha
 
 -- smoke particles.
 for s=1,8+flr(rnd(7)) do
	 alpha=rnd()
		add_ptc(60,_y,
		 sin(alpha)*7+rnd(2),
		 cos(alpha)*3+rnd(2),
		 2,5+rnd(5),{2,4,5,1,1},6+rnd(3))
	end
end

function add_mainmenu_pk_ptc()
 local alpha
 -- smoke particles.
 for s=1,20+flr(rnd(10)) do
	 alpha=rnd()
		add_ptc(56,40,
		 sin(alpha)*15+rnd(8),
		 cos(alpha)*15+rnd(8),
		 2,10+rnd(25),{7,8,9,9,2,5,1},8+rnd(4))
	end
 
 -- chunks.
 for p=0,8+flr(rnd(4)) do
	 alpha=rnd()
	 add_ptc(56,40,
	 	sin(alpha)*(2+rnd(4)),
	 	cos(alpha)*(2+rnd(5)),
	 	1,24,{65,66,67,81,82,83})
 end
 
 -- pixel particles.
 for p=0,50+rnd(20) do
 	alpha=rnd()
 	add_ptc(56,40,
 		sin(alpha)*(3+rnd(7)),
 		cos(alpha)*(3+rnd(7)),
 		0,24,{4,9,10,4})
 end
end

function add_mainmenu_play_pk_ptc()
 local alpha
 -- smoke particles.
 for s=1,20+flr(rnd(10)) do
	 alpha=rnd()
		add_ptc(56,94,
		 sin(alpha)*12+rnd(6),
		 cos(alpha)*12+rnd(6),
		 2,8+rnd(20),{7,8,9,9,2,5,1},6+rnd(3))
	end
 
 -- chunks.
 for p=0,6+flr(rnd(3)) do
	 alpha=rnd()
	 add_ptc(56,94,
	 	sin(alpha)*(2+rnd(3)),
	 	cos(alpha)*(2+rnd(4)),
	 	1,18,{65,66,67,81,82,83})
 end
 
 -- pixel particles.
 for p=0,30+rnd(15) do
 	alpha=rnd()
 	add_ptc(56,94,
 		sin(alpha)*(3+rnd(7)),
 		cos(alpha)*(3+rnd(7)),
 		0,24,{4,9,10,4})
 end
end

function add_pk_cut_ptc()
 local alpha
 
 -- pixel particles.
 for p=0,8+rnd(5) do
 	alpha=rnd()
 	add_ptc(pk_px+8,pk_py+8,
 		sin(alpha)*(2+rnd(2)),
 		cos(alpha)*(2+rnd(2)),
 		0,24,{4,9,10,4})
 end
 
 -- chunks.
 for p=0,1+flr(rnd(2)) do
	 alpha=rnd()
	 add_ptc(pk_px+8,pk_py+8,
	 	sin(alpha)*(2+rnd(2)),
	 	cos(alpha)*(2+rnd(2)),
	 	1,24,
	 	{65,66,67,81,82,83})
 end
end

function add_pk_lost_ptc()
 -- pixel particles.
 for p=0,10+rnd(5) do
 	local angle=rnd_vector_in_cone(90,135)
 	add_ptc(pk_px,pk_py-2,
 		angle.x*3,angle.y*(2+rnd(3)),
 		0,12,{10,9,8,2})
 end
 
 -- smoke particles.
 for s=0,6+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(pk_px+8,pk_py,
		 sin(alpha)*8+rnd(4),
		 cos(alpha)*8+rnd(4),
		 2,10+rnd(8),{8,9,10,7,7,2,1},3+rnd(3))
	end
end

function add_ptc(_x,_y,_dx,_dy,_t,_max_age,_col_seq,_s)
	local ptc={
		x=_x,
		y=_y,
		dx=_dx,
		dy=_dy,
		t=_t,
		age=0,
		max_age=_max_age,
		col_seq=_col_seq,
		size=_s,
		init_size=_s }
	
	if ptc.t==1 then
		ptc.col=ptc.col_seq[1+flr(rnd(#ptc.col_seq))]
	end
	
	add(ptcs, ptc)
end

function add_txt_display(_txt,_x,_y,_dx,_dy,_col_seq,_max_age)
 add(txts_displays,{
  txt=_txt,
	 x=_x,
	 y=_y,
	 dx=_dx,
	 dy=_dy,
	 col_seq=_col_seq,
	 age=0,
	 max_age=_max_age })
end

function set_shake(_trauma)
	cur_trauma=mid(0,_trauma,1)
end

function spawn_candle_ptcs()
	for c=1,rnd(3) do
		add_ptc(7+rnd(4),112,
		 -1+rnd(2),-0.1,
		 3,15+rnd(15),candle_ptcs_col_seq,1.2+rnd(2))
		
		add_ptc(18+rnd(4),118,
		 -1+rnd(2),-0.1,
		 3,15+rnd(15),candle_ptcs_col_seq,1.2+rnd(2))
		
		add_ptc(116+rnd(4),112,
		 -1+rnd(2),-0.1,
		 3,15+rnd(15),candle_ptcs_col_seq,1.2+rnd(2))
		
		add_ptc(104+rnd(4),118,
		 -1+rnd(2),-0.1,
		 3,15+rnd(15),candle_ptcs_col_seq,1.2+rnd(2))
		end
end
-->8
-- draw functions.


------------------------
-- pumpkin.
------------------------

function draw_pk()
	spr_outline(pk_spr,7,pk_px,pk_py,2,2,pk_flip)
	if pk_isbad then
		-- draw bad pk mask.
		palt(0,false)
		palt(12,true)
		spr(5,pk_px,pk_py,2,2,pk_flip)
		palt(0,true)
		palt(12,false)
	end
end

function draw_pk_light()
 if lvlup_timer>-1 then
		return
	end

	local light_px=pk_px+8
	local light_py=pk_py+8
	
	fillp(░)
	circfill(light_px,light_py,20,1)
 circfill(light_px,light_py,14,0)
 fillp(▒)
 circfill(light_px,light_py,14,1)
	fillp(◆)
	circfill(light_px,light_py,10,1)
	fillp()
end


------------------------
-- knife.
------------------------

function draw_knife()
	if not knf_anim_on then
		local x_input_h=knf_py-11+cos(timer/12)
		print("❎",knf_px+4,x_input_h,1)
		print("❎",knf_px+4,x_input_h-1,13)
	end
	
	local knf_spr=101
	if knf_spr_timer>-1 then
		-- knife rotation anim.
		knf_spr=get_table_item_mod(knf_spr_seq,1,0)
	end
	spr(knf_spr,knf_px,knf_py-8,2,2,knf_flipx)
end

function draw_knife_clamps()
	local dist_tomin=knf_py-knf_minh
	local dist_tomax=knf_maxh-knf_py

	local perc_tomin=flr(dist_tomin/(knf_maxh-knf_minh)*#knf_borders_col_seq)
	local perc_tomax=flr(dist_tomax/(knf_maxh-knf_minh)*#knf_borders_col_seq)
	
	perc_tomin=max(1,perc_tomin)
	perc_tomax=max(1,perc_tomax)
	
	for i=0,64 do
		pset(i*4,knf_minh,knf_borders_col_seq[perc_tomin])
		pset(i*4,knf_maxh,knf_borders_col_seq[perc_tomax])
	end
end

function draw_knife_scope()
	if knf_anim_on or last_lvl_done then
		return
	end
	
	for i=0,27 do
		pset(i*5+(timer%5)*knf_dir,knf_py,13)
	end
end


------------------------
-- gui.
------------------------

function draw_gover()			
	if gover_timer==-1 then
	 return
	end
	
	-- game over msg.
	local gover_msg_h=12
 local gover_msg_col=gover_msg_col_seq[#gover_msg_col_seq]

	if gover_timer<gover_msg_dur then
	 local gover_msg_perc=1-(gover_msg_dur-gover_timer)/gover_msg_dur
	 gover_msg_col=gover_msg_col_seq[1+flr(gover_msg_perc*#gover_msg_col_seq)]
		
		gover_msg_h=lerp(
		 20,12,out_quad(gover_msg_perc))
	end
	
	print("game over!",44,gover_msg_h,gover_msg_col)

	-- game stats.
	if gover_timer>60 then
		local score_x=49-(#tostr(score)-1)*2
	 print("score:"..score,score_x,41,1)
	 print("score:"..score,score_x,40,7)
		if gover_timer==61 then
			add_gover_stat_ptcs(42)
		end
		
		if gover_timer>80 then
		 local cut_pk_x=28-(#tostr(cut_pk)-1)*2
		 print("pumpkins slashed:"..cut_pk,cut_pk_x,48,1)
	  print("pumpkins slashed:"..cut_pk,cut_pk_x,47,7)
	 	if gover_timer==81 then
				add_gover_stat_ptcs(49)
			end
	 	
	 	if gover_timer>100 then
	 	 local cut_bad_pk_x=28-(#tostr(cut_bad_pk)-1)*2
	 	 print("bad pumpkins hit:"..cut_bad_pk,cut_bad_pk_x,55,1)
	  	print("bad pumpkins hit:"..cut_bad_pk,cut_bad_pk_x,54,7)
	 		if gover_timer==101 then
					add_gover_stat_ptcs(56)
				end
	 		
	 		if gover_timer>120 then
	 		 local max_combo_x=34-(#tostr(max_combo)-1)*2
	 		 print("highest combo:"..max_combo,max_combo_x,62,1)
	  		print("highest combo:"..max_combo,max_combo_x,61,7)
	 			if gover_timer==121 then
						add_gover_stat_ptcs(63)
					end
	 		end
	 	end
	 end
	end
end

function draw_gui()
 -- top panel.
	rectfill(-10,top_panel_h-10,135,top_panel_h+8,1)
	line(-10,top_panel_h+9,135,top_panel_h+9,2)
	
	-- level progression.
	if not last_lvl_done 
	and lvlup_timer==-1
	and cur_lvl_pk_counter+1!=cur_lvl.pk_count then
		line(0,top_panel_h+9,
		 128*(1-((cur_lvl_pk_counter+1)/cur_lvl.pk_count)),
		 top_panel_h+9,8)
	end
	
	print("level:"..cur_lvl_index,2,top_panel_h+3,0)
	print("level:"..cur_lvl_index,2,top_panel_h+2,7)
	
	local combo_x=52-(#tostr(combo)-1)*4
	print("combo:"..combo,combo_x,top_panel_h+3,0)
	print("combo:"..combo,combo_x,top_panel_h+2,7)
	
	local score_x=99-(#tostr(score)-1)*4
	print("score:"..score,score_x,top_panel_h+3,0)
	print("score:"..score,score_x,top_panel_h+2,7)
	
	-- lvl up popup.
	if lvlup_timer>-1 then
		local lvlup_perc=1-lvlup_timer/lvlup_dur
		local lvlup_col=lvlup_col_seq[1+flr(lvlup_perc*#lvlup_col_seq)]
		
		local lvlup_h=lerp(
		 26,17,out_quad(lvlup_perc))
		print("level up!",47,lvlup_h,lvlup_col)
	end
	
	-- start msg popup.
	if start_msg_timer>-1 then
		local start_msg_perc=1-start_msg_timer/start_msg_dur
		local start_msg_col=start_msg_col_seq[1+flr(start_msg_perc*#start_msg_col_seq)]
		
		local start_msg_h=lerp(
		 26,17,out_quad(start_msg_perc))
		print("slash!",54,start_msg_h,start_msg_col)
	end
end

function draw_mainmenu()
	if not mainmenu_pk_cut then
		fillp(░)
		circfill(64,36,20,1)
	 circfill(64,36,14,0)
	 fillp(▒)
	 circfill(64,36,14,1)
		fillp(◆)
		circfill(64,36,8,1)
		fillp()
	 spr_outline(1,7,56,28,2,2)
 else
 	-- actual main menu.
  mainmenu_title_h+=sin(mainmenu_title_wave)*0.6
  mainmenu_title_wave+=0.03
 	spr_outline(128,0,26,mainmenu_title_h,10,7)
		spr(get_table_item_mod(fire_anim_seq,3,0),77,mainmenu_title_h+1,1,2)
 
 	if mainmenu_timer>48 then
 		-- credits.
 		local credits_col=2
 		
 		if mainmenu_timer==49 then
 			add_main_credits_ptc(71)
 		end
		 if mainmenu_timer<52 then
			 credits_col=1
			end
 		print("by robin six",41,68-credits_col,credits_col)
 	 if mainmenu_timer>60 then
				credits_col=2
 	 	if mainmenu_timer==61 then
 				add_main_credits_ptc(78)
 			end
 			if mainmenu_timer<64 then
 			 credits_col=1
 			end
 	 	print("sixrobin.itch.io",33,75-credits_col,credits_col)
 		end
 	end
 	
 	-- play pumpkin.
 	if mainmenu_play_pk_on
 	and not mainmenu_play_pk_cut
 	then
			fillp(░)
			circfill(64,103,17,1)
		 circfill(64,103,12,0)
		 fillp(▒)
		 circfill(64,103,12,1)
			fillp()
		 spr_outline(33,7,56,94,2,2)
 	end 
 end
end


------------------------
-- feedback.
------------------------

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

function draw_txts_displays()
	for t in all(txts_displays) do
		print(t.txt,t.x,t.y,t.col)
	end
end


------------------------
-- enviro.
------------------------

function draw_enviro()
 local ptc
 
 -- candle particles.
 for p=1,#ptcs do
 	ptc=ptcs[p]
 	if ptc.t==3 then
			-- candle particles.
		 circfill(ptc.x,ptc.y,ptc.size,ptc.col)
 	end
 end
 
 -- fire sparks particles.
	for p=1,#dust_ptcs do
	 ptc=dust_ptcs[p]
	 circ(ptc.x,ptc.y,0,ptc.col)
	end

	-- spider webs.
	local rope_offset=0
	if (spider_ropes_offset>0) then
		rope_offset=spider_ropes_offset_seq[spider_ropes_offset]
	end
	
	local web_start_h=top_panel_h+9
	line(10,web_start_h,10+rope_offset,top_panel_h+34,13)
	line(25,web_start_h,25+rope_offset,top_panel_h+14,13)
	line(31,web_start_h,31+rope_offset,top_panel_h+11,6)
	line(100,web_start_h,100+rope_offset,top_panel_h+20,6)
	line(109,web_start_h,109+rope_offset,top_panel_h+14,13)
	spr(7,0,web_start_h,2,2)
	spr(9,112,web_start_h,2,4)
	
	fillp(░)
	rectfill(0,114,127,127,2)
	rectfill(0,122,127,127,0)
 fillp(▒)
	rectfill(0,122,127,127,8)
	fillp()
	
	-- candles.
	spr_outline(13,8,5,112,1,2)
	spr(get_table_item_mod(fire_anim_seq,3,0),
	 5,101,1,2)
	 
	spr_outline(14,8,15,119,1,2)
	spr(get_table_item_mod(fire_anim_seq,3,2),
	 16,107,1,2)
	 
	spr_outline(13,8,115,112,1,2)
	spr(get_table_item_mod(fire_anim_seq,3,1),
	 114,101,1,2,true)
	 
	spr_outline(14,8,103,119,1,2,true)
	spr(get_table_item_mod(fire_anim_seq,3,0),
	 103,107,1,2)
end
-->8
-- init functions.

function init_lvls()
 add(lvls,lvl_1)
 add(lvls,lvl_1) -- tmp.
	--add(lvls,lvl_2)
	--add(lvls,lvl_3)
	--add(lvls,lvl_4)
	--add(lvls,lvl_5)
			
	cur_lvl=lvls[1]
	cur_lvl_pk_counter=cur_lvl.pk_count
end

function init_sparks_ptcs()
 for p=0,30 do
  add(dust_ptcs,{
   x=rnd(127),
   y=128,
   dy=0.2+rnd(0.5),
   col=8+flr(rnd(2)),
   max_h=90+rnd(20)})
 end
end
-->8
-- update functions.

------------------------
-- levels.
------------------------

function update_gover()
	if last_lvl_done
	and top_panel_gover_timer<-24 then
	 if gover_timer<1 then
	 	add_gover_msg_ptcs()
	 end
	 gover_timer+=1
	 
	 if gover_timer>120 then
	 	-- do it a function.
	 	if btn(❎) then
	 		gstate="mainmenu"
	 		shake_counter=0
	 	end
	 end
	end
end

function update_lvlup()
	if lvlup_timer==-1 then
		return
	end
	
	lvlup_timer-=1

	if lvlup_timer==-1 then
		generate_pk()
	end
end


------------------------
-- knife.
------------------------

function update_knife_height()
	local any_input
	if not knf_anim_on then
		if btn(⬆️) then
		 knf_vely-=7
		 any_input=true
		end
		if btn(⬇️) then
			knf_vely+=7
			any_input=true
		end
	end
	
	if any_input then
		knf_vely=mid(-5,knf_vely,5)
	else
		knf_vely*=0.8
		if abs(knf_vely)<0.5 then
			knf_vely=0
		end
	end
	
	if gstate=="playing" then
		knf_py=mid(knf_minh,knf_py+knf_vely,knf_maxh)
	elseif gstate=="mainmenu" then
		knf_py=mid(16,knf_py+knf_vely,120)
	end
end

function update_knife_throw()
	if not knf_anim_on
	and not knf_input_pressed
	and btn(❎)
	then
		knf_vely=0
		knf_anim_on=true
		knf_hit_smth=false
		knf_input_pressed=true
		knf_spr_timer=0
		
		add_knf_throw_ptc()
		sfx(0)
	end
	
	knf_input_pressed=btn(❎)
end

function update_knife()
	-- block input while fading in.
	if gstate=="mainmenu"
	and not mainmenu_play_pk_cut
	and fade_perc!=0 then
	 return
	end

	update_knife_height()
	update_knife_throw()

	if not knf_anim_on
	or knf_hitpause>-1 then
		knf_hitpause-=1
		return
	end
	
	knf_px+=knf_dir*knf_speed
	knf_spr_timer+=1
	
	-- check walls.
	if knf_px>=112 or knf_px<=0 then
		-- land.
		knf_px=mid(0,knf_px,112)
		
		knf_anim_on=false
		knf_dir*=-1
		knf_spr_timer=-1
		knf_flipx=not knf_flipx
		add_knf_land_ptc()
		
		sfx(5)
		set_shake(0.07)
		spider_ropes_offset=1
		
		if not knf_hit_smth then
			if combo>0 then
				combo=0
				sfx(3)
				local txt_px=knf_px+knf_dir*10
				add_txt_display("combo",
				 txt_px,knf_py-16,txt_px,knf_py-31,{7,7,8,2},9)
				add_txt_display("lost!",
				 txt_px,knf_py-10,txt_px,knf_py-25,{7,7,8,2},9)
			end
		end
		knf_hit_smth=false
	end

	-- check pumpkin.
	if knf_anim_on then
		-- knife throw in game.
		if gstate=="playing" then
			if not last_lvl_done
			and lvlup_timer==-1
			and dist_sqr(pk_px+8,pk_py+12,knf_px+8,knf_py)<225
			then
				-- pumpkin cut.
				knf_hit_smth=true
				if pk_isbad then
					-- bad pk cut.
					cut_bad_pk+=1
					combo=0
					score=max(score-cur_lvl.malus*10)
					
					add_txt_display("-"..tostr(cur_lvl.malus),
						pk_px,pk_py,pk_px,pk_py-15,{7,8,2},12)
						
					set_shake(0.15)
					add_bad_pk_cut_ptc()
					sfx(2)
				else
					-- good pk cut.
					cut_pk+=1
					combo+=1
					max_combo=max(combo,max_combo)
					score+=combo
				
					add_txt_display("+"..combo,
						pk_px,pk_py,pk_px,pk_py-15,{7,7,10,8,1},12)
					
					set_shake(0.08)
					add_pk_cut_ptc()
					sfx(1)
				end
				
				knf_hitpause=1
				next_pk()
			end
		
		-- knife throw in menu.
		elseif gstate=="mainmenu" then
			if not mainmenu_pk_cut
			and dist_sqr(56,30,knf_px+8,knf_py)<225
			then
			 add_mainmenu_pk_ptc()
			 set_shake(0.15)
			 mainmenu_pk_cut=true
			end
			if mainmenu_play_pk_on
			and not mainmenu_play_pk_cut
			and dist_sqr(56,103,knf_px+8,knf_py)<225
			then
			 -- play.
			 mainmenu_play_pk_cut=true
			 add_mainmenu_play_pk_ptc()
			 set_shake(0.15)
			 mainmenu_play_pk_cut=true
			 mainmenu_play_timer=0
			end
		end
	end
end


------------------------
-- pumpkin.
------------------------

function update_pk()
	if last_lvl_done
	or not game_started
	or lvlup_timer>-1 then
		return
	end

	pk_vely+=cur_lvl.grav
	pk_px+=pk_velx
	pk_py+=pk_vely
	
	if pk_py>128 then
		if lvlup_timer==-1 then
			-- pumpkin lost.
			if not pk_isbad then
				add_pk_lost_ptc()
				combo=0
				sfx(3)
			else
			 add_bad_pk_lost_ptc()
				sfx(4)
			end
			
			next_pk()
			set_shake(0.06)
		end
	end
end


------------------------
-- gui.
------------------------

function update_fade()
	if fade_perc==fade_target_perc then
		fading=false
		return
	end
	
	fading=true
	fade_timer+=1
 if fade_timer>2 then
 	fade_perc=mid(0,fade_perc+0.2*sgn(fade_target_perc-fade_perc),1)
 	fade_timer=0
 end
end

function update_start_countdown()
	-- start message popup.
 if timer_playing>24 then
 	if start_msg_timer==-1
  and timer_playing==25 then
 		start_msg_timer=start_msg_dur
 		add_lvlup_ptcs()
 	elseif start_msg_timer>-1 then
			start_msg_timer-=1
		end
	end
	
	game_started=timer_playing>92
end

function update_mainmenu()
	if mainmenu_pk_cut then
	 mainmenu_timer+=1
	 mainmenu_play_pk_on=mainmenu_timer>100
	end
	
	if mainmenu_play_timer>-1 then
		mainmenu_play_timer+=1
		
		if mainmenu_play_timer>24
		and fade_target_perc!=1
		then
		 fade_target_perc=1
		end
		
		if mainmenu_play_timer>54 then
			init_playing_state()
		end
	end
end

function update_top_panel()
	if not last_lvl_done then
		return
	end
 
 if top_panel_gover_timer>0 then
 	top_panel_gover_timer-=1
 elseif top_panel_gover_timer==0 then
  top_panel_h-=1
  if top_panel_h<top_panel_gover_h then
  	top_panel_h=top_panel_gover_h
  	top_panel_gover_timer=-1
  end
 elseif top_panel_gover_timer<0 then
 	top_panel_gover_timer-=1
 end
end


------------------------
-- feedback.
------------------------

-- 0 - pixels.
-- 1 - chunks.
-- 2 - smoke.
-- 3 - candles.
function update_ptcs()
	local ptc
	for p=#ptcs,1,-1 do
	 ptc=ptcs[p]
	 ptc.age+=1
	 if ptc.age>ptc.max_age then
	  del(ptcs,ptcs[p])
	 else
	 	if ptc.t==0
	 	or ptc.t==2
	 	or ptc.t==3 then
		 	ptc.col=ptc.col_seq[
		 		1+flr((ptc.age/ptc.max_age) * #ptc.col_seq)]
	 	end
	 	
	 	-- shrink and brake smoke.
	 	if ptc.t==2 then
	 	 ptc.size=(1-(ptc.age/ptc.max_age))*ptc.init_size
	 	 ptc.dx*=0.75
	 	 ptc.dy*=0.75
	 	end
	 	
	 	-- shrink and raise candle ptcs.
	 	if ptc.t==3 then
	 	 ptc.size=(1-(ptc.age/ptc.max_age))*ptc.init_size
	 	 ptc.dx*=0.75
	 	 ptc.dy*=1.05
	 	end
	 	
	 	-- move particles.
	 	ptc.x+=ptc.dx
	 	if ptc.t==3 then
	 	ptc.y+=ptc.dy
	 	ptc.dy-=0.05
	 	else
		 	ptc.y+=ptc.dy
		 	-- apply gravity.
		 	ptc.dy+=0.15
	 	end
	 end
	end
end

function update_shake()
	local shake_x=(8-rnd(16))*cur_trauma
	local shake_y=(8-rnd(16))*cur_trauma
	
	camera(shake_x,shake_y)
	
	cur_trauma*=0.95
	if cur_trauma<0.05 then
	 cur_trauma=0
	end
end

function update_ropes_offset()
	if spider_ropes_offset>-1 then
	 spider_ropes_offset+=1
	 if (spider_ropes_offset>#spider_ropes_offset_seq) then
	 	spider_ropes_offset=-1
	 end
	end
end

function update_txts_displays()
	for t in all(txts_displays) do
		t.age+=1
		if t.age>t.max_age then
			del(txts_displays,t)
		else
			t.col=t.col_seq[1+flr((t.age/t.max_age)*#t.col_seq)]
	 	t.x+=(t.dx-t.x)/5
			t.y+=(t.dy-t.y)/5
		end
	end
end


------------------------
-- enviro.
------------------------

function update_candle_ptcs()
	candle_ptcs_timer+=1
	if candle_ptcs_timer > 4 then
		spawn_candle_ptcs()
		candle_ptcs_timer=0
	end
end

function update_sparks_ptcs()
 local ptc
 for p=1,#dust_ptcs do
  ptc=dust_ptcs[p]
 	if ptc.y<ptc.max_h then
			ptc.x=rnd(127)
   ptc.y=128
   ptc.dy=0.2+rnd(0.5)
   ptc.max_h=90+rnd(20)
	 else
	  ptc=dust_ptcs[p]
	 	ptc.y-=ptc.dy
 	end
 end
end
-->8
-- tools.

function dist_sqr(_ax,_ay,_bx,_by)
	return (_ax-_bx)*(_ax-_bx)+(_ay-_by)*(_ay-_by)
end

function lerp(_a,_b,_t)
	return _a*(1-_t)+_b*_t
end

function out_quad(_t)
	return _t*(2-_t)
end

function rnd_vector_in_cone(_angle,_wideness)
	rnd_dir = 
		rnd(_wideness/720)
		- rnd(_wideness/720)
		+ (_angle/360)

	return {
		x=cos(rnd_dir),
		y=sin(rnd_dir) }
end

function spr_outline(_n,_col,_x,_y,_w,_h,_flip_x,_flip_y)
 if fade_perc==0 then
	 -- set palette to color.
	 for c=1,15 do
	  pal(c,_col)
	 end
 end
 
 -- draw outline.
 for x=-1,1 do
  for y=-1,1 do
   spr(_n,_x+x,_y+y,_w,_h,_flip_x,_flip_y)
  end
 end
 
 -- set palette to fill color.
 for c=1,15 do
  pal(c,_fillcol)
 end
 
 -- draw fill.
 spr(_n,_x,_y,_w,_h,_flip_x,_flip_y)
 -- reset palette.
 pal()
 
 fade_pal(fade_perc)
 
 -- draw actual sprite.
 spr(_n,_x,_y,_w,_h,_flip_x,_flip_y)	
end

function get_table_item_mod(_table,_rate,_offset)
	return _table[flr((timer+_offset)/_rate)%#_table+1]
end

function fade_pal(_p)
	local p=flr(mid(0,_p,1)*100)
	local k_max,col
	local d_pal={
	 0,1,1,2,1,13,6,4,4,9,3,16,1,13,14}
	 
	for j=1,15 do
		col=j
		k_max=(p+(j*1.46))/22
		
		for k=1,k_max do
			col=d_pal[col]
		end
		
		pal(j,col)
	end
end
__gfx__
0000000000000033000000000000003300000000ccccccccccccccccd0d00d00d0060006d006d0dd0dd0d0000000000000000000000000000000000000000000
0000000000000333b000000000000333b0000000ccccccccccccccccd00d06dd600600066006d06006d6d0000000000000040000000000000000077000000000
0070070000000003300000000000000330000000cccccccccccccccc0d0d6000d6d600060d06d00dd60066dd000400000044000000007790009a7aa000000000
0007700000005553b544000000002223b5440000ccccccccccccccccdd660d0600606660006660066000d00d00940000000000000077aa000009965000000000
0007700000554533bb9aa90000224223bb9ffa00cccccccccccccccc00d00060006000600000d6d0600d000d0002000000009400009165000006665000000000
007007000544495335444a900244495525444f90cccccccccccccccc00600606660000600000d000060d00060009440000029000006665000006165000000000
0000000055499944449aa4992249444444940499cccccccccccc0ccc0060d000606606000000d60006d0000d00299900000920000061650000d6565000000000
000000005449944aa4aaaa492449024ff4500f49cccc0cccccc00cccd60600066000660000006600060600d00029990000aa90000065650000dd66dd00000000
0000000054994499aa4aaa992494000af4080a99cccc000ccc0c0ccc0006066060006600000060d66000606000aa900000aaa00000655500022dd22220000000
0000000054994499aa4aa99924940080f400af99cccc00c0cc00cccc00666000060606000000d0060000060004aaa400059aa000006555000000000000000000
0000000054994499994aa94924942004a44a90f9ccccc00cccccc0cc66606000066006000000600600000d6d0277740005977600006565d00000000000000000
00000000555494999a499a49222099999990d049ccc0ccccccc0c0cc006006000660060000006000600d660002777f0002f77000006555d00000000000000000
0000000005445499949994900240d0d0d0707f90ccc0c0c0c0c0cccc06000606600006000000600066600d0000777000007770000d5565d00000000000000000
0000000005454949949994000244007070000400cccc00c0c0000ccc0600666000000600000060000600600000070000000700000d6666d00000000000000000
0000000000555449944440000022440070444000cccccc00c0cccccc6666000000000000000060000060600000000000000000000d666dd00000000000000000
0000000000005544444000000000244444400000cccccccccccccccc00000000000000000000600000660000000000000000000022d2dd220000000000000000
00000000000000000000000000000000b30000000000000000000000000000000000000000006000006060000000000000000000000000000000000000000000
000000000000000330000000000000003b000000000000000000000000000000000000000000600000606d000000000000000000000000000000000000000000
000000000000000333b0000000000000300000000000000000000000000000000000000000006000006060600000000000000000000000000000000000000000
00000000000000003b00000000005555354440000000000000000000000000000000000000006000006060060000400000000000000000000000000000000000
00000000000045553554000000054443354494900000000000000000000000000000000000006000006000000000500000940000000000000000000000000000
0000000000054453b544900000549495b449a9490000000000000000000000000000000000006000006000000045500000200000000000000000000000000000
000000000054444bb49a4a000054499449a499490000000000000000000000000000000000006000006000000499000000004900000000000000000000000000
00000000005499449a4aa490054949a49aaa49a9000000000000000000000000000000000000600000000000004990000000a900000000000000000000000000
0000000005499499aaa4aa90054949a999aa49a9000000000000000000000000000000000000600000000000000aa900000a9000000000000000000000000000
000000000549949aaaa4aa990549494999aa49a9000000000000000000000000000000000000600000000000000aaa00005aa000000000000000000000000000
000000005549a999aaa49a990549494999aa49a900000000000000000000000000000000000000000000000000f77f2004a79400000000000000000000000000
000000005449a999aaa49a4900544994999a494000000000000000000000000000000000000000000000000005f7700005777400000000000000000000000000
00000000544994999aa9994900054994999a49000000000000000000000000000000000000000000000000000077700000770000000000000000000000000000
000000000544949999a494400000549499a444000000000000000000000000000000000000000000000000000007000000070000000000000000000000000000
00000000005445499944440000000544999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000555444440000000000004444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004949000000040000000a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004499a000009440000aaa400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000494a000aa9440009994940000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000
0000000000494a000a94940004444440000000000000000000000000000000000000000000000000000000000002400000040000000000000000000000000000
00000000004440000049450000045500000000000000000000000000000000000000000000000000000000000005000000a90000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009000000990000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009900000044a000000000000000000000000000
000000000090000000000540000b0000000000000000000000000000000000000000000000000000000000000aaa90000004aa00000000000000000000000000
00000000049a00000000949000b30000000000000000000000000000000000000000000000000000000000000afff00000f7a400000000000000000000000000
000000004999a00000aa949000330000000000000000000000000000000000000000000000000000000000000d77400000777500000000000000000000000000
00000000d449aaa000a4499000030000000000000000000000000000000000000000000000000000000000000277000000277000000000000000000000000000
0000000000449a40000049000003b000000000000000000000000000000000000000000000000000000000000007000000070000000000000000000000000000
000000000000ddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000077000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000076000000000076000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000
00000000000000776000000000076600000000000000000000000000000000000000544000000000000000000000000000000000000000000000000000000000
000000000000007666000000000076d0000000000000000000000000000000000004554400000000000000000000000000000000000000000000000000000000
00000000000000766d0000000000766d000000000000000000000000000000060024455000000000000000000000000000000000000000000000000000000000
00000000000000766d0000000000076dd00000000000000000600000000000006552440000000000000000000000000000000000000000000000000000000000
00000000000000766d00000000000766dd06000000006ddddd6022040000000d6655000000000000000000000000000000000000000000000000000000000000
00000000000000766d00000000000076666000007766666666652454000000dd6665000000000000000000000000000000000000000000000000000000000000
00000000000000776d0000000000000766500000077766666765245400000dd66706000000000000000000000000000000000000000000000000000000000000
000000000000066666600000000000006552000000077777776024040000d6667000000000000000000000000000000000000000000000000000000000000000
00000000000000055000000000000006554420000000000000600000000666770000000000000000000000000000000000000000000000000000000000000000
00000000000000444200000000000000004455000000000000000000006677000000000000000000000000000000000000000000000000000000000000000000
00000000000000444200000000000000004554200000000000000000077700000000000000000000000000000000000000000000000000000000000000000000
00000000000000055000000000000000000544000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000444200000000000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000500000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000494900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000049000004499a0000000000000000009400000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000009000000499a00000000000000000a9900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000040449aa0000000000049900000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000490499900000000000224400000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000900000000000000000000000002240000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000b000000000000000000000000000011100000011101110111000001110000000000000000000000000000000000000000000000000000000000000000
000000b3000000001111110111111011110117111111117111711171111011710000000000000000000000000000000000000000000000000000000000000000
0000003300000000177771117117111771117f1177f711f711f11171171117f10000000000000000000000000000000000000000000000000000000000000000
000000030000000017f11711f1171117f711ff17f11f11ff17f111f11f711ff10000000000000000000000000000000000000000000000000000000000000000
00000003b00000001ff11f17f11f111fff17ff17f11f11ffff111ff17ff11f110000000000000000000000000000000000000000000000000000000000000000
00000000000000011fff711ff11f117f1fffff1fffff11fff1111f11f1ff1f100000000000000000000000000000000000000000000000000000000000000000
00000000000000011f11111f111f11ff1ff1f11f111111fff111ff11f11fff100000000000000000000000000000000000000000000000000000000000000000
0000000000000001ff11111f11ff11f11111f11f11111ff1f111ff11f11ff1101000000000000000000000000000000000000000000000000000000000000000
0000000000000101ee1221eeeeee11e1111ee1ee12211e11e111ee1ee11ee1101000000000000000000000000000000000000000000000000000000000000000
00000000d0010101f11221fffff11ff1211ff1f112211f11fff1f11ff111f10010d00d0000000000000000000000000000000000000000000000000000000000
00000000000000011128211111111111221111f18821ff111111f111111111010010000000000000000000000000000000000000000000000000000000000000
00000000000000008820228888282282028221118021111111111111122820000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000008280028888822828228820000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000
00000000000000000011111001111001111111110000111111111111111110101d0d000000000000000000000000000000000000000000000000000000000000
0000000000d001010117771111771011771177f111111171177ff1777f7110000000033000000000000000000000000000000000000000000000000000000000
0000000000000d01017f1f7f11f11017ff11f1ff117717f17ff1f17f11f71055000000b000000000000000000000000000000000000000000000000000000000
000000000000000101ff11ff11f1111ff117f11f11f11ff1ff11111f11ff10550000000000000000000000000000000000000000000000000000000000000000
000000000000500001ff11111ff111fff11ff11111f11f11f111111f77f110544000000000000000000000000000000000000000000000000000000000000000
0000000000000000011ff7111f1111f1f111ff1117ff7f11fff111ffff1100549000000000000000000000000000000000000000000000000000000000000000
00000000000000000011fff11f1111f7f1111ff11fffff11f11111f1f11004440000000000000000000000000000000000000000000000000000000000000000
000000000000000011111ff1ff111ff1f11111f11ff1f11ff1111ff1ff1054000000a90000000000000000000000000000000000000000000000000000000000
00000000000000001f7711e1ee111e11e1ee1ee1eee1e11ee1ee1e111e10500000aaa40000000000000000000000000000000000000000000000000000000000
0000000000000900111ffff1ffff1f1ff11ffff1ff11f11ffff1ff111f1000000999494000000000000000000000000000000000000000000000000000000000
00000009000099000211111111111111111111111111ff1111111112111000000444444000000000000000000000000000000000000000000000000000000000
0000000000049a000022822888822282888222828221111888822822820000000004550000000000000000000000000000000000000000000000000000000000
0000000000049a000000000000000000000000000082822000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004999a00000225220000004550000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000000
0000009000d449aaa900055450000004500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000449a4000004500004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000ddd000000000004000000000000090000000000000000000000009900000000000000000000000000000000000000000000000000000000000
0000000000000000000000000a094400000000000090000000000000000000000000400000000000000000000000000000000000000000000000000000000000
0000000000000000000000009aa94400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004a949400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000494500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000004990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11711177717171777171111111771111111111111111111111111771177177717771177111117771111111111111111111117711771177177717771111171111
11711170017171700171111711071111111111111111111111117001707177717071707117110071111111111111111111170017001707170717001171171111
11711177117171771171111011171111111111111111111111117111717170717701717110111771111111111111111111177717111717177017711101177711
11711170117771701171111711171111111111111111111111117111717171717071717117111071111111111111111111100717111717170717011171170711
11777177710701777177711011777111111111111111111111110771770171717771770110117771111111111111111111177010771770171717771101177711
11000100011011000100011111000111111111111111111111111001001101010001001111110001111111111111111111100111001001101010001111100011
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
d00d06dd60d60006000000000d00000600000000000000000000000000000000000000000000000000000000000000000000600000000d006006d06006d6d000
0d0d6000d6d60006000000000d00000600000000000000000000000000000000000000000000000000000000000000000000600000000d000d06d00dd60066dd
dd660d0600606660000000000d00000000000000000000000000000000000000000000000000000000000000000000000000600000000d00006660066000d00d
00d0006000600060000000000d00000000000000000000000000000000000000000000000000000000000000000000000000600000000d000000d6d0600d000d
0060060666d00060000000000d00000000000000000000000000000000000000000000000000000000000000000000000000600000000d000000d000060d0006
0060d000606606000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000d60006d0000d
d606000660d0660000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000006600060600d0
0006066060d06600000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000060d660006060
0066600006d606000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000d00600000600
66606000066006000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000600600000d6d
006006000660060000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000006000600d6600
0600060660d006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600066600d00
0600666000d006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600006006000
6666000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000606000
0000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000660000
0000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000606000
0000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000606d00
0000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000606060
0000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000606006
0000000000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000600000
1000100010d010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010601000
0000000000d000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000600000600000
0000000000d000000000000000000000000000000000000000000000000000000000009000000000000000000000000000000000000000000000600000000000
0000000000d000000000000000000000000000000000000000000000000000000000009000000000042000000000000000000000000000000000600000000000
0000000000d000000000000000000000000000000000000000000005000000000000000005000000050000000000000000000000000000000000600000000000
00000000000000000000000000000000000000000000000004400000000000000000000000000004550000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000494900000000000000000000000004a400000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000049000004499a00000000000000000094000004a90000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000009000000499a00000000000000000a99000000aa9000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000040449aa00000000000499000000000000aaa500000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000004904999000000000002244000000000006fff200000000000000000000000000000000000000000000
00000ddddd000000000000000000000000000000900000000000000000000000002240000000005f760000000000000000000000000000000000000000000000
0000dd1d1dd0000000000000000000000b000000000000000000000000000011100000011101110d750000011100000000000000000000000000000000000000
0000ddd1ddd000000000000000000000b30000000011111101111110111101171111111171117111711110117100000000000000000000000000000000000000
0000dd1d1dd0000000000000000000003300000000177771117117111771117f1177f711f711f11171171117f100000000000000000000000000000000000000
00001ddddd1000000000000000000000030000000017f11711f1171117f711ff17f11f11ff17f111f11f711ff100000000000000000000000000000000000000
0000011111000000000000000000000003b00000001ff11f17f11f111fff17ff17f11f11ffff111ff17ff11f1100000000000000000000000000000000000000
0000000000000000000000000000000000000000011fff711ff11f117f1fffff1fffff11fff1111f11f1ff1f1000000000000000000000000000000000000000
0000000000000000000000000000000000000000011f11111f111f11ff1ff1f11f111111fff111ff11f11fff1000000000000000000000000000000000000000
000000000000000000000000000000000000000001ff11111f11ff11f11111f11f11111ff1f111ff11f11ff11010000000000000000000000000000000000000
000006000000000000000000000000000000000101ee1221eeeeee11e1111ee1ee12211e11e111ee1ee11ee11010000000000000000000000000000000000000
402206ddddd60000000000000000000000d0010101f11221fffff11ff1211ff1f112211f11fff1f11ff111f10010d00d00000000000000000000000000000000
4542566666666677000000000000000000000000011128211111111111221111f18821ff111111f1111111110100100000000000000000000000000000000000
45425676666677700000000000000000000000000088202288882822820282211180211111111111111228200000000000000000000000000000000000000000
40420677777770000000000000000000000000000000000000000000000000082800288888228282288200000000000000000000000000000000000000000000
00000600000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010000000000000000000000000000000000000
0000000000000000000000000000000000000000000011111001111001111111110000111111111111111110101d0d0000000000000000000000000000000000
000000000000000000000000000000000000d001010117771111771011771177f111111171177ff1777f71100000000330000000000000000000000000000000
000000000000000000000000000000000000000d01017f1f7f11f11017ff11f1ff117717f17ff1f17f11f71055000000b0000000000000000000000000000000
00000000000000000000000000000000000000000101ff11ff11f1111ff117f11f11f11ff1ff11111f11ff105500000000000000000000000000000000000000
00000000000000000000000000000000000000500001ff11111ff111fff11ff11111f11f11f111111f77f1105440000000000000000000000000000000000000
000000000000000000000000000000000000000000011ff7111f1111f1f111ff1117ff7f11fff111ffff11005490000000000000000000000000000000000000
0000000000000000000000000000000000000000000011fff11f1111f7f1111ff11fffff11f11111f1f110044400000000000000000000000000000000000000
00000000000000000000000000000000000000000011111ff1ff111ff1f11111f11ff1f11ff1111ff1ff1054000000a900000000000000000000000000000000
0000000000000000000000000000000000000000001f7711e1ee111e11e1ee1ee1eee1e11ee1ee1e111e10500000aaa400000000000000000000000000000000
000000000000000000000000000000000000000900111ffff1ffff1f1ff11ffff1ff11f11ffff1ff111f10000009994940000000000000000000000000000000
0000000000000000000000000000000009000099000211111111111111111111111111ff11111111121110000004444440000000000000000000000000000000
000000000000000000000000000000000000049a0000228228888222828882228282211118888228228200000000045500000000000000000000000000000000
000000000000000000000000000000000000049a0000000000000000000000000000828220000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000004999a000002252200000045500000000000000000000000009000000000000000000000000000000000000000000
000000000000000000000000000000009000d449aaa9000554500000045000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000449a40000045000040000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000ddd0000000000040000000000000900000000000000000000000099000000000000000000000000000000000
000000000000000000000000000000000000000000000000000a0944000000000000900000000000000000000000004000000000000000000000000000000000
000000000000000000000000000000000000000000000000009aa944000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000004a9494000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000004945000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000004990000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000049900000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000900000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000
00000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055500000000
00000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000
00000000000000000000000000000000000000000009000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000042000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000240000000000
00000009058000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000
00000094558800001000000000000000000000000000000000000000000000000008000000000000000000000000000000000005000000000000555400000000
0000004a408000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004a40000000
00000004a9900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a400000000
00000777aa99008090000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000009aa790000000
00007777aaa500000000000000000000000000000000000000090000000000000000000000000000090000080000000000000000000420000005aaa770000000
00007776fff200000094000000000000000000000000000000000000000000000000000000000000000000000000000000000000080500000002fff670000000
0000775f760000000020101000000000000000000000000000000000009080000000000000000000000000000000000000000000845590000000767f50000000
0000077d7588800000004a00000000000000000000000000000000000000000000000000000000000000000000000000000000004a4900000000057d88800000
20002088777980002005a9502000200020002000200020002000200020002000200020002000200020002000200020002000200024a920002000887779802000
002000877aa88020002a99200020002000200020002000200020002000200020002000200020002000200020002000200020002000aa9a200020877aa8800020
2000208916582000205aa5072000200020002000200020002000200020002000200020002000200020002000200020002000200020aaa5002008891658002000
002000866658002004a7f4277020002000200020002000200020002000200020002000200028002000200020002000200020002006fff2200020866658200020
20002086165820002577a507200020002000200020002000200020002000200020002000200020002000200020002000200020005f7620002000861658002000
002000865658002000678880002000200020002000200020002000200020002000200020002000200020002000200020002000288d7500200020865658200020
20002086555820008887778020002080200020002000200020002000200020002000200020002000200020002000200020002008777888002000865558002000
002000865558802089a7aa8000200020002000200020002000200020002000200020002000200020002000200020002000200028aa7a98200020865558800020
80808086565d8980889965808080808080808080808080808080808080808080808080808080808080808080808080808080808856998880808086565d808080
08080886555d8808086665880808080808080808080808080808080808080808080808080808080808080808080808080808080856668808080886555d880808
808088d5565d80808861658080808080888080808080808080808080808080808080808080808080808080808080808080808088561688808088d5565d808080
080808d6666d88088d656588080808080808080808080808080808080808080808080808080808080808080808080808080808885656d8080808d6666d880808
808088d666dd88888dd66dd88080808080808080808080808080808080808080808080808080808080808080808080808080808dd66dd8808988d666dd888080
0808822d2dd2280822dd22280808080808080808080808080808080808080808080808080808080808080808080808080808088222dd228808822d2dd2289808

__sfx__
00020000286402864023640156300663000620006003b6003a6003a6003d6003d6002160021600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000020500605011050270501d0503b050330501e050170501705025050370501c050230500f0600f05012060180601b060100502d0503f04027010080000b0000e00015000340003a000000000000000000
000200002815027150251501f150131500d1500e1500f1501115012150111500b150061500315004150081500a1500b1500615003150001500115000100001000010000100001000010000100001000010000100
000200001a05019050170501505013040100400d0400a030090300703006020050200301002010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a640286402764024640226401e6401b6401864014640106300e6300c6300b62009620086200662005620046200361002610016100061000600056000360003600026000260002600016000160001600
000100002563031630366302b62020610166100a6100261000600006000e6000c6000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
