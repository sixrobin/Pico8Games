pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- main.

lvl=1
frame=0

game_state="playing"

function _draw()
	cls(1)
	update_shake()
	if game_state=="playing" then
		draw_grid()
		draw_grid_content()
		draw_selected_dir()
		draw_gui()
	elseif game_state=="game_over" then
		draw_grid()
		draw_game_over_gui()
	end
end

function _init()
	init_keys()
	init_lvl()
end

function _update()
	frame+=1
	update_keys()
	
	if game_state=="playing" then
		update_player()
	elseif game_state=="game_over" then
		-- replay button.
	end
end

function game_over()
	cls(1)
	game_state="game_over"
	add_shake(0.2)
end

function init_lvl()
	init_grid()
	init_player()
	init_enemies()
	cls(1)
end

function next_lvl()
	lvl+=1
	bombs+=1
	tps+=1
	init_lvl()
	
	animate_lvlup_col=true
	sfx(4)
end
-->8
-- enemies.

enemies={}

e_init=8
e_incr=4

function draw_enemy(x,y)
	spr(2,x*cell_size,y*cell_size)
end

function draw_obstacle(x,y)
	spr(3,x*cell_size,y*cell_size)
end

function init_enemies()
	for e=1,e_init+e_incr*(lvl-1) do
		local e_x=flr(rnd(grid_w))+1
		local e_y=flr(rnd(grid_h))+1
		
		while grid[e_x][e_y]!=0 do
			e_x=flr(rnd(grid_w))+1
			e_y=flr(rnd(grid_h))+1
		end	
		
		grid[e_x][e_y]=2
		enemies[e]={x=e_x,y=e_y}
	end
end

function move_enemies()
	-- move enemies to player.
	for e in all(enemies)	do
		grid[e.x][e.y]-=2
		if (e.x<p_x) e.x+=1
		if (e.x>p_x) e.x-=1
		if (e.y<p_y) e.y+=1
		if (e.y>p_y) e.y-=1
		grid[e.x][e.y]+=2
	end
	
	-- check enemies collisions.
	local any_killed=false
	
	for e in all(enemies)	do
	 if grid[e.x][e.y]>=4 then
	 	del(enemies,e)
			any_killed=true
	 end
	end
	
	if #enemies==0 then
		next_lvl()
	elseif any_killed then
		sfx(1)
		add_shake(0.1)
	end
end
-->8
-- input management.

keys={};

function init_keys()
	for k=0,5 do
		keys[k]=0;
	end
end

function key_held(k)
	return band(keys[k],1)==1
end

function key_down(k)
	return band(keys[k],2)==2
end

function key_up(k)
	return band(keys[k],4)==4
end

function update_key(k)
 if keys[k]==0 then
  if btn(k) then
  	keys[k]=3
  end
 elseif keys[k]==1 then
  if not btn(k) then
  	keys[k]=4
  end
 elseif keys[k]==3 then
  if btn(k) then
  	keys[k]=1
  else
  	keys[k]=4
  end
 elseif keys[k]==4 then
  if btn(k) then
  	keys[k]=3
  else
  	keys[k]=0
  end
 end
end

function update_keys()
  for k=0,5 do 
  	update_key(k)
  end
end
-->8
-- grid.

grid={}

cell_size=6
grid_col=1
cell_col=2
grid_w=19
grid_h=17
grid_global_offset=6

function draw_grid()
	rect(
		cell_size-1,
		cell_size-1,
		(grid_w+1)*cell_size+1,
		(grid_h+1)*cell_size+1,
		8)

	rectfill(
		cell_size,
		cell_size,
		(grid_w+1)*cell_size,
		(grid_h+1)*cell_size,
		cell_col)

	for x=0,grid_w-1 do
		for y=0,grid_h-1 do
			rect(
				x*cell_size+grid_global_offset,
				y*cell_size+grid_global_offset,
				x*cell_size+cell_size+grid_global_offset,
				y*cell_size+cell_size+grid_global_offset,
				grid_col)
		end
	end
end

function draw_grid_content()
	for x=1,grid_w do
		for y=1,grid_h do
		 local unit=grid[x][y]
		 if (unit==1) draw_player()
			if (unit==2) draw_enemy(x,y)
			if (unit>=4) draw_obstacle(x,y)
		end
	end
end

function init_grid()
	for x=1,grid_w do
		grid[x]={}
		for y=1,grid_h do
			grid[x][y]=0
		end
	end
end
-->8
-- player.

p_init_x=10
p_init_y=9
p_x=0
p_y=0

dir_x=0
dir_y=0
dir_helper_blink_timer=0
dir_helper_blink_dur=12

bombs=1
tps=1

cur_mode="movement"
cur_action="bomb"

function check_player_pos()
	if grid[p_x][p_y]>=2 then
		game_over()
	end
end

function draw_player()
	spr(1,p_x*cell_size,p_y*cell_size)
end

function draw_selected_dir()
 if cur_mode=="movement" then
		-- selected direction cell.
		spr(4,
			(p_x+dir_x)*cell_size,
			(p_y+dir_y)*cell_size)
	
		dir_helper_blink_timer+=1
			if dir_helper_blink_timer
				>dir_helper_blink_dur then
				
			-- possible directions.
			for x=-1,1 do
				for y=-1,1 do
					-- check out of bounds.
					if p_x+x<1 or p_x+x>grid_w
						or p_y+y<1 or p_y+y>grid_h then
						spr(5,
							(p_x+x)*cell_size,
							(p_y+y)*cell_size)
					elseif grid[p_x+x][p_y+y]<=1 then
						spr(5,
							(p_x+x)*cell_size,
							(p_y+y)*cell_size)
					end
				end
			end
		
			if dir_helper_blink_timer>
				2*dir_helper_blink_dur then
				dir_helper_blink_timer=0
			end
		end
	end
end

function init_player()
	p_x=p_init_x
	p_y=p_init_y
	dir_x=0
	dir_y=0
	grid[p_x][p_y]=1
	cur_mode="movement"
end

function move_player()
	if key_down(5) then
		local prev_x=p_x
		local prev_y=p_y
		
		p_x+=dir_x
		p_y+=dir_y
		
	 if (p_x<1) p_x=1
		if (p_x>grid_w) p_x=grid_w
		if (p_y<1) p_y=1
		if (p_y>grid_h) p_y=grid_h
		
		if prev_x!=p_x or prev_y!=p_y then
			-- pickup things.
			grid[prev_x][prev_y]-=1
			grid[p_x][p_y]+=1
		end
		
		sfx(0)
		return true
	end
end

function update_player()
	if cur_mode=="movement" then
		-- update direction.
		if (key_down(0)) dir_x-=1
		if (key_down(1)) dir_x+=1
		if (key_down(2)) dir_y-=1
		if (key_down(3)) dir_y+=1
		
		if (dir_x<-1) dir_x=-1
		if (dir_x>1) dir_x=1
		if (dir_y<-1) dir_y=-1
		if (dir_y>1) dir_y=1
	
		if move_player() then
			move_enemies()
			check_player_pos()
		end
		
	elseif cur_mode=="action" then
		if key_down(0) or key_down(1) then
			if cur_action=="bomb" then
				cur_action="tp"
			else
				cur_action="bomb"
			end
		end
		
		if key_down(5) then
			if cur_action=="bomb" then
			 if (bomb())move_enemies()
			end
			if cur_action=="tp" then
			 if (tp())move_enemies()
			end
		end
	end
	
		update_player_mode()
end

function update_player_mode()
 if key_down(4) then
 	if cur_mode=="movement" then
 		cur_mode="action"
 		cur_action="bomb"
 	elseif cur_mode=="action" then
 		cur_mode="movement"
 		dir_helper_blink_timer=0
 	end
 end
end

-- action: bomb.
function bomb()
	if bombs>0 then
		for e in all(enemies) do
			if abs(e.x-p_x)<2 and abs(e.y-p_y)<2 then
				grid[e.x][e.y]=4
				del(enemies,e)
			end
		end
		
		bombs-=1
		add_shake(0.2)
		sfx(2)
		return true
	end
end

-- action: tp.
function tp()
	if tps>0 then
		local tp_x=flr(rnd(grid_w))+1
		local tp_y=flr(rnd(grid_h))+1
		
		-- still possible to tp on
		-- a free cell and then get
		-- overlapped.
		while grid[tp_x][tp_y]!=0 do
			tp_x=flr(rnd(grid_w))+1
			tp_y=flr(rnd(grid_h))+1
		end	
		
		grid[p_x][p_y]-=1
		p_x=tp_x
		p_y=tp_y
		grid[p_x][p_y]+=1
		
		tps-=1
		add_shake(0.1)
		sfx(3)
		return true
	end
end
-->8
-- gui.

gui_bg_col=0
gui_txt_col=7
gui_txt_off_col=13
gui_stroke_col=12

lvlup_col=7
animate_lvlup_col=false

selected_blink_timer=0
selected_blink_dur=6

function draw_game_over_gui()
	local rect_h=
		grid_h*cell_size
		+grid_global_offset
		+cell_size
		
	rectfill(0,rect_h,127,127,gui_bg_col)
	rect(0,rect_h,127,127,gui_stroke_col)
		
	print(
		"game over!",
			46,
			rect_h+5,
			gui_txt_col)
end

function draw_gui()
	local rect_h=
		grid_h*cell_size
		+grid_global_offset
		+cell_size
	
	rectfill(0,rect_h,127,127,gui_bg_col)
	rect(0,rect_h,127,127,gui_stroke_col)
	
	-- display current level
	if animate_lvlup_col then
		lvlup_col+=1
		if lvlup_col-32==7 then
			lvlup_col=7
			animate_lvlup_col=false
		end
	end
	
	print("lvl:"..lvl,6,rect_h+5,lvlup_col)
	
	if cur_mode=="movement" then
		print("🅾️bombs:"..bombs,
			35,rect_h+5,gui_txt_col)	
		print("❎tps:"..tps,
			 80,rect_h+5,gui_txt_col)
	else
		selected_blink_timer+=1
		selected_char="◆"
		if selected_blink_timer>selected_blink_dur
		or (cur_action=="bomb" and bombs==0)
		or (cur_action=="tp" and tps==0)
		then
			selected_char="…"
		end			
	
		local bomb_col=gui_txt_col
		local tp_col=gui_txt_col
		if (bombs==0) bomb_col=gui_txt_off_col
		if (tps==0) tp_col=gui_txt_off_col
		
		if cur_action=="bomb" then
			print(selected_char.."bombs"..selected_char,
				35,rect_h+5,bomb_col)
			print("…tps…",80,rect_h+5,tp_col)
		else
			print("…bombs…",35,rect_h+5,bomb_col)
			print(selected_char.."tps"..selected_char,
				80,rect_h+5,tp_col)
		end
		
		if selected_blink_timer>
			2*selected_blink_dur then
			selected_blink_timer=0
		end
	end
end
-->8
-- feedback.

cur_trauma=0

function add_shake(trauma)
	cur_trauma+=trauma;
	if (cur_trauma>1) then
		cur_trauma=1
	end
end

function update_shake()
	local shake_x=(16-rnd(32))*cur_trauma
	local shake_y=(16-rnd(32))*cur_trauma
	
	camera(shake_x,shake_y)
	
	cur_trauma=cur_trauma*0.95
	if (cur_trauma<0.1) then
		cur_trauma=0
	end
end
__gfx__
00000000000000000000000000000000aa000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaa00000eee00006666600a00000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000a779a000e688e0006161600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000a779a000e888e000166610000000000000a000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000a999a000e888e0000616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000aaa00000eee00006101600a00000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000aa000aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000070400a0300d0201001015000050000500000000010000100000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000a6600a6600e6500e6500c65008650086400764002630006200061001600026000160001600006000060000600006000b600036000160004600046000260001600016000160000600006000060000600
0003000022650236302262020660136501361016620116100a6000c6100b610096100460000600006000460007600086000460001600006000060000600006000060000600006000060000600006000060000600
000100000b0400d0400a05009050090400b0300f02016020220102a01009010090200c0300f040140501d050290503d030050200a010120002000020000260002f000370003a0001f00022000300000000000000
00020000060500a050130501b050240502f05006050090500c050110501a0502d050080500a0500d05012050180502505034050080000c0001200019000220000000001000000000000000000000000100000000
