pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- pumpkin slasher.
-- robin six.

------------------------

----------------
----- todo -----
----------------

-- ● general.
-- ∧ ? replay pk fall/reset pk.

-- ● ? sfx retake.
-- ● music.

-- ● wishlist.
-- ∧ cuttable spider.
-- ∧ full knife rotation anim.
-- ∧ pk rotation.
-- ∧ more control on lvls gen.

------------------------


function _draw()
	cls(0)
	fade_pal(fade_perc)

	if gstate=="mainmenu" then
		draw_enviro()
		draw_knife()
		draw_mainmenu()
	elseif gstate=="playing" then
		draw_pks_lights()
		draw_knife_clamps()
		draw_knife_scope()
		draw_pks()
		draw_enviro()
		draw_knife()
		draw_gui()
		draw_msg_popup()
	 draw_gover()
	end
	
	draw_ptcs()
	draw_txts_displays()
	
	-- ● debug.
	--line(pk_px+8,pk_py+10,knf_px+8,knf_py,11)
 --print(cur_lvl_timer,40,11,11)
 --print(game_started,40,11,11)
end

function _init()
	-- ● debug.
	--add(lvls,lvl_tuto)
	--add(lvls,lvl_onlybad)
 --add(lvls,lvl_1)
 --add(lvls,lvl_bonus)
 --add(lvls,lvl_onlycandies)
	--add(lvls,lvl_test)

 add(lvls,lvl_tuto)
 add(lvls,lvl_1)
	add(lvls,lvl_2)
	add(lvls,lvl_3)
	add(lvls,lvl_4)
	add(lvls,lvl_bonus)
	add(lvls,lvl_5)
	add(lvls,lvl_6)

 init_sparks_ptcs()
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
	 update_lvl()
		update_lvlup()
		update_gover()
		update_knife()
		update_pks()
		update_top_panel()
	end
	
	update_fade()
	update_ptcs()
	update_shake()
	update_txts_displays()
	
	update_candle_ptcs()
	update_dust_ptcs()
	update_sparks_ptcs()
	update_ropes_offset()
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

mainmenu_pk_cut,
mainmenu_play_pk_cut,
mainmenu_play_pk_on
 =false,false,false

mainmenu_title_h=8
mainmenu_title_wave=0

mainmenu_play_timer=-1
mainmenu_play_pk_h=67


------------------------
-- levels.
------------------------

game_started,game_over
 =false,false

lives=3

cur_lvl=nil
cur_lvl_index=1
cur_lvl_timer=0

exp,exp_to_next_lvl=0

lvls={}

lvl_onlybad={
 exp=10,
 bad_pk_perc=1,
 candy_perc=0,
 pk_base_vely=-9,
 rnd_add_vely=2,
 grav=0.35,
 add_pk_timer=20}

lvl_onlycandies={
 exp=10,
 bad_pk_perc=0,
 candy_perc=1,
 pk_base_vely=-9,
 rnd_add_vely=2,
 grav=0.35,
 add_pk_timer=20}

lvl_test={
 exp=100,
 bad_pk_perc=0,
 candy_perc=0.5,
 pk_base_vely=-9,
 rnd_add_vely=2,
 grav=0.35,
 add_pk_timer=20}

lvl_tuto={
 exp=3,
 bad_pk_perc=0,
 candy_perc=0,
 pk_base_vely=-7,
 rnd_add_vely=0,
 grav=0.25,
 add_pk_timer=-1}

lvl_bonus={
 exp=20,
 bad_pk_perc=0,
 candy_perc=0,
 pk_base_vely=-11,
 rnd_add_vely=2,
 grav=0.55,
 add_pk_timer=10}

lvl_1={
 exp=5,
 bad_pk_perc=0,
 candy_perc=0,
 pk_base_vely=-9,
 rnd_add_vely=2,
 grav=0.35,
 add_pk_timer=100}
 
lvl_2={
 exp=10,
 bad_pk_perc=0.15,
 candy_perc=0.04,
 pk_base_vely=-10.5,
 rnd_add_vely=2.5,
 grav=0.4,
 add_pk_timer=125}
 
lvl_3={
 exp=15,
 bad_pk_perc=0.25,
 candy_perc=0.04,
 pk_base_vely=-11,
 rnd_add_vely=3,
 grav=0.5,
 add_pk_timer=100}
 
lvl_4={
 exp=25,
 bad_pk_perc=0.4,
 candy_perc=0.05,
 pk_base_vely=-11,
 rnd_add_vely=3,
 grav=0.5,
 add_pk_timer=-1}
 
lvl_5={
 exp=30,
 bad_pk_perc=0.25,
 candy_perc=0.07,
 pk_base_vely=-13,
 rnd_add_vely=2,
 grav=0.55,
 add_pk_timer=70}
 
lvl_6={
 exp=25,
 bad_pk_perc=0.4,
 candy_perc=0.04,
 pk_base_vely=-11,
 rnd_add_vely=3,
 grav=0.5,
 add_pk_timer=50}


back_to_menu_timer=-1
back_to_menu_pk_cut,back_to_menu_pk_on
 =false,false


------------------------
-- pumpkin.
------------------------

pks={}
pk_sprs={1,33,35}
-- rest in generate_pk().


------------------------
-- knife.
------------------------

knf_vely=0
knf_min_h,knf_max_h=30,85
knf_input_pressed=false

knf_spr_seq={97,99,101,103}
knf_px,knf_py,knf_dir=0,87,1
knf_anim_on,knf_hit_smt
 =false,false
knf_flipx=true
knf_hitpause=-1

knf_borders_col_seq={8,2,2,1,1,1,1,1,1,1,1,1}


------------------------
-- scoring.
------------------------

score,combo,cut_pk,max_combo
 =0,0,0,0


------------------------
-- gui.
------------------------

fade_perc,fade_target_perc,fade_timer
 =0,0,0

msg_popup=""
msg_popup_timer=-1
msg_popup_dur=nil
msg_popup_col_seq={}
msg_popup_x=50
msg_popup_init_h,msg_popup_target_h
 =26,17

lvlup_timer=-1
gover_timer=-1

top_panel_h=-11
top_panel_gover_h=-11
top_panel_timer=48

last_heart_col_seq={7,7,14,8,14}


------------------------
-- feedback.
------------------------

cur_trauma=0
ptcs,txts_displays={},{}


------------------------
-- enviro.
------------------------

spark_ptcs,dust_ptcs={},{}
candle_ptcs_timer=0
candle_ptcs_col_seq={7,10,9,8,5,1,0}
ropes_offset=-1
ropes_offset_seq=
{3,-2,-2,1,1,1,-0.5,-0.5,0.5,0}
fire_anim_seq={11,12,43,44,75,76}
-->8
-- punctual functions.

------------------------
-- general.
------------------------

function init_playing_state()
	gstate="playing"
	pks={}
	
	fade_target_perc=0
	--top_panel_h=0
	combo,exp,lives=0,0,3
	exp_to_next_lvl=lvls[1].exp
	
	cur_lvl_index=1
 cur_lvl=lvls[1]
	
	-- reset main menu values.
	mainmenu_timer=0
	mainmenu_play_pk_cut,
	mainmenu_play_pk_on
	 =false,false
	mainmenu_play_timer=-1
	knf_py=56
end

function next_lvl()	
	cur_lvl_index+=1
	cur_lvl=lvls[cur_lvl_index]
	cur_lvl_timer=0
	
 exp=0
 exp_to_next_lvl=lvls[cur_lvl_index].exp

	set_msg_popup("level up!",30,
	 47,26,17,
	 {1,2,8,10,7,7,7,7,8,8,2,1})
  	 
 lvlup_timer=40
	add_lvlup_ptcs()
end

function reset_playing_state()
 cur_lvl_index=1
 cur_lvl=lvls[1]

 game_over,
 game_started,
 back_to_menu_pk_on,
 back_to_menu_pk_cut
  =false,false,false,false
 
 exp,score=0,0
	exp_to_next_lvl=cur_lvl.exp
 
 timer_playing=0
	back_to_menu_timer,
 gover_timer,
 start_msg_timer
  =-1,-1,-1
	
	top_panel_gover_timer=48
	top_panel_h=top_panel_gover_h

	knf_py=87
end


------------------------
-- pumpkin.
------------------------

function generate_pk()
	local pk={
		px=20+rnd(80),
		py=128,
		vely=cur_lvl.pk_base_vely+rnd(cur_lvl.rnd_add_vely),
		isbad=rnd()<cur_lvl.bad_pk_perc,
		isflip=rnd()<0.5,
		sprite=3}

	pk.velx=rnd(1.5)*sgn(60-pk.px)
	if not pk.isbad then
		if lives<5
		and rnd()<cur_lvl.candy_perc
		then
			pk.sprite=37
			pk.iscandy=true
		else
			pk.sprite=pk_sprs[1+flr(rnd(#pk_sprs))]
		end
	end
	
	add(pks,pk)
	sfx(11)
end

function on_candy_cut(pk)
	lives=min(lives+1,5)
	exp+=1
	
	candy_cut_feedback(pk.px,pk.py)
	add_life_gain_ptc(5+lives*5)
end

function on_pk_cut(pk)
	cut_pk+=1
	combo+=1
	max_combo=max(combo,max_combo)
	score+=combo
	exp+=1
	
	pk_cut_feedback(pk.px,pk.py)
end

function on_bad_pk_cut(pk)
	cut_pk+=1
	combo=0
	lives-=1
	game_over=lives==0
	
	bad_pk_cut_feedback(pk.px,pk.py)
	add_life_loss_ptc(5+lives*6)
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

function gover_stat_feedback(_y)
 local alpha
 for s=1,6+flr(rnd(3)) do
	 alpha=rnd()
		add_ptc(64,_y,
		 sin(alpha)*10+rnd(3),
		 cos(alpha)*2+rnd(3),
		 2,10+rnd(5),{7,6,13,5,1},3+rnd(4))
	end
	
	sfx(7)
end

function add_life_loss_ptc(_x)
 local alpha
 for s=1,4+flr(rnd(3)) do
	 alpha=rnd()
		add_ptc(_x,5,
		 sin(alpha)*2+rnd(3),
		 cos(alpha)*2+rnd(3),
		 2,7+rnd(4),{7,8,8,5,2},2+rnd(3))
	end
end

function add_life_gain_ptc(_x)
 local alpha
 for s=1,4+flr(rnd(3)) do
	 alpha=rnd()
		add_ptc(_x,5,
		 sin(alpha)*4+rnd(3),
		 cos(alpha)*4+rnd(3),
		 2,3+rnd(4),{2,8,14,15,7,7},2+rnd(3))
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

function set_msg_popup(_txt,_dur,_x,_init_h,_target_h,_col_seq)
	msg_popup=_txt
	msg_popup_timer=_dur
	msg_popup_dur=_dur
	msg_popup_col_seq=_col_seq
	msg_popup_x=_x
	msg_popup_init_h=_init_h
	msg_popup_target_h=_target_h
	
	sfx(9)
end


------------------------
-- feedback.
------------------------

function add_dust_ptcs(_count)
	for d=1,_count do
		add(dust_ptcs,{
		 px=rnd(127),
		 py=top_panel_h+rnd(2)-2,
		 vely=1+rnd(1),
		 max_h=5+rnd(15)})
	end
end

function bad_pk_cut_feedback(_x,_y)
 local alpha
 -- pixel particles.
 for p=1,10+rnd(5) do
 	alpha=rnd()
 	add_ptc(_x+8,_y+8,
 		sin(alpha)*(1+rnd(5)),
 		cos(alpha)*(1+rnd(5)),
 		0,12,{8,8,10,2})
 end
 
  -- smoke particles.
 for s=1,5+flr(rnd(2)) do
	 alpha=rnd()
		add_ptc(_x+8,_y+8,
		 sin(alpha)*4+rnd(2),
		 cos(alpha)*4+rnd(2),
		 2,30+rnd(15),{4,2,5,1},5+rnd(6))
	end
  
 for s=1,7+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(_x+8,_y+8,
		 sin(alpha)*8+rnd(2),
		 cos(alpha)*8+rnd(2),
		 2,10+rnd(8),{11,8,9,4,3,2},5+rnd(6))
	end
	
	add_txt_display("-1♥",
		_x,_y,_x,_y-15,{7,8,2},12)
	set_shake(0.15)
	sfx(2)
end

function knf_land_feedback()
	local angle
	-- pixel particles.
	for p=1,6+rnd(4) do
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
	
	sfx(5)
	set_shake(0.07)
	ropes_offset=1
end

function knf_throw_feedback()
	local alpha
	for s=1,2+flr(rnd(1)) do
	 alpha=rnd()
		add_ptc(knf_px+8,knf_py,
		 sin(alpha)*2+rnd(1),
		 cos(alpha)*2+rnd(1),
		 2,10+rnd(5),{7,6,13,5,1},2+rnd(3))
	end
	
	sfx(0)
end

function add_credits_ptc(_y)
 local alpha
 for s=1,8+flr(rnd(7)) do
	 alpha=rnd()
		add_ptc(62,_y,
		 sin(alpha)*7+rnd(2),
		 cos(alpha)*3+rnd(2),
		 2,5+rnd(5),{2,4,5,1,1},6+rnd(3))
	end
end

function title_pop_feedback()
 local alpha
 -- smoke particles.
 for s=1,20+flr(rnd(10)) do
	 alpha=rnd()
		add_ptc(56,mainmenu_title_h+26,
		 sin(alpha)*15+rnd(8),
		 cos(alpha)*15+rnd(8),
		 2,10+rnd(25),{7,8,9,9,2,5,1},8+rnd(4))
	end
 
 -- chunks.
 for p=1,9+flr(rnd(4)) do
	 alpha=rnd()
	 add_ptc(56,mainmenu_title_h+26,
	 	sin(alpha)*(2+rnd(4)),
	 	cos(alpha)*(2+rnd(5)),
	 	1,24,{65,66,67,81,82,83})
 end
 
 -- pixel particles.
 for p=1,50+rnd(20) do
 	alpha=rnd()
 	add_ptc(56,mainmenu_title_h+26,
 		sin(alpha)*(3+rnd(7)),
 		cos(alpha)*(3+rnd(7)),
 		0,24,{4,9,10,4})
 end
 
 set_shake(0.15)
 sfx(4)
 sfx(6)
end

function add_mainmenu_play_pk_ptc()
 local alpha
 -- smoke particles.
 for s=1,20+flr(rnd(10)) do
	 alpha=rnd()
		add_ptc(56,mainmenu_play_pk_h,
		 sin(alpha)*12+rnd(6),
		 cos(alpha)*12+rnd(6),
		 2,8+rnd(20),{7,8,9,9,2,5,1},6+rnd(3))
	end
 
 -- chunks.
 for p=1,7+flr(rnd(3)) do
	 alpha=rnd()
	 add_ptc(56,mainmenu_play_pk_h,
	 	sin(alpha)*(2+rnd(3)),
	 	cos(alpha)*(2+rnd(4)),
	 	1,18,{65,66,67,81,82,83})
 end
 
 -- pixel particles.
 for p=1,30+rnd(15) do
 	alpha=rnd()
 	add_ptc(56,mainmenu_play_pk_h,
 		sin(alpha)*(3+rnd(7)),
 		cos(alpha)*(3+rnd(7)),
 		0,24,{4,9,10,4})
 end
 
 set_shake(0.12)
	sfx(1)
end

function menus_pk_pop_feedback(_y)
 local alpha
 for s=1,10+flr(rnd(7)) do
	 alpha=rnd()
		add_ptc(62,_y,
		 sin(alpha)*7+rnd(4),
		 cos(alpha)*7+rnd(4),
		 2,4+rnd(7),{10,9,2,4,1,1},6+rnd(3))
	end
	
	sfx(8)
end

function candy_cut_feedback(_x,_y)
 local alpha
 -- pixel particles.
 for p=1,8+rnd(5) do
 	alpha=rnd()
 	add_ptc(_x+8,_y+8,
 		sin(alpha)*(2+rnd(2)),
 		cos(alpha)*(2+rnd(2)),
 		0,24,{2,14,8,15})
 end
 
 -- smoke particles.
 for s=1,7+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(_x+8,_y,
		 sin(alpha)*5+rnd(4),
		 cos(alpha)*5+rnd(4),
		 2,10+rnd(8),{14,15,8,8,7,2,1},5+rnd(3))
	end
 
 -- chunks.
 for p=1,4+flr(rnd(3)) do
	 alpha=rnd()
	 add_ptc(_x+8,_y+8,
	 	sin(alpha)*(2+rnd(2)),
	 	cos(alpha)*(2+rnd(2)),
	 	1,24,{39,40,55,56})
 end
 
 add_txt_display("+1♥",
		_x,_y,_x,_y-25,{7,15,14,8,2,1},12)
	set_shake(0.065)
	sfx(12)
end

function pk_cut_feedback(_x,_y)
 local alpha
 -- pixel particles.
 for p=1,8+rnd(5) do
 	alpha=rnd()
 	add_ptc(_x+8,_y+8,
 		sin(alpha)*(2+rnd(2)),
 		cos(alpha)*(2+rnd(2)),
 		0,24,{4,9,10,4})
 end
 
 -- chunks.
 for p=1,2+flr(rnd(2)) do
	 alpha=rnd()
	 add_ptc(_x+8,_y+8,
	 	sin(alpha)*(2+rnd(2)),
	 	cos(alpha)*(2+rnd(2)),
	 	1,24,
	 	{65,66,67,81,82,83})
 end
 
 add_txt_display("+"..combo,
		_x,_y,_x,_y-15,{7,7,10,8,1},12)
	set_shake(0.08)
	sfx(1)
end

function bad_pk_lost_feedback(_x,_y)
	local alpha
 for s=1,5+flr(rnd(2)) do
	 alpha=rnd()
		add_ptc(_x+8,_y-4,
		 sin(alpha)*4+rnd(4),
		 cos(alpha)*4+rnd(4),
		 2,30+rnd(15),{4,2,5,1},5+rnd(6))
	end
  
 for s=1,7+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(_x+8,_y-4,
		 sin(alpha)*8+rnd(4),
		 cos(alpha)*8+rnd(4),
		 2,10+rnd(8),{11,8,9,4,3,2},5+rnd(6))
	end
	
	sfx(4)
end

function pk_lost_feedback(_x,_y)
 -- pixel particles.
 for p=1,11+rnd(5) do
 	local angle=rnd_vector_in_cone(90,135)
 	add_ptc(_x,_y-2,
 		angle.x*3,angle.y*(2+rnd(3)),
 		0,12,{10,9,8,2})
 end
 
 -- smoke particles.
 for s=1,7+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(_x+8,_y,
		 sin(alpha)*8+rnd(4),
		 cos(alpha)*8+rnd(4),
		 2,10+rnd(8),{8,9,10,7,7,2,1},3+rnd(3))
	end
	
	sfx(3)
end

function candy_lost_feedback(_x,_y)
 -- pixel particles.
 for p=1,11+rnd(5) do
 	local angle=rnd_vector_in_cone(90,135)
 	add_ptc(_x,_y-2,
 		angle.x*3,angle.y*(2+rnd(3)),
 		0,12,{8,14,15,2})
 end
 
 -- smoke particles.
 for s=1,7+flr(rnd(4)) do
	 alpha=rnd()
		add_ptc(_x+8,_y,
		 sin(alpha)*8+rnd(4),
		 cos(alpha)*8+rnd(4),
		 2,10+rnd(8),{15,14,8,8,7,2,1},3+rnd(3))
	end
	
	sfx(13)
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

function candles_burst()
	for c=1,1+flr(rnd(2)) do
		add_ptc(7+rnd(4),112,
		 0,-0.2-rnd(0.4),
		 3,20+rnd(13),candle_ptcs_col_seq,2+rnd(2.5))
		
		add_ptc(18+rnd(4),118,
		 0,-0.2-rnd(0.4),
		 3,20+rnd(13),candle_ptcs_col_seq,2+rnd(2.5))
		
		add_ptc(116+rnd(4),112,
		 0,-0.2-rnd(0.4),
		 3,20+rnd(13),candle_ptcs_col_seq,2+rnd(2.5))
		
		add_ptc(104+rnd(4),118,
		 0,-0.2-rnd(0.4),
		 3,20+rnd(13),candle_ptcs_col_seq,2+rnd(2.5))
		end
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

function draw_pks()
 if game_started
 and lvlup_timer==-1
 then
		for p=1,#pks do
			local pk=pks[p]
			spr_outline(pk.sprite,7,pk.px,pk.py,2,2,pk.isflip)
			if pk.isbad then
				-- bad pk mask.
				palt(0,false)
				palt(12,true)
				spr(5,pk.px,pk.py,2,2,pk.isflip)
				palt()
			end
		end
	end
end

function draw_pk_light(_x,_y)
	local light_px=_x+8
	local light_py=_y+8
		
	fillp(░)
	circfill(light_px,light_py,20,1)
 circfill(light_px,light_py,14,0)
 fillp(▒)
 circfill(light_px,light_py,14,1)
	fillp(◆)
	circfill(light_px,light_py,10,1)
	fillp()
end

function draw_pks_lights()
 if game_started
 and lvlup_timer==-1
 then
		for p=1,#pks do
			draw_pk_light(pks[p].px,pks[p].py)
		end
	end
end


------------------------
-- knife.
------------------------

function draw_knife()
	local knf_spr=101
	
	if knf_anim_on then
		knf_spr=get_table_item_mod(knf_spr_seq,1,0)
	else
		print_shadow("❎",knf_px+4,knf_py-12+cos(timer/12),13,1)
	end

	spr(knf_spr,knf_px,knf_py-8,2,2,knf_flipx)
end

function draw_knife_clamps()
	local perc_tomin=max(1,flr((knf_py-knf_min_h)/(knf_max_h-knf_min_h)*#knf_borders_col_seq))
	local perc_tomax=max(1,flr((knf_max_h-knf_py)/(knf_max_h-knf_min_h)*#knf_borders_col_seq))
	
	for i=0,32 do
		if gover_timer==-1 or abs(16-i)>gover_timer then
			pset(i*4,knf_min_h,knf_borders_col_seq[perc_tomin])
			pset(i*4,knf_max_h,knf_borders_col_seq[perc_tomax])
		end
	end
end

function draw_knife_scope()
	if knf_anim_on or game_over then
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
	
	if gover_timer>24 then
	 print("game over!",44,12,8)
	end

	-- game stats.
	local score_add_l=#tostr(score)-1
	local cut_pk_add_l=#tostr(cut_pk)-1
	local max_combo_add_l=#tostr(max_combo)-1
	
	if gover_timer>60 then
		local score_x=49-score_add_l*2
	 rectfill(score_x-1,29,score_x+27+score_add_l*4,36,0)
		print_shadow("score:"..score,score_x,30,7,1)
		if gover_timer==61 then
			gover_stat_feedback(32)
		end
		
		if gover_timer>80 then
		 local cut_pk_x=28-cut_pk_add_l*2
		 rectfill(cut_pk_x-1,36,cut_pk_x+71+cut_pk_add_l*4,43,0)
	 	print_shadow("pumpkins slashed:"..cut_pk,cut_pk_x,37,7,1)
	 	if gover_timer==81 then
				gover_stat_feedback(39)
			end
	 	
	 	if gover_timer>100 then
	 	 local max_combo_x=34-max_combo_add_l*2
	 	 rectfill(max_combo_x-1,43,max_combo_x+59+max_combo_add_l*4,50,0)
	 	 print_shadow("highest combo:"..max_combo,max_combo_x,44,7,1)
	 		if gover_timer==101 then
					gover_stat_feedback(46)
				end
	 	end
	 end
	 
	 if gover_timer>140 then
	 	if not back_to_menu_pk_cut then
				draw_pk_light(56,72)
			 spr_outline(1,7,56,72,2,2)
		 end
	 end
	end
end

function draw_gui()
 -- top panel.
	rectfill(-10,top_panel_h-10,135,top_panel_h+8,1)
	line(-10,top_panel_h+9,135,top_panel_h+9,2)
	
	-- level progression.
	if not game_over
	and exp>0
	then
		line(0,top_panel_h+9,
		 128*(exp/exp_to_next_lvl),
		 top_panel_h+9,8)
	end
	
	for l=1,5 do
		local heart_px=1+(l-1)*6
		local heart_col=7
		-- last heart pulse.
		if l==1 and lives==1 then
			heart_col=get_table_item_mod(last_heart_col_seq,2,1)
		end
		
		if l>lives then
		 spr(68,heart_px,top_panel_h+2)
		else
			print_shadow("♥",heart_px,top_panel_h+2,heart_col,0)
		end
		
	end

	print_shadow("combo:"..combo,52-(#tostr(combo)-1)*4,top_panel_h+2,7,0)
	print_shadow("score:"..score,99-(#tostr(score)-1)*4,top_panel_h+2,7,0)
end

function draw_mainmenu()
	if not mainmenu_pk_cut then
		draw_pk_light(56,28)
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
 			add_credits_ptc(100)
 			sfx(7)
 		end
		 if mainmenu_timer<52 then
			 credits_col=1
			end
			rectfill(40,97,88,103,0)
 		print("by robin six",41,100-credits_col,credits_col)
 	 if mainmenu_timer>60 then
				credits_col=2
 	 	if mainmenu_timer==61 then
 				add_credits_ptc(107)
 				sfx(7)
 			end
 			if mainmenu_timer<64 then
 			 credits_col=1
 			end
 	 	rectfill(32,104,96,110,0)
 	 	print("sixrobin.itch.io",33,107-credits_col,credits_col)
 		end
 	end
 	
 	-- play pumpkin.
 	if mainmenu_play_pk_on
 	and not mainmenu_play_pk_cut
 	then
 		-- not using the draw light
 		-- function to use another
 		-- radius.
 		local light_py=mainmenu_play_pk_h+9
			fillp(░)
			circfill(64,light_py,17,1)
		 circfill(64,light_py,12,0)
		 fillp(▒)
		 circfill(64,light_py,12,1)
			fillp()
		 spr_outline(33,7,56,mainmenu_play_pk_h,2,2)
 	end 
 end
end

function draw_msg_popup()
	if msg_popup_timer>-1 then
		local msg_popup_perc=1-msg_popup_timer/msg_popup_dur
		local msg_popup_col=msg_popup_col_seq[1+flr(msg_popup_perc*#msg_popup_col_seq)]
		
		msg_popup_timer-=1
		
		local msg_popup_h=lerp(
		 msg_popup_init_h,
		 msg_popup_target_h,
		 out_quad(msg_popup_perc))
		 
		print(msg_popup,msg_popup_x,msg_popup_h,msg_popup_col)
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
 
 -- dust particles.
 for p=1,#dust_ptcs do
 	ptc=dust_ptcs[p]
 	pset(ptc.px,ptc.py,5)
 end
 
 -- fire sparks particles.
	for p=1,#spark_ptcs do
	 ptc=spark_ptcs[p]
	 circ(ptc.x,ptc.y,0,ptc.col)
	end

	-- spider webs.
	local offset=0
	if (ropes_offset>0) then
		offset=ropes_offset_seq[ropes_offset]
	end
	
	local web_start_h=top_panel_h+9
	line(10,web_start_h,10+offset,top_panel_h+34,13)
	line(25,web_start_h,25+offset,top_panel_h+14,13)
	line(31,web_start_h,31+offset,top_panel_h+11,6)
	line(100,web_start_h,100+offset,top_panel_h+20,6)
	line(109,web_start_h,109+offset,top_panel_h+14,13)
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

function init_sparks_ptcs()
 for p=1,30 do
  add(spark_ptcs,{
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
	if game_over
	and top_panel_timer<-24
	then
	 if gover_timer<1 then
	 	add_gover_msg_ptcs()
	 	set_msg_popup("game over!",24,
			 44,20,12,
			 {1,2,5,4,8})
	 end
	 
	 gover_timer+=1
	 
	 if gover_timer>140 then
	 	if gover_timer==141 then
	 		menus_pk_pop_feedback(86)
	 	end
	 	back_to_menu_pk_on=true
	 	if back_to_menu_pk_cut
	 	and back_to_menu_timer==-1
	 	then
	 		back_to_menu_timer=0
	 	end
	 	if back_to_menu_timer>-1 then
	 		back_to_menu_timer+=1
	 		if back_to_menu_timer>12 then
	 			fade_target_perc=1
	 			if back_to_menu_timer>40 then
	 				-- back to menu.
	 			 gstate="mainmenu"
	 			 fade_target_perc=0
						reset_playing_state()
	 			end
	 		end
	 	end
	 end
	end
end

function update_lvl()
	if exp>=cur_lvl.exp
	and cur_lvl_index<#lvls
	and #pks==0
 then
	 next_lvl()
	 return
	end

	if lvlup_timer>-1
	or not game_started
	or game_over then
	 return
	end
	
	if exp<cur_lvl.exp
	and #pks==0
	then
		generate_pk()
	end
	
	if exp<cur_lvl.exp then
		cur_lvl_timer+=1
		if cur_lvl.add_pk_timer>-1
		and cur_lvl_timer>cur_lvl.add_pk_timer
		then
			generate_pk()
			cur_lvl_timer=0
		end
	end
end

function update_lvlup()
	if lvlup_timer>-1 then
		lvlup_timer-=1
		if lvlup_timer==-1 then
			generate_pk()
		end
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
	
	if gstate=="playing"
	and gover_timer==-1
	then
		knf_py=mid(knf_min_h,knf_py+knf_vely,knf_max_h)
	else
		knf_py=mid(16,knf_py+knf_vely,104)
	end
end

function update_knife_throw()
	if not knf_anim_on
	and not knf_input_pressed
	and btn(❎)
	then
		knf_vely=0
		knf_anim_on,knf_input_pressed
		 =true,true
		knf_hit_smth=false
		knf_throw_feedback()
	end
	
	knf_input_pressed=btn(❎)
end

function update_knife_mainmenu()
	if not mainmenu_pk_cut
	and dist_sqr(56,30,knf_px+8,knf_py)<225
	then
		mainmenu_pk_cut=true
	 title_pop_feedback()
	elseif mainmenu_play_pk_on
	and not mainmenu_play_pk_cut
	and dist_sqr(56,mainmenu_play_pk_h+9,knf_px+8,knf_py)<225
	then
	 -- play.
	 mainmenu_play_pk_cut=true
	 mainmenu_play_timer=0
	 add_mainmenu_play_pk_ptc()
	end
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
	
	knf_px+=knf_dir*14
	
	-- check walls.
	if knf_px>=112 or knf_px<=0 then
		-- land.
		knf_px=mid(0,knf_px,112)
		knf_anim_on=false
		knf_dir*=-1
		knf_flipx=not knf_flipx
		
		if not knf_hit_smth then
			if combo>0
			and not game_over
			and game_started then
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
		knf_land_feedback()
		add_dust_ptcs(5)
	end

	-- check pumpkins / candies.
	if knf_anim_on then
		if game_started then
			if not game_over
			and lvlup_timer==-1
			then
				for p=#pks,1,-1 do
					local pk=pks[p]
					if dist_sqr(pk.px+8,pk.py+12,knf_px+8,knf_py)<225 then
						knf_hit_smth=true
						if pk.isbad then
							on_bad_pk_cut(pk)
						elseif pk.iscandy then
							on_candy_cut(pk)
						else
							on_pk_cut(pk)
						end
						
						knf_hitpause=1
						del(pks,pk)
					end
				end
							
				if game_over then
					pks={}
				end
				
			elseif back_to_menu_pk_on
			and not back_to_menu_pk_cut
			and dist_sqr(56,74,knf_px+8,knf_py)<225
			then
				-- back to menu pumpkin.
				back_to_menu_pk_cut=true
				add_mainmenu_play_pk_ptc(86)
			end
		elseif gstate=="mainmenu" then
			update_knife_mainmenu()
		end
	end
end


------------------------
-- pumpkins.
------------------------

function update_pks()
	if game_over
	or not game_started
	or lvlup_timer>-1 then
		return
	end

	for p=#pks,1,-1 do
		local pk=pks[p]
		
		pk.vely+=cur_lvl.grav
		pk.px+=pk.velx
		pk.py+=pk.vely
		
		if pk.py>128 then
			if pk.iscandy then
				candy_lost_feedback(pk.px,pk.py)
			elseif not pk.isbad then
				combo=0
				pk_lost_feedback(pk.px,pk.py)
			else
			 bad_pk_lost_feedback(pk.px,pk.py)
			end
			
			del(pks,pk)
			
			candles_burst()
			set_shake(0.06)
		end
	end
end


------------------------
-- gui.
------------------------

function update_fade()
 fading=fade_perc!=fade_target_perc
	if fading then
		fade_timer+=1
	 if fade_timer>2 then
	 	fade_perc=mid(0,fade_perc+0.2*sgn(fade_target_perc-fade_perc),1)
	 	fade_timer=0
	 end
	end
end

function update_start_countdown()
	if timer_playing==64 then
 	set_msg_popup("slash!",40,
 	 54,26,17,
 	 {1,2,8,9,7,7,7,7,8,5,2,1})
 	 
		add_lvlup_ptcs()
	end
	game_started=timer_playing>120
end

function update_mainmenu()
	if mainmenu_pk_cut then
	 mainmenu_timer+=1
		if mainmenu_timer==100 then
			menus_pk_pop_feedback(mainmenu_play_pk_h+9)
		end
	 mainmenu_play_pk_on=mainmenu_timer>=100
	end
	
	if mainmenu_play_timer>-1 then
		mainmenu_play_timer+=1
		
		if mainmenu_play_timer>24 then
		 fade_target_perc=1
		end
		
		if mainmenu_play_timer>54 then
			init_playing_state()
		end
	end
end

function update_top_panel()
	if game_over then
		if top_panel_timer>0 then
	 	if top_panel_timer==1 then
	 		sfx(10)
	 	end
 		top_panel_timer-=1
 	elseif top_panel_timer==0 then
  	top_panel_h-=1
	  if top_panel_h<top_panel_gover_h then
	  	top_panel_h=top_panel_gover_h
	  	top_panel_timer=-1
	  	set_shake(0.075)
	  end
 	elseif top_panel_timer<0 then
 		top_panel_timer-=1
 	end
	else -- if not game started.
		if timer_playing>30 and top_panel_h<0 then
			if timer_playing==31 then
				sfx(10)
			end
			top_panel_h+=1
	  if top_panel_h>=0 then
	  	top_panel_h=0
	  	set_shake(0.09)
	  end
	 end
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
	if ropes_offset>-1 then
	 ropes_offset+=1
	 if (ropes_offset>#ropes_offset_seq) then
	 	ropes_offset=-1
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
	if candle_ptcs_timer>4 then
		spawn_candle_ptcs()
		candle_ptcs_timer=0
	end
end

function update_dust_ptcs()
	local ptc
	for p=#dust_ptcs,1,-1 do
		ptc=dust_ptcs[p]
		ptc.py+=ptc.vely
		if ptc.py>ptc.max_h then
			del(dust_ptcs,ptc)
		end
	end
end

function update_sparks_ptcs()
 local ptc
 for p=1,#spark_ptcs do
  ptc=spark_ptcs[p]
 	if ptc.y<ptc.max_h then
			ptc.x=rnd(127)
   ptc.y=128
   ptc.dy=0.2+rnd(0.5)
   ptc.max_h=90+rnd(20)
	 else
	  ptc=spark_ptcs[p]
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
	rnd_dir=rnd(_wideness/720)
		-rnd(_wideness/720)
		+(_angle/360)

	return{
	 x=cos(rnd_dir),
		y=sin(rnd_dir)}
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

function print_shadow(_txt,_x,_y,_col,_scol)
	print(_txt,_x,_y+1,_scol)
	print(_txt,_x,_y,_col)
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
00000000000000000000000000000000b30000000000000000001000000000000000000000006000006060000000000000000000000000000000000000000000
000000000000000330000000000000003b00000000000000002ffd000ffef000002000000000600000606d000000000000000000000000000000000000000000
000000000000000333b00000000000003000000000000000002ee81008ef2f000086000000006000006060600000000000000000000000000000000000000000
00000000000000003b000000000055553544400000000000002d8181001eee0000ff000000006000006060060000400000000000000000000000000000000000
0000000000004555355400000005444335449490000002fffe2118800012e0000e2f000000006000006000000000500000940000000000000000000000000000
0000000000054453b544900000549495b449a94900001feeeef21100000000000000000000006000006000000045500000200000000000000000000000000000
000000000054444bb49a4a000054499449a499490000de8effef1000000000000000000000006000006000000499000000004900000000000000000000000000
00000000005499449a4aa490054949a49aaa49a90001e8eeefe8000000000000000000000000600000000000004990000000a900000000000000000000000000
0000000005499499aaa4aa90054949a999aa49a90001e88eeee8000000000000000000000000600000000000000aa900000a9000000000000000000000000000
000000000549949aaaa4aa990549494999aa49a90001d88eeee8000000000000000eef000000600000000000000aaa00005aa000000000000000000000000000
000000005549a999aaa49a990549494999aa49a902222888ee82000000f100000002ee00000000000000000000f77f2004a79400000000000000000000000000
000000005449a999aaa49a4900544994999a49400eff2188882000000fffd00000028f80000000000000000005f7700005777400000000000000000000000000
00000000544994999aa9994900054994999a4900dee8d211100000000fee8000000186e000000000000000000077700000770000000000000000000000000000
000000000544949999a494400000549499a44400018d82000000000000d810000000000000000000000000000007000000070000000000000000000000000000
0000000000544549994444000000054499940000001d800000000000000800000000000000000000000000000000000000000000000000000000000000000000
00000000000555444440000000000004444000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000dd0dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000440000000004000000000000d0d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004949000000040000000a9000d000d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000004499a000009440000aaa40000d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000494a000aa9440009994940000d00000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000
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
__label__
0d0d6000d6d60006000000000d00000600000000000000000000000000000000000000000000000000000000000000000000600000000d000d06d00dd60066dd
dd660d0600606660000000000d00000000000000000000000000000000000000000000000000000000000000000000000000600000000d00006660066000d00d
00d0006000600060000000000d00000000000000000000000000000000000000000000000000000000000000000000000000600000000d000000d6d0600d000d
0060060666d00060000000000d00000000000000000000000000000000000000000000000000000000000000000000000000600000000d000000d000060d0006
0060d000606606000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000d60006d0000d
d606000660d0660000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000006600060600d0
0006066060d06600000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000060d660006060
0066600006d606000000000000000000000000000000000000000000000000000000000500000000400000000000000000006000000000000000d00600000600
66606000066006000000000000000000000000000000000000000000000000000000009000000009400000000000000000006000000000000000600600000d6d
006006000660060000000000000000000000000000000000000000000000000000000090000000002000000000000000000060000000000000006000600d6600
0600060660d006000000000000000000000000000000000000000005000000000000000005000000944000000000000000000000000000000000600066600d00
0600666000d006000000000000000000000000000000000004400000000000000000000000000002999000000000000000000000000000000000600006006000
6666000000d000000000000000000000000000000000000004949000000000000000000000000002999000000000000000000000000000000000600000606000
0000000000d000000000000000000000000000000049000004499a0000000000000000009400000aa90000000000000000000000000000000000600000660000
0000000000d000000000000000000000000000000009000000499a00000000000000000a9900004aaa4000000000000000000000000000000000600000606000
0000000000d00000000000000000000000000000000000040449aa00000000000499000000000027774000000000000000000000000000000000600000606d00
0000000000d00000000000000000000000000000000000490499900000000000224400000000002777f000000000000000000000000000000000600000606060
0000000000d000000000000000000000000000009000000000000000000000000022400000000007770000000000000000000000000000000000600000606006
0000000000d0000000000000000000000b0000000000000000000000000000111000000111011101710000011100000000000000000000000000600000600000
0000000000d000000000000000000000b30000000011111101111110111101171111111171117111711110117100000000000000000000000000600000600000
0000000000d0000000000000000000003300000000177771117117111771117f1177f711f711f11171171117f100000000000000000000000000600000600000
0000000000d000000000000000000000030000000017f11711f1171117f711ff17f11f11ff17f111f11f711ff100000000000000000000000000600000000000
0000000000d00000000000000000000003b00000001ff11f17f11f111fff17ff17f11f11ffff111ff17ff11f1100000000000000000000000000600000000000
0000000000d00000000000000000000000000000011fff711ff11f117f1fffff1fffff11fff1111f11f1ff1f1000000000000000000000000000600000000000
0000000000000000000000000000000000000000011f11111f111f11ff1ff1f11f111111fff111ff11f11fff1000000000000000000000000000000000000000
000000000000000000000000000000000000000001ff11111f11ff11f11111f11f11111ff1f111ff11f11ff11010000000000000000000000000000000000000
000000000000000000000000000000000000000101ee1221eeeeee11e1111ee1ee12211e11e111ee1ee11ee11010000000000000000000000000000000000000
0000000000000000000000000000000000d0010101f11221fffff11ff1211ff1f112211f11fff1f11ff111f10010d00d00000000000000000000000000000000
0000000000000000000000000000000000000000011128211111111111221111f18821ff111111f1111111110100100000000000000000000000000000000000
00000000000000000000000000000000000000000088202288882822820282211180211111111111111228200000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000082800288888228282288200000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000
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
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddd000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd1d1dd00000
00000000000000000000000000000000000000000000000000000000000000100010000000000000000000000000000000000000000000000000ddd1ddd00000
00000000000000000000000000000000000000000000000000000000000010001000100000000000000000000000000000000000000000000000dd1d1dd00000
000000000000000000000000000000000000000000000000000000000010001000100010000000000000000000000000000000000000000000001ddddd100000
00000000000000000000000000000000000000000000000000000000100010001000100010000000000000000000000000000000000000000000011111000000
00000000000000000000000000000000000000000000000000000010001000100010001000100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000100010101010100010001000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000010001101010101011000100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000101010101010101010001000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100010010101777701010100100010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000101010733777101010001000000000000000000000000000000000000000000000600000
000000000000000000000000000000000000000000000000001000010101017333b70101010000100000000000000000000000000000000000006ddddd602204
00000000000000000000000000000000000000000000000010001010101777773b77701010101000100000000000000000000000000000007766666666652454
00000000000000000000000000000000000000000000000000100101017745553554770101010010000000000000000000000000000000000777666667652454
0000000000000000000000000000000000000000000000001000101017754453b544977010101000100000000000000000000000000000000007777777602404
000000000000000000000000000000000000000000000000001001010754444bb49a4a7701010010000000000000000000000000000000000000000000600000
00000000000000000000000000000000000000000000000010001010775499449a4aa49710101000100000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000010010175499499aaa4aa9771010010000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000100010177549949aaaa4aa9970101000100000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000001001075549a999aaa49a9971010010000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000100010175449a999aaa49a4970101000100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100107544994999aa9994971010010000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000100010177544949999a4944770101000100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100101775445499944447701010010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000010001010177555444447777010101000100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100001017777777777010101000010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000101010101010101010001000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000100010010101010101010100100010000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000101010101010101010001000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000010001101010101011000100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000001000100010101010100010001000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000010001000100010001000100000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000100010001000100010000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000001000100010001000000000000000000000000000000000000000000000000000000000
00000000000010000000000000000000000000000000000000000000000010001000100000000000000000000000000000000000000000000000010000000000
00000000000000000000000000000000000000000000000000000000000000100010000000000000000000000000000000000000000000000000000000800000
00000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800000000000000000000000
00000000000000000000000000000000000000000222020200000222002202220222022000000022022202020000000000000000000000000000000000000000
00000000000000000000000000000000000000000202020200000202020202020020020200000200002002020000000000000000000000000000000000000000
00000000000000000000000000080000000000000220022200000220020202200020020200000222002000200000000000000000000000000000000000000000
00000001000000000000000000000000000000000202000200000202020202020020020200000002002002020000000000000000000000000000008000000000
00000000000000000000000000000000000000000222022200000202022002220222020200000220022202020000000000000000000000000000000000000000
00000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000
00000009400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004900000000
00000000200000000000000000000000002202220202022200220222022202200000022202220022020200000222002200000000000000000000002000000000
00000000944000000000000000000000020000200202020202020202002002020000002000200200020200000020020200000000000000000000449000000000
00000002999000000000100000000000022200200020022002020220002002020000002000200200022200000020020200000000050000000000999200000000
00000002999000000000000000000000000200200202020202020202002002020000002000200200020200000020020200000000000000000000999200000000
000000aaa9000000000400000000000002200222020202020220022202220202002002220020002202020020022202200000000000400000000009aa00000000
00000a4aaa40000008940000000000000000000000000000000000000000000000000000000000000000000000000000000000800940000000004aaa40000000
00000027774000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000002000000000477720000000
0000002777f008000009440000000000000000000000000000000000000000000000000000000000000000000000000000000000809440000000f77720000000
00000007778880000029990000000000000000000000000000000000000000000000000000000000000000000000000000000008829990000000077788800000
20002088777980002029990020002000200020002000200020002000200028002000200020002000200020002000200020002000229990002000887779802000
002000877aa8802000aa9020902000200020002000200020002000200020002000200020002000200020002000200020002000200aa900200020877aa8800020
200020891658200024aaa409290020002000200020092000200020002000200020002000200020002000200020002000200020004aaa40002000891658002000
00200086665800200277742090200020002000200020002000200020002000200020002000200020002000200020002000200020277740200020866658200020
200020861658200022777f00200020002008200020002000200020002000200020002000200020002000200020002000200020002777f0002000861658002000
00200086565800200077788000200020002000200020002000200020002000200020002000200020002000200020002000200028877700200020865658200020
20002086555820008887778020002000200020002000200020002000200020002000200020002000200020002000200020002008777888002000865558002000
002000865558802089a7aa8000200020002000200020002000200020002000200020002000200020002000200020002000200028aa7a98200020865558800020
80808086565d8080889965808080808080808080808080808080808080808080808080808080808080808080808080808080808856998880808086565d808080
08080886555d8808086665880808080808080808080808080808080808080808080808080808080808080808080898080808080856668808080886555d880808
808088d5565d80808861658080808080808080808080808080808080808080808080808080808080808080808080808080808088561688808088d5565d808080
080808d6666d88088d656588080808080808080808080808080808080808080808080808080808080808080808080808080808885656d8080808d6666d880808
808088d666dd88888dd66dd88080808080808080808080808088808080808080808080808080808080808080808080808080808dd66dd8808088d666dd888080
0808822d2dd2280822dd22280808080808080808080808080808080808080808080808080808080808080808080808080808088222dd228808822d2dd2280808

__sfx__
00020000286402864023640156300663000620006003b6003a6003a6003d6003d6002160021600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00010000020500605011050270501d0503b050330501e050170501705025050370501c050230500f0600f05012060180601b060100502d0503f04027010080000b0000e00015000340003a000000000000000000
000200002815027150251501f150131500d1500e1500f1501115012150111500b150061500315004150081500a1500b1500615003150001500115000100001000010000100001000010000100001000010000100
000200001a05019050170501505013040100400d0400a030090300703006020050200301002010010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a640286402764024640226401e6401b6401864014640106300e6300c6300b62009620086200662005620046200361002610016100061000600056000360003600026000260002600016000160001600
000100002563031630366302b62020610166100a6100261000600006000e6000c6000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
00040000260203b03027050320602e060180601e0503b030250102c030290501706014070110700e0400b03009030070200501003010020000000000000010000000000000000000600003000060000300002000
000200000762009620216201563009630086200562003610016100061004600036000160000600036000160000600006000060000600006000060000600006000060000600006000060000600006000060000600
00020000000002d0502d050290501d050130502c0501e05016050150503405036050390503b050380003a0003b0003e0000e000100001400018000230002d0003c00000000000000000000000000000000000000
0003000007020070200703026030230500b0500d06012060170702d070210701d060240503c0502c040310603e060320403c0303f0102d0602d0603b0603c040270502703029050320502d0502b0503e0003d000
00050000056400b6600a64007640066400e640096400a6300d6500b6501e6701a650106300763005620026100061000600006000b600046000360000600006000060000600006000060000600006000060000600
00020000276301d63015630116300d6300b6300963009630086200a62009620076100561006610056100261000610006100460003600026000160001600006000060000600006000060000600006000060000600
00030000167501575016750007001c750007002375000700377503f750007003f7503f7503f750007003f7003f7003f7000070000700007000070000700007000070000700007000070000700007000070000700
00010000377403776036740357103471032740307702e7402c7202976027770227701f7501c7301874015740127300f7200c74008740057200272000710000000000000000000000000000000000000000000000
