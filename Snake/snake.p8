pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- main.

game_state = "play"

function _draw()
	cls(1)
	
	-- debug.
	--print("state:"..game_state, 4, 115, 7)
	print(timer.last,4,115,7)

	draw_grid()
	draw_snake()
	draw_fruit()
	draw_score()
	draw_game_over()
	draw_ptcs()
end

function _init()

	timer = {
		elapsed = 0,
		last=time() }
		
	init_keys()
	init_snake()
	spawn_fruit()
end

function _update()
	update_timer()
	update_keys()
	
	if game_state == "play" then
		update_snake()
		update_fruit()
	elseif game_state == "game_over_anim" then
	 update_snake_death_anim()
	elseif game_state == "game_over" then
	 if (key_down(5)) replay()
	end
	
	update_shake()
	update_ptcs()
	update_pulse()
end

function replay()
	spawn_fruit()
	init_snake()
	game_state = "play"
	set_shake(0)
end

function update_timer()
 timer.elapsed = (time() - timer.last)
 timer.last = time()
end


-- ---- todo ----

-- optimize tokens.
-- align texts according to score.
-- wait any input to start.
-- add state machine methods?

-- pop a +1 sign on fruit pickup.
-- fruit visual.
-- fruit spawn better visual.
-- last tail part visual?

-- no fruit particles on init.
-->8
-- inputs.

keys = {}

function init_keys()
	for k = 0,5 do
		keys[k] = 0
	end
end

--function key_held(k)
	--return band(keys[k], 1) == 1
--end

function key_down(k)
	return band(keys[k], 2) == 2
end

--function key_up(k)
	--return band(keys[k], 4) == 4
--end

function update_key(k)
 if keys[k] == 0 then
  if (btn(k)) keys[k] = 3
 elseif keys[k] == 1 then
  if (not btn(k)) keys[k] = 4
 elseif keys[k] == 3 then
  if btn(k) then
  	keys[k] = 1
  else
  	keys[k] = 4
  end
 elseif keys[k] == 4 then
  if btn(k) then
  	keys[k] = 3
  else
  	keys[k] = 0
  end
 end
end

function update_keys()
  for k = 0,5 do 
  	update_key(k)
  end
end
-->8
-- snake.

step_timer = 0 
fruit_pause = 0.11

death_anim_step_dur = 6
death_anim_step_timer = 0
death_anim_accel = 0.05
death_anim_min_step_dur = 1

prev_tail_last_pos = {
 x = -1,
 y = -1 }
 
tail_pulse_indexes = { }

function draw_snake()
	-- tail.
	for t=1,#tail do
		local spr_index = 1
		for pulse in all(tail_pulse_indexes) do
			if t == pulse then
			 spr_index = 17
			end
		end
		spr(spr_index, tail[t].x*5+1, tail[t].y*5+1)
	end
	
	-- head.
	if game_state == "play" then
		spr(snk_spr, snk_x*5+1, snk_y*5+1)
	elseif game_state == "game_over_anim" then
		spr(snk_spr, snk_x*5+1, snk_y*5+1)
	end
end

function init_snake()
	snk_x = 11
	snk_y = 10
	snk_dir_x = 1
	snk_dir_y = 0
	snk_last_dir_x = snk_dir_x
	snk_last_dir_y = snk_dir_y
	snk_spr = 4
	step_dur = 0.13 --0.2
	step_min = 0.05
	step_accel = 0.001
	score = 0
	tail = {}
end

function kill_snake()
	game_state = "game_over_anim"
	remove_fruit()
	
	-- set sprite for death anim.
	if (snk_dir_x == 1) snk_spr = 4
	if (snk_dir_x == -1) snk_spr = 3
	if (snk_dir_y == 1) snk_spr = 5
	if (snk_dir_y == -1) snk_spr = 2
	
	death_anim_step_timer = 0
	add_shake(0.1)
	b4_gameover_draw_timer = 0
end

function rewind_tail()
	for t = 1,#tail-1 do
		tail[t] = {
			x=tail[t+1].x,
			y=tail[t+1].y}
	end
end

function update_snake()
	if key_down(0) and snk_last_dir_y != 0 then
		snk_dir_x = -1
		snk_dir_y = 0
	elseif key_down(1) and snk_last_dir_y != 0 then
		snk_dir_x = 1
		snk_dir_y = 0
	elseif key_down(2) and snk_last_dir_x != 0 then
		snk_dir_x = 0
		snk_dir_y = -1
	elseif key_down(3) and snk_last_dir_x != 0 then
		snk_dir_x = 0
		snk_dir_y = 1
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
		snk_last_dir_x = snk_dir_x
		snk_last_dir_y = snk_dir_y
		
		if snk_x < 1
		or snk_y < 1
		or snk_x > grid_w
		or snk_y > grid_h 
		then
			snk_x -= snk_dir_x
			snk_y -= snk_dir_y
			rewind_tail()
			kill_snake()
			do return end
		end
		
		-- check fruit.
		local fruit_eaten = false
		if snk_x == fruit_x
		and snk_y == fruit_y
		then
			eat_fruit()
			add(tail, { x=snk_x,y=snk_y })
			fruit_eaten = true
		end
		
		-- check tail.
		for t = 1,#tail-1 do
			if (snk_x == tail[t].x and snk_y == tail[t].y)
			or (snk_x == prev_tail_last_pos.x and snk_y == prev_tail_last_pos.y)
			then
				kill_snake()
				add_shake(0.1)
				add_snk_self_bite_ptcs(
					snk_x,
					snk_y,
					snk_dir_x,
					snk_dir_y)
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
-->8
-- grid.

grid_w = 23
grid_h = 20

border_col = 13
border_blink_seq = { 13,4,8,4 }
border_blink_step_dur = 2
border_blink_index = 1
border_blink_timer = 0

function draw_grid()
	update_border_blink()

	-- 122 = grid_w * 5 + 7
	-- 107 = grid_h * 5 + 7
	rectfill(4, 4, 122, 107, 0)
	rect(4, 4, 122, 107, border_col)

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
					col=13
				end
			end
				
			pset(x * 5 + 3, y * 5 + 3, col)
		end
	end
end

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
		if border_blink_timer > border_blink_step_dur then
			border_blink_index += 1
			if border_blink_index > #border_blink_seq then
				border_blink_index = 1
			end
			border_blink_timer = 0
		end
		border_col = border_blink_seq[border_blink_index]
	end
end

function update_pulse()
	if pulse_min < 99 then
		pulse_max += pulse_speed
		pulse_min = pulse_max - 2
	end
end
-->8
-- pickups.

fruit_x = -99
fruit_y = -99

fruit_pulse_speed = 6
fruit_pulse_timer = 0

function draw_fruit()
	local size = 1
	if fruit_pulse_timer > fruit_pulse_speed then
		size = 2
	end

	circfill(
		fruit_x * 5 + 3,
		fruit_y * 5 + 3,
		size,
		7)
end

function eat_fruit()
 add_fruit_eat_ptcs(fruit_x, fruit_y)
 pulse_grid(fruit_x, fruit_y, 6, 3)
	spawn_fruit()
	sfx(0)
end

function remove_fruit()
	fruit_x = -99
	fruit_y = -99
end

function spawn_fruit()
	local found_pos = false
	while not found_pos do
	
		fruit_x = flr(rnd(grid_w)) + 1
		fruit_y = flr(rnd(grid_h)) + 1
		found_pos = true
		
		for t = 1,#tail do
			if fruit_x == tail[t].x
			and fruit_y == tail[t].y then
				found_pos = false
				break
			end
		end
	end
	
	add_fruit_spawn_ptcs(fruit_x, fruit_y)
	fruit_pulse_timer = 0
end

function update_fruit()
	fruit_pulse_timer += 1
	if fruit_pulse_timer > 2 * fruit_pulse_speed then
		fruit_pulse_timer = 0
	end
end
-->8
-- gui.

dur_b4_gameover_draw = 36
b4_gameover_draw_timer = 0

replay_msg_blink_seq = { 7,15,5,2,5,15 }
replay_msg_step_dur = 1
replay_msg_index = 1
replay_msg_timer = 0

function draw_game_over()
	if game_state == "game_over" then
		
		b4_gameover_draw_timer += 1
		replay_msg_timer += 1
	
		if replay_msg_timer > replay_msg_step_dur then
			replay_msg_index += 1
			if replay_msg_index > #replay_msg_blink_seq then
				replay_msg_index = 1
			end
			replay_msg_timer = 0
		end
	
		local replay_msg_col = replay_msg_blink_seq[replay_msg_index]
	
		if b4_gameover_draw_timer > dur_b4_gameover_draw then
			rectfill(10, 45, 117, 61, 1)
			rect(10, 45, 117, 61, 13)
			print("game over! score:"..score, 30, 48, 7)
			print("press ❎ to replay", 30, 54, replay_msg_col)
		end
	end
end

function draw_score()
	if game_state == "play" then
		print("score:"..score, 90, 115, 7)
	end
end
-->8
-- feedback.

cur_trauma = 0
ptcs = {} -- particles.

pulse_x=0
pulse_y=0
pulse_min = 99
pulse_max = 99
pulse_col = 7
pulse_speed = 1

function add_fruit_eat_ptcs(x, y)
 for p = 0,7 do
 	local alpha=rnd()
 	add_ptc(
 		x * 5 + 5,
 		y * 5 + 5,
 		sin(alpha) * 2 + rnd(),
 		cos(alpha) * 2 + rnd(),
 		0,
 		9,
 		{ 7, 12, 6, 7 })
 end
end

function add_fruit_spawn_ptcs(x, y)
 for p = 0,7 do
 	local alpha=rnd()
 	add_ptc(
 		x * 5 + 5,
 		y * 5 + 5,
 		sin(alpha) * 3 + rnd(),
 		cos(alpha) * 3 + rnd(),
 		0,
 		6,
 		{ 7 })
 end
end

function add_ptc(
	x,
	y,
	dir_x,
	dir_y,
	t,
	max_age,
	col_seq)
	
	local ptc = {
		x = x,
		y = y,
		dir_x = dir_x,
		dir_y = dir_y,
		t = t,
		age = 0,
		max_age = max_age,
		col_seq = col_seq }
	
	add(ptcs, ptc)
end

function add_shake(trauma)
	cur_trauma += trauma;
	if cur_trauma > 1 then
		cur_trauma = 1
	end
end

function add_snk_death_ptc(x, y)
 for p = 0,10 do
 	local alpha=rnd()
 	add_ptc(
 		x * 5 + 5,
 		y * 5 + 5,
 		sin(alpha) * 2,
 		cos(alpha) * 2,
 		0,
 		9,
 		{ 8, 9, 10, 15, 7 })
 end
end

function add_snk_self_bite_ptcs(x, y, dir_x, dir_y)
 for p = 0,15 do
 
 	-- blood particles direction.
 	local alpha=0
 	if (dir_x == -1) alpha = 180
 	if (dir_y == 1) alpha = 270
 	if (dir_y == -1) alpha = 90
 
 	local rnd_vector = rnd_vector_in_cone(alpha,90)

 	add_ptc(
 		x * 5 + 3,
 		y * 5 + 3,
 		rnd_vector.x * (3 + rnd(4)),
 		rnd_vector.y * (3 + rnd(4)),
 		0,
 		6,
 		{ 8, 2 })
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

function pulse_grid(x, y, col, speed)
	pulse_x = x
	pulse_y = y
	pulse_max = 0
	pulse_min = 0
	pulse_col = col
	pulse_speed = speed
end

function rnd_vector_in_cone(angle, wideness)
	rnd_dir = 
		rnd(wideness / 720)
		- rnd(wideness / 720)
		+ (angle / 360)

 vx = cos(rnd_dir)
 vy = sin(rnd_dir)

	return { x = vx, y = vy }
end

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

function update_shake()
	local shake_x = (8 - rnd(16)) * cur_trauma
	local shake_y = (8 - rnd(16)) * cur_trauma
	
	camera(shake_x, shake_y)
	
	cur_trauma = cur_trauma * 0.95
	if cur_trauma < 0.05 then
	 cur_trauma = 0
	end
end

function set_shake(trauma)
	cur_trauma = trauma;
	if cur_trauma > 1 then
		cur_trauma = 1
	end
end
__gfx__
00000000099900000999000009984000489900004888400000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000999980009191900091998000899190009999900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700999980008999800099998000899990008999800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000488840009999900091998000899190009191900000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000044400004888400009984000489900000999000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aa900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002575025750257502475022750207501e7501c7501875014750127400e7400b73006720017100070009700087000670000700037000270001700007000070000700007000070000700007000070000700
000100000472008700087000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000f64006640056300463014630036200162000610066100562001610036000260000600006000560002600006000d6000c6000a6000860006600056000460002600006000060000600006000060000600
000500001c0401c0401b0401b0401a040180401704016030150301303012030100300d0300a030080300703005030040300303002030010300003000030000300003000010000100001000000000000000000000
__music__
00 01424344

