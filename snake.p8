pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- main.


----------------------
-- draw.
----------------------
function _draw()
	cls(1)
	
	-- debug.
	--print("state:"..game_state, 4, 115, 7)
	print(timer.last,4,115,7)

	if game_state == "main_menu" then
		draw_main_menu()
	else
		draw_grid()
		draw_snake()
		draw_fruit()
		draw_score()
		draw_game_over()
		draw_ptcs()
		draw_txts_displays()
	end
end


----------------------
-- init.
----------------------
function _init()
	timer = {
		elapsed = 0,
		last=time() }
		
	init_keys()
	init_main_menu_droplets()
	init_snake()
	spawn_fruit()
end


----------------------
-- update.
----------------------
function _update()
	update_timer()
	update_keys()
	
	if game_state == "main_menu" then
		if (key_down(5)) replay()
	elseif game_state == "play" then
		update_snake()
	elseif game_state == "game_over_anim" then
	 update_snake_death_anim()
	elseif game_state == "game_over" then
	 update_game_over()
	end
	
	update_shake()
	update_ptcs()
	update_pulse()
	update_txts_displays()
end
-->8
-- variables.

----------------------
-- general.
----------------------

game_state = "main_menu"


----------------------
-- inputs.
----------------------

keys = {}


----------------------
-- grid.
----------------------

grid_w, grid_h = 23, 20
border_col = 13
border_blink_seq = { 13,4,8,4 }
border_blink_index = 1
border_blink_timer = 0


----------------------
-- fruit.
----------------------

fruit_x, fruit_y = -99, -99
fruit_pause = 0.11


----------------------
-- snake.
----------------------

step_timer = 0 

death_anim_step_dur = 6
death_anim_step_timer = 0
death_anim_accel = 0.05
death_anim_min_step_dur = 1

prev_tail_last_pos = {
 x = -1,
 y = -1 }
 
tail_pulse_indexes = {}


----------------------
-- gui.
----------------------

dur_b4_gameover_draw = 36
b4_gameover_draw_timer = 0

play_msg_blink_seq = { 7,15,5,2,5,15 }
play_msg_step_dur = 2
play_msg_index = 1
play_msg_timer = 0

main_menu_droplets = {}


----------------------
-- feedback.
----------------------

cur_trauma = 0
ptcs = {}

txts_displays = {}

pulse_x, pulse_y = 0, 0
pulse_min, pulse_max = 99
pulse_col = 7
pulse_speed = 1
-->8
-- punctual functions.


----------------------
-- general.
----------------------

function replay()
	spawn_fruit(false)
	init_snake()
	game_state = "play"
	set_shake(0)
end


----------------------
-- inputs.
----------------------

function key_down(k)
	return keys[k] & 2 == 2
end

--function key_held(k)
	--return band(keys[k], 1) == 1
--end
--function key_up(k)
	--return band(keys[k], 4) == 4
--end


----------------------
-- fruit.
----------------------

function eat_fruit()
 add_fruit_eat_ptcs()
 pulse_grid(fruit_x, fruit_y, 7, 3)
	add_txt_display("+1",
		fruit_x * 5, 
		fruit_y * 5,
		fruit_x * 5 + snk_dir_x * 15,
		fruit_y * 5 + snk_dir_y * 15, 
		{ 7, 7, 10, 5, 2 }, 12)
	
	spawn_fruit(true)
	sfx(0)
end

function spawn_fruit(with_ptcs)
	local found_pos = false
	while not found_pos do
	
		fruit_x = flr(rnd(grid_w)) + 1
		fruit_y = flr(rnd(grid_h)) + 1
		found_pos = true
		
		for t = 1,#tail do
			if (fruit_x == tail[t].x
			and fruit_y == tail[t].y)
			or (fruit_x == snk_x
			and fruit_y == snk_y)
			then
				found_pos = false
				break
			end
		end
	end
	
	if with_ptcs then
		add_txt_display("♥",
			fruit_x * 5, fruit_y * 5,
			fruit_x * 5, fruit_y * 5 - 10, 
			{ 7, 7, 8, 1 }, 18)

		add_fruit_spawn_ptcs()
	end
end


----------------------
-- snake.
----------------------

function kill_snake()
	game_state = "game_over_anim"
	tail_pulse_indexes = {}
	fruit_x, fruit_y = -99, -99
	
	-- set sprite for death anim.
	if (snk_dir_x == 1) snk_spr = 4
	if (snk_dir_x == -1) snk_spr = 3
	if (snk_dir_y == 1) snk_spr = 5
	if (snk_dir_y == -1) snk_spr = 2
	
	add_shake(0.1)
	sfx(4)
	death_anim_step_timer = 0
	b4_gameover_draw_timer = 0
	pulse_min, pulse_max = 99, 99
end

--function rewind_tail()
	--for t = 1,#tail-1 do
		--tail[t] = {
			--x=tail[t+1].x,
			--y=tail[t+1].y}
	--end
--end


----------------------
-- feedback.
----------------------

function add_fruit_eat_ptcs()
 for p = 0,7 do
 	local alpha=rnd()
 	add_ptc(
 		fruit_x * 5 + 5, fruit_y * 5 + 5,
 		sin(alpha) * 2 + rnd(),
 		cos(alpha) * 2 + rnd(),
 		0, 9, { 7, 12, 6, 7 })
 end
end

function add_fruit_spawn_ptcs()
 for p = 0,15 + rnd(10) do
 	local alpha=rnd()
 	add_ptc(
 		fruit_x * 5 + 5, fruit_y * 5 + 5,
 		sin(alpha) * (4 + rnd(2)),
 		cos(alpha) * (4 + rnd(2)),
 		0, 6, { 7 })
 end
end

function add_ptc(x, y, dir_x, dir_y, t, max_age, col_seq)
	local ptc = {
		x = x, y = y,
		dir_x = dir_x, dir_y = dir_y,
		t = t,
		age = 0,
		max_age = max_age,
		col_seq = col_seq }
	
	add(ptcs, ptc)
end

function add_shake(trauma)
	cur_trauma = mid(0, cur_trauma + trauma, 1)
end

function add_snk_death_ptc(x, y)
 for p = 0,10 do
 	local alpha=rnd()
 	add_ptc(x * 5 + 5, y * 5 + 5,
 		sin(alpha) * 2, cos(alpha) * 2,
 		0, 9, { 8, 9, 10, 15, 7 })
 end
end

function add_snk_self_bite_ptcs()
 for p = 0,15 + rnd(10) do
 
 	-- blood particles direction.
 	local alpha=0
 	if (snk_dir_x == -1) alpha = 180
 	if (snk_dir_y == 1) alpha = 270
 	if (snk_dir_y == -1) alpha = 90
 
 	local rnd_vector = rnd_vector_in_cone(alpha,135)

 	add_ptc(snk_x * 5 + 3, snk_y * 5 + 3,
 		rnd_vector.x * (3 + rnd(2)),
 		rnd_vector.y * (3 + rnd(2)),
 		0, 6, { 8, 2 })
 end
 
 add_txt_display("!!!",
		snk_x * 5 - 2, 
		snk_y * 5,
		snk_x * 5 - 2 + snk_dir_x * 10,
		snk_y * 5 + snk_dir_y * 10,
		{ 7, 7, 8, 1 },
		12)
 
end

function add_txt_display(txt, x, y, dx, dy, col_seq, max_age)
 add(txts_displays,
 	{ txt = txt,
	 x = x, y = y,
	 dx = dx, dy = dy,
	 col_seq = col_seq,
	 timer = 0,
	 max_age = max_age })
end

function fade_pal(perc)
	local p = flr(mid(0, perc, 1) * 100)
	local kmax, col, dpal, j, k
	
	dpal = { 
	 0, 1, 1, 2,
	 1, 13, 6, 4,
	 4, 9, 3, 16,
	 1, 13, 14 }
	 
	for j = 1,15 do
		col = j
		kmax = (p + (j * 1.46)) /  22
		
		for k = 1,kmax do
			col = dpal[col]
		end
		
		pal(j, col)
	end
end

function pulse_grid(x, y, col, speed)
	pulse_x, pulse_y = x, y
	pulse_min, pulse_max = 0, 0
	pulse_col = col
	pulse_speed = speed
end

function set_shake(trauma)
	cur_trauma = mid(0, trauma, 1)
end


----------------------
-- utilities.
----------------------

function rnd_vector_in_cone(angle, wideness)
	rnd_dir = 
		rnd(wideness / 720)
		- rnd(wideness / 720)
		+ (angle / 360)

	return {
		x = cos(rnd_dir),
		y = sin(rnd_dir) }
end
-->8
-- init functions.


----------------------
-- inputs.
----------------------

function init_keys()
	for k = 0,5 do
		keys[k] = 0
	end
end


----------------------
-- snake.
----------------------

function init_snake()
	snk_x, snk_y = 11, 10
	snk_dir_x,	snk_dir_y = 1, 0

	snk_last_dir_x, snk_last_dir_y
		= snk_dir_x, snk_dir_y

	snk_spr = 4
	step_dur = 0.13 --0.2
	step_min = 0.05
	step_accel = 0.001
	
	score = 0
	
	tail = {}
end


----------------------
-- gui.
----------------------

function init_main_menu_droplets()
	local possible_cols = { 1, 1, 2, 13 }
	local possible_sizes = { 1, 0.5, 0.5 }

	for d = 1,150 do
	 add(main_menu_droplets, {
	 	x = rnd(127),
	 	y = rnd(127),
	 	dy = 1 + rnd(1.5),
	 	col = possible_cols[flr(rnd(#possible_cols) + 1)],
	 	size = possible_sizes[flr(rnd(#possible_sizes) + 1)] })
	end
end
-->8
-- update functions.


----------------------
-- general.
----------------------

function update_game_over()
	if key_down(5) then
		replay()
	elseif key_down(4) then
		game_state="main_menu"
	end
end

function update_timer()
 timer.elapsed = (time() - timer.last)
 timer.last = time()
end


----------------------
-- input.
----------------------

function update_keys()
		local key
  for k = 0,5 do
  
  	key = keys[k]

		 if key == 0 then
		  if (btn(k)) keys[k] = 3
		 elseif key == 1 then
		  if (not btn(k)) keys[k] = 4
		 elseif key == 3 then
		  if btn(k) then
		  	keys[k] = 1
		  else
		  	keys[k] = 4
		  end
		 elseif key == 4 then
		  if btn(k) then
		  	keys[k] = 3
		  else
		  	keys[k] = 0
		  end
		 end
  end
end


----------------------
-- grid.
----------------------

function update_border_blink()
	if game_state != "play"
	or (snk_x > 1
	and snk_x < grid_w
	and snk_y > 1
	and snk_y < grid_h)
	then
		border_blink_timer = 0
		border_col = 13
	else
		border_blink_timer += 1
		if border_blink_timer > 2 then
			border_blink_index += 1
			if border_blink_index > #border_blink_seq then
				border_blink_index = 1
			end
			border_blink_timer = 0
		end
		border_col = border_blink_seq[border_blink_index]
	end
end


----------------------
-- snake.
----------------------

function update_snake()
	if snk_last_dir_y != 0 then
		if key_down(0) then
			snk_dir_x, snk_dir_y = -1, 0
		elseif key_down(1) then
			snk_dir_x, snk_dir_y = 1, 0
		end
	elseif snk_last_dir_x != 0 then
		if key_down(2) then
			snk_dir_x, snk_dir_y = 0, -1
		elseif key_down(3) then
			snk_dir_x, snk_dir_y = 0, 1
		end
	end
	
	step_timer += timer.elapsed
	if step_timer > step_dur then

		update_tail()

		if snk_dir_x != snk_last_dir_x
			or snk_dir_y != snk_last_dir_y then
			sfx(1)
		end

		snk_x += snk_dir_x
		snk_y += snk_dir_y
		snk_last_dir_x, snk_last_dir_y
		 = snk_dir_x, snk_dir_y
		
		if snk_x < 1
		or snk_y < 1
		or snk_x > grid_w
		or snk_y > grid_h 
		then
			snk_x -= snk_dir_x
			snk_y -= snk_dir_y
			--rewind_tail()
			kill_snake()
			do return end
		end
		
		-- check fruit.
		local fruit_eaten = false
		if snk_x == fruit_x
		and snk_y == fruit_y
		then
			eat_fruit()
			add(tail, { x = snk_x, y = snk_y })
			fruit_eaten = true
		end
		
		-- check tail.
		for t = 1,#tail-1 do
			if (snk_x == tail[t].x and snk_y == tail[t].y)
			or (snk_x == prev_tail_last_pos.x and snk_y == prev_tail_last_pos.y)
			then
				kill_snake()
				add_shake(0.1)
				add_snk_self_bite_ptcs()
				do return end
			end
		end
		
		-- eat fruit.
		if fruit_eaten then
			score+=1
			
			step_dur -= step_accel
			if step_dur < step_min then
			 step_dur = step_min
			end
			
			add_shake(0.054)
			-- modify first -1 in array
			-- instead of adding a pulse
			-- each time.
			add(tail_pulse_indexes, 0)
			
			step_timer =- fruit_pause
		else
			step_timer = 0
		end
		
		-- set sprite for next move.
		if (snk_dir_x == 1) snk_spr = 4
		if (snk_dir_x == -1) snk_spr = 3
		if (snk_dir_y == 1) snk_spr = 5
		if (snk_dir_y == -1) snk_spr = 2		
	end

	-- update tail pulses.
	for p = 1,#tail_pulse_indexes do
		if (tail_pulse_indexes[p] > -1) then
			tail_pulse_indexes[p] += ceil(#tail / 12)
			if tail_pulse_indexes[p] > #tail then
			 tail_pulse_indexes[p] = -1
			end
		end
	end
end

function update_snake_death_anim()
	
	death_anim_step_timer += 1
	death_anim_step_dur -= death_anim_accel
	
	if death_anim_step_dur < death_anim_min_step_dur then
	 death_anim_step_dur = death_anim_min_step_dur
	end
	
	if death_anim_step_timer > death_anim_step_dur then
	 if #tail > 0 then
	 	add_snk_death_ptc(tail[#tail].x, tail[#tail].y)
		 pulse_grid(tail[#tail].x, tail[#tail].y, 10, 5)
		 
		 del(tail, tail[#tail])
		 death_anim_step_timer = 0
		 set_shake(0.075)

		 sfx(2)
	 else
	 	-- remove head + game over.
	 	game_state = "game_over"
	 	
	 	set_shake(0.15)
	 	pulse_grid(snk_x, snk_y, 8, 2)
	 	sfx(3)
	 end
	end
end

function update_tail()
	-- workaround to avoid snake
	-- not being able to bite last
	-- part of his tail.
	if #tail>1 then
		prev_tail_last_pos.x = tail[#tail-1].x
		prev_tail_last_pos.y = tail[#tail-1].y
	end

	for t = #tail,2,-1 do
		tail[t] = {
			x=tail[t-1].x,
			y=tail[t-1].y}
	end

	if #tail > 0 then
		tail[1] = { x=snk_x,y=snk_y }
	end
end


----------------------
-- feedback.
----------------------

function update_ptcs()
	local ptc
	for p = #ptcs,1,-1 do
	 ptc = ptcs[p]
	 ptc.age += 1
	 if ptc.age > ptc.max_age then
	  del(ptcs, ptcs[p])
	 else
	 	-- update particle color.
	 	ptc.col = ptc.col_seq[
	 		1 + flr((ptc.age / ptc.max_age) * #ptc.col_seq)]
	 	
	 	-- move particles.
	 	ptc.x += ptc.dir_x
	 	ptc.y += ptc.dir_y
	 end
	end
end

function update_pulse()
	if pulse_min < 99 then
		pulse_max += pulse_speed
		pulse_min = pulse_max - 2
	end
end

function update_shake()
	local shake_x = (8 - rnd(16)) * cur_trauma
	local shake_y = (8 - rnd(16)) * cur_trauma
	
	camera(shake_x, shake_y)
	
	cur_trauma *= 0.95
	if cur_trauma < 0.05 then
	 cur_trauma = 0
	end
end

function update_txts_displays()
	for t in all(txts_displays) do
		t.x += (t.dx - t.x) / 5
		t.y += (t.dy - t.y) / 5
		t.timer += 1
		if t.timer > t.max_age then
			del(txts_displays, t)
		end
	end
end
-->8
-- draw functions.


----------------------
-- fruit.
----------------------

function draw_fruit()
	local offset = 0
	--if fruit_offset_timer > 6 then
	if timer.last*4 % 2 < 1 then
		offset = 1
	end
	
	spr(18, fruit_x*5, fruit_y*5 - offset)
end


----------------------
-- grid.
----------------------

function draw_grid()
	update_border_blink()

	local grid_rect_bx = grid_w * 5 + 7
	local grid_rect_by = grid_h * 5 + 7

	-- 107 = grid_h * 5 + 7
	rectfill(4, 4, grid_rect_bx, grid_rect_by, 0)
	rect(4, 4, grid_rect_bx, grid_rect_by, border_col)

	for x = 1,grid_w do
		for y = 1,grid_h do
			local col = 5
			
			if pulse_min < 99 then
				local pulse_dist =
					sqrt((x-pulse_x) * (x-pulse_x)
						+ (y-pulse_y) * (y-pulse_y))
					
				if pulse_dist < pulse_max
				and pulse_dist > pulse_min then
					col=pulse_col
				end
			end
			
			-- snake halo.
			if (game_state == "play" or game_state == "game_over_anim")
			and pulse_min > 4 then
				if sqrt((x-snk_x) * (x-snk_x) + (y-snk_y) * (y-snk_y)) < 4 then
					col=4
				end
			end
			
			-- fruit halo.
			if game_state == "play" and pulse_min > 4 then
				if sqrt((x-fruit_x) * (x-fruit_x) + (y-fruit_y) * (y-fruit_y)) < 3 then
					col=14
				end
			end
				
			pset(x * 5 + 3, y * 5 + 3, col)
		end
	end
end


----------------------
-- snake.
----------------------

function draw_snake()
	-- tail.
	for t=1,#tail do
		local spr_index = 1
		for pulse in all(tail_pulse_indexes) do
			if t == pulse then
			 spr_index = 17
			end
		end
		
		spr(spr_index,
			tail[t].x*5+1,
			tail[t].y*5+1)
		
	end
	
	-- head.
	if game_state == "play" then
		spr(snk_spr, snk_x*5+1, snk_y*5+1)
	elseif game_state == "game_over_anim" then
		spr(snk_spr, snk_x*5+1, snk_y*5+1)
	end
end


----------------------
-- gui.
----------------------

function draw_game_over()
	if game_state == "game_over" then
		b4_gameover_draw_timer += 1
		if b4_gameover_draw_timer > dur_b4_gameover_draw then
			rectfill(10, 45, 117, 67, 1)
			rect(10, 45, 117, 67, 8)
			print("game over! score:"..score, 30, 48, 7)
			print("❎ play again", 30, 54, 7)
			print("🅾️ back to menu", 30, 60, 7)
		end
	end
end

function draw_main_menu()
	play_msg_timer += 1
	if play_msg_timer > play_msg_step_dur then
		play_msg_index += 1
		if play_msg_index > #play_msg_blink_seq then
			play_msg_index = 1
		end
		play_msg_timer = 0
	end

	local play_msg_col = play_msg_blink_seq[play_msg_index]
	
	rectfill(0, 0, 127, 127, 0)

	-- droplets.
	for d = 1,#main_menu_droplets do
		main_menu_droplets[d].y += main_menu_droplets[d].dy
		if main_menu_droplets[d].y > 127 then
			main_menu_droplets[d].x = rnd(127)
			main_menu_droplets[d].y = 0
			main_menu_droplets[d].dy = 1 + rnd(1.5)
		end
		
		circfill(
			main_menu_droplets[d].x,
			main_menu_droplets[d].y,
			main_menu_droplets[d].size,
			main_menu_droplets[d].col)
	end

	rectfill(18, 20, 109, 92, 0)
	rect(20, 22, 107, 90, 1)
	--rect(22, 24, 105, 88, 2)
	
	spr(80, 30, 30, 9, 3)	-- logo.
	
	print("by robin six.", 32, 54, 1)
	print("sixrobin.itch.io", 32, 60, 1)
	
	print("press ❎ to play", 32, 77, play_msg_col)
end

function draw_score()
	if game_state == "play" then
		print("score:"..score, 90, 115, 7)
	end
end


----------------------
-- feedback.
----------------------

function draw_txts_displays()
	for t in all(txts_displays) do
		local col = t.col_seq[
	 	1 + flr((t.timer / t.max_age) * #t.col_seq)]
		print(t.txt, t.x, t.y, col)
	end
end

function draw_ptcs()
	for p = 1,#ptcs do
		local ptc = ptcs[p]
		if ptc.t == 0 then
			-- pixel particles.
			pset(ptc.x, ptc.y, ptc.col)
		end
	end
end
-->8
-- todo

-- align texts according to score.
-- add state machine methods?

-- fadings & transitions.
-- particles using sprites.
-- feedback when menu nav input.

-- ? snake accel is strange.
__gfx__
00000000099900000999000009984000489900004888400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000979980009191900091998000899190009999900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700999980008999800099998000899990008999800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000488840009999900091998000899190009191900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000044400004888400009984000489900000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077700000033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777a0000003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777a00008888e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077779000088877e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aa900000888878000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000288888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999000000099900000009990000000999000000099900000000000000000000000000000000000000000000000000000000000000000000000000000
00099909799809990979980999097998099909799809990979980999048990000000000000000000000000000000000000000000000000000000000000000000
00979989999897998999989799899998979989999897998999989799887919008000000000000000000000000000000000000000000000000000000000000000
00999984888499998488849999848884999984888499998488849999889999880000000000000000000000000000000000000000000000000000000000000000
00488841444148884144414888414441488841444148884144414888489919118000000000000000000000000000000000000000000000000000000000000000
00144411111114441111111444111111144411111114441111111444148991121000000000000000000000000000000000000000000000000000000000000000
00111122222221112222222111222222211122222221112222222111111111222000000000000000000000000000000000000000000000000000000000000000
00777777777771177772777712213312222177772777772222772227717717777000000000000000000000000000000000000000000000000000000000000000
007dddd77ddd717ddd777dd772211311222778882778772227777227717727788000000000000000000000000000000000000000000000000000000000000000
0072772777272722777727727218888e122aa2222aa2aa222a88a22aa7a82aa22000000000000000000000000000000000000000000000000000000000000000
00788887178717871117877871188877e128aa222aa28aa2aa22aa2aaa822aaa2000000000000000000000000000000000000000000000000000000000000000
0078777717871787111787787118888781118aa11aa11aa1aaaaaa1aaa111aa81000000000000000000000000000000000000000000000000000000000000000
007e711177e777ee7777e77e71128888811119991991199199889919989119911000000000000000000000000000000000000000000000000000000000000000
007e71117eee717eee777ee771112222111aaaa81aa11aa1aa11aa1aa1aa1aaaa000000000000000000000000000000000000000000000000000000000000000
00777111777771177771777711111111111888811881188188118818818818888000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111111111111111111111111111111111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2c2000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666666666666666666666666666666666666666666666666666666666666666000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002575025750257502475022750207501e7501c7501875014750127400e7400b73006720017100070009700087000670000700037000270001700007000070000700007000070000700007000070000700
000100000472008700087000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f64006640056300463014630036200162000610066100562001610036000260000600006000560002600006000d6000c6000a6000860006600056000460002600006000060000600006000060000600
000500001c0401c0401b0401b0401a040180401704016030150301303012030100300d0300a030080300703005030040300303002030010300003000030000300003000010000100001000000000000000000000
000300000934009340073300432001310003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
__music__
00 01424344

