pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- pumpkin striker.
-- robin six.


------------------------

-- todo.

-- damping on cut speed.
-- cut animation and visual.
-- cut clamps visual.
-- pk x velocity.
-- multiple pk sprites.
-- ? pk rotation.
-- ptcs with sprite.
-- tuto.
-- levels and final score.

------------------------


function _draw()
	cls(0)
	draw_pk_light()
	draw_cut()
	draw_pk()
	draw_ptcs()
	draw_gui()
	draw_txts_displays()
end

function _init()
	spawn_pk()
end

function _update()
	update_cut()
	update_pk()
	update_shake()
	update_ptcs()
	update_txts_displays()
end
-->8
-- variables.

pk_posx,pk_posy=-99,-99
pk_velx,pk_vely=0,3
pk_grav=.5
pk_flip=false

cut_h=30
cut_cd,cut_timer=12,-1

lvl,score,combo=1,0,0

cur_trauma=0
ptcs,txts_displays={},{}
-->8
-- punctual functions.


function try_cut()
	if cut_h>=pk_posy-2
	and cut_h<=pk_posy+18
	then
		-- cut succeeded.
		combo+=1
		score+=combo
		
		add_txt_display("+"..combo,
			pk_posx,pk_posy,
			pk_posx,pk_posy-15,
			{ 7,7,10,8,1 }, 12)
		
		set_shake(0.1)
		add_pk_cut_ptc()
		
		spawn_pk()
	end
end

function spawn_pk()
	pk_posx=20+rnd(80)
	pk_posy=128
	pk_vely=-11+rnd(3)
	pk_flip=rnd()<0.5
end


------------------------
-- feedback.
------------------------

function add_pk_cut_ptc()
 for p=0,15+rnd(10) do
 	local alpha=rnd()
 	add_ptc(
 		pk_posx,
 		pk_posy,
 		sin(alpha)*(2+rnd(2)),
 		cos(alpha)*(2+rnd(2)),
 		0,
 		12,
 		{ 4,9,10 })
 end
end

function add_pk_lost_ptc()
 for p=0,10+rnd(5) do
 	local angle=rnd_vector_in_cone(90,135)
 	add_ptc(
 		pk_posx,
 		pk_posy-2,
 		angle.x*3,
 		angle.y*(2+rnd(3)),
 		0,
 		12,
 		{ 10,9,8,2 })
 end
end

function add_ptc(_x,_y,_dx,_dy,_t,_max_age,_col_seq)
	local ptc={
		x=_x,
		y=_y,
		dx=_dx,
		dy=_dy,
		t=_t,
		age=0,
		max_age=_max_age,
		col_seq=_col_seq }
	
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
-->8
-- draw functions.

------------------------
-- pumpkin.
------------------------

function draw_pk()
	spr_outline(1,7,pk_posx,pk_posy,2,2,pk_flip)
end

function draw_pk_light()
	fillp(░)
	circfill(pk_posx+8,pk_posy+8,20,1)
 circfill(pk_posx+8,pk_posy+8,14,0)
 fillp(▒)
 circfill(pk_posx+8,pk_posy+8,14,1)
	fillp(◆)
	circfill(pk_posx+8,pk_posy+8,10,1)
	fillp(0)
end


------------------------
-- cut.
------------------------

function draw_cut()
	local col=7
	if cut_timer>-1 then
		col=13
	end
	
	rectfill(0,cut_h-2,3,cut_h+2,col)
 rectfill(124,cut_h-2,127,cut_h+2,col)

	if cut_timer==-1 then
		line(0,cut_h,127,cut_h,col)
	else
		for i=0,64 do
			pset(i*3,cut_h,col)
		end
	end
end


------------------------
-- gui.
------------------------

function draw_gui()
	rectfill(-10,-10,135,8,0)
	
	print("level:"..lvl,2,2,7)
	
	local combo_x=52-(#tostr(combo)-1)*4
	print("combo:"..combo,combo_x,2,7)
	
	local score_x=99-(#tostr(score)-1)*4
	print("score:"..score,score_x,2,7)
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
		end
	end
end

function draw_txts_displays()
	for t in all(txts_displays) do
		print(t.txt,t.x,t.y,t.col)
	end
end
-->8
-- init functions.
-->8
-- update functions.

function update_cut()
	if (btn(⬆️)) cut_h-=2
	if (btn(⬇️)) cut_h+=2
	cut_h=mid(8,cut_h,80)
	
	-- cut input.
	if cut_timer==-1 and btn(❎) then
		try_cut()
		cut_timer=0
	end
	
	if cut_timer>-1 then
		cut_timer+=1
		if cut_timer>cut_cd then
			cut_timer=-1
		end
	end
end

function update_pk()
	pk_vely+=pk_grav
	pk_posy+=pk_vely
	
	if (pk_posy>128) then
		-- pumpkin lost.
		add_pk_lost_ptc()
		spawn_pk()
		combo=0
		set_shake(0.06)
		end
end


------------------------
-- feedback.
------------------------

function update_ptcs()
	local ptc
	for p=#ptcs,1,-1 do
	 ptc=ptcs[p]
	 ptc.age+=1
	 if ptc.age>ptc.max_age then
	  del(ptcs,ptcs[p])
	 else
	 	ptc.col=ptc.col_seq[
	 		1+flr((ptc.age/ptc.max_age) * #ptc.col_seq)]
	 	
	 	ptc.x+=ptc.dx
	 	ptc.y+=ptc.dy
	 	ptc.y+=3
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

function update_txts_displays()
	for t in all(txts_displays) do
		t.age+=1
		if t.age>t.max_age then
			del(txts_displays,t)
		else
			t.col=t.col_seq[
	 		1+flr((t.age/t.max_age)*#t.col_seq)]
	 	
	 	t.x+=(t.dx-t.x)/5
			t.y+=(t.dy-t.y)/5
		end
	end
end
-->8
-- tools.


------------------------
-- vector in cone.
------------------------

function rnd_vector_in_cone(_angle,_wideness)
	rnd_dir = 
		rnd(_wideness/720)
		- rnd(_wideness/720)
		+ (_angle/360)

	return {
		x=cos(rnd_dir),
		y=sin(rnd_dir) }
end


------------------------
-- sprite outline.
------------------------

function spr_outline(_n,_col,_x,_y,_w,_h,_flip_x,_flip_y)
  -- set palette to color.
  for c=1,15 do
    pal(c,_col)
  end
  
  -- draw outline.
  for x=-1,1 do
    for y=-1,1 do
      spr(_n,_x+x,_y+y,_w,_h,_flip_x,_flip_y)
    end
  end
  
  pal() -- reset palette.
  
  -- draw actual sprite.
  spr(_n,_x,_y,_w,_h,_flip_x,_flip_y)	
end
__gfx__
00000000000000330000000000000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000333b000000000000333b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000033000000000000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000005553b544000000005553b54400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000554533bb9aa90000554533bb9aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000544495335444a900544495335444a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055499944449aa49955494444449404990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005449944aa4aaaa495449054aa4500a490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000054994499aa4aaa9954940009a40009990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000054994499aa4aa99954940000a400aa990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000054994499994aa9495494500994aaa0a90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555494999a499a495550999999a000490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005445499949994900540000000000a900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000054549499499940005450000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005554499444400000555500005440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000055444440000000005555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
