-- Platformer ... a simple platform game/demo
-- Written by Rob Probin, starting 27th December 2012.
--
-- Copyright (C) 2012 Rob Probin
-- 
-- This program is free software; you can redistribute it and/or modify it under 
-- the terms of the GNU General Public License as published by the Free Software 
-- Foundation; either version 2 of the License, or (at your option) any later 
-- version.
--
-- This program is distributed in the hope that it will be useful, but WITHOUT 
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
-- FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along with 
-- this program; if not, write to the Free Software Foundation, Inc., 59 Temple 
-- Place, Suite 330, Boston, MA 02111-1307 USA
--
--
-- REFERENCES
--
-- A flip-screen-based platformer http://en.wikipedia.org/wiki/Flip-screen
-- Examples of flip-sceen http://www.giantbomb.com/flip-screen/92-2123/
--
-- SpriteBatch tile based on https://love2d.org/wiki/Tutorial:Efficient_Tile-based_Scrolling


-- TO DO
--
-- * PowerPC Audio broken
-- * Johnny got a out of bounds crash?!?!
-- * tidy up this mess of hacky code and make into seperate source files (modules)
-- * New room at top


local map -- stores tiledata
local mapWidth, mapHeight -- width and height in tiles

local mapX, mapY -- view x,y in tiles. can be a fractional value like 3.25.

local tilesDisplayWidth, tilesDisplayHeight -- number of tiles to show

local tilesetImage
local tileSize -- size of tiles in pixels
local tileQuads = {} -- parts of the tileset used for different tiles
local tilesetSprite

local characterImage
local characterQuads = {}

wallValue = 2




init_map = { 
--              11111111112222222222333
--     12345678901234567890123456789012
	"---------------------------  ---", -- 1
	"-                              -", -- 2
	"-                              -", -- 3
	"-     -------  -----------------", -- 4
	"-                              -", -- 5
	"-                              -", -- 6
	"-             --               -", -- 7
	"-              ---             -", -- 8
	"-    ------                    -", -- 9
	"-         --          ----     -", -- 10
	"-             ---    -         -", -- 11
	"-  --------                    -", -- 12
	"-                              -", -- 13
	"-             ------------     -", -- 14
	"-                              -", -- 15
	"-                           ----", -- 16
	"-                  -------     -", -- 17
	"-                              -", -- 18
	"-                              -", -- 19
	"-          ---------           -", -- 20
	"-                              -", -- 21
	"-                     ----     -", -- 22
	"-           ----------         -", -- 23
	"--------------------------------" -- 24
}
--
function setup_map()
	mapWidth = screenWidth / tileSize
	mapHeight = screenHeight / tileSize

	map = {}
	
	-- random stuff in the map
	for x = 1, mapWidth do
		map[x] = {}
		for y=1,mapHeight do
			--local k = math.random(0,3)
			--if k ~= wallValue then
			--	k = 0
			--end
			local c = init_map[y]:sub(x, x)
			local k = 0
			if c == "-" then
				k = wallValue
			elseif c == nil then
				k = wallValue
			end
			map[x][y] = k
		end
	end


	--[[
	-- bottom and top border
	for x = 1, mapWidth do
		map[x][1] = wallValue
		map[x][mapHeight] = wallValue
	end
	
	-- left and right border
	for y = 1, mapWidth do
		map[1][y] = wallValue
		map[mapWidth][y] = wallValue
	end
	]]
	
	-- ensure start position is clear
	map[2][mapHeight-1] = 0
	map[2][mapHeight-2] = 0
	map[3][mapHeight-1] = 0
	map[3][mapHeight-2] = 0
end

--
function setup_view()
	tilesDisplayWidth = screenWidth / tileSize
	tilesDisplayHeight = screenHeight / tileSize
	mapX = 1
	mapY = 1
end

function imagequad(x, y, image, tsx, tsy)
	tsx = tsx or tileSize
	tsy = tsy or tileSize
	return love.graphics.newQuad(x * tsx, y * tsy, tsx, tsy,
    image:getWidth(), image:getHeight())
end

function setup_tileset()
	tilesetImage = love.graphics.newImage( "media/Resource-ExampleEfficientTileset.png" )
	tilesetImage:setFilter("nearest", "linear") -- this "linear filter" removes some artifacts if we were to scale the tiles

  -- grass
  tileQuads[0] = love.graphics.newQuad(0 * tileSize, 20 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- kitchen floor tile
  tileQuads[1] = love.graphics.newQuad(2 * tileSize, 0 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- parquet flooring
  tileQuads[2] = love.graphics.newQuad(4 * tileSize, 0 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())
  -- middle of red carpet
  tileQuads[3] = love.graphics.newQuad(3 * tileSize, 9 * tileSize, tileSize, tileSize,
    tilesetImage:getWidth(), tilesetImage:getHeight())

  tilesetBatch = love.graphics.newSpriteBatch(tilesetImage, tilesDisplayWidth * tilesDisplayHeight)
  
  updateTilesetBatch()
end

-- We only wish to add to the SpriteBatch the tiles that are presently visible. To do this, we make a function that updates the tileset and call it whenever the map focus changes. We also call it once in the initialization.
function updateTilesetBatch()
  tilesetBatch:clear()
  for x=0, tilesDisplayWidth-1 do
    for y=0, tilesDisplayHeight-1 do
      tilesetBatch:addq(tileQuads[map[x+mapX][y+mapY]], x*tileSize, y*tileSize)
    end
  end
end

function setup_character_image()

	character_height = 38
	character_width = 28

	characterImage = love.graphics.newImage( "media/warrior.png" )
	local count = 0
	for y = 0, 3 do
		for x = 0, 3 do			
			characterQuads[count] = imagequad(x, y, characterImage, character_width, character_height)
			count = count + 1
		end
	end
	
	accumulated_time = 0
	animation_step = 0
	direction = 1
	movement = 0
	
	new_direction = 1
	new_movement = 0
	
	fall_accumulated_time = 0
	
	player_x = 1.5 * tileSize
	player_y = return_floor_below((mapHeight-1) * tileSize)-character_height
	player_jumping = false
	new_player_jumping = false
	player_jump_count = 0
	on_floor = false
end

-- love.load gets called only once, when the game is started, and is usually 
-- where you would load resources, initialize variables and set specific 
-- settings. All those things can be done anywhere else as well, but doing them 
-- here means that they are done once only, saving a lot of system resources.
--
function love.load()
	screenWidth = 1024
	screenHeight = 768

	tileSize = 32

	setup_map()
	setup_view()
	setup_tileset()
	setup_character_image()
	love.graphics.setFont(love.graphics.newFont(12))
	setup_sound()
end

function point_in_wall(x,y)
	x = math.floor(x / tileSize + 1)
	y = math.floor(y / tileSize + 1)
	if x < 1 or x > #map then
		return false
	end
	if map[x][y] == wallValue then
		return true
	end
	
	return false
end

-- bit rubbish .. checks 6 points not bounds
function box_in_wall(x, y, width, height)
	return point_in_wall(x, y) or point_in_wall(x+width, y) or 
		point_in_wall(x, y+(height/2)) or point_in_wall(x+width, y+(height/2)) or
			point_in_wall(x, y+height) or point_in_wall(x+width, y+height)
end

function return_floor_above(y)
	return (math.floor(y / tileSize)+1) * tileSize - 0.0000000001	-- fractionally above floor
end
function return_floor_below(y)
	return (math.floor(y / tileSize)) * tileSize - 0.0000000001	-- fractionally above floor
end


max_fall_speed_per_second = -300	-- going down is negative
fall_acceleration = -350

jump_speed_per_second = 300		-- +ve is going up
player_vertical_speed = 0		-- start at zero

max_jump_height = 100
current_jump_height = 0
movement_speed_per_second = 100

function move_player(time_step)

	-- we only allow left/right and jump when we are on the floor
	if on_floor then 
		if new_player_jumping and player_jumping == false then
			play_sound("jump")
			player_vertical_speed = jump_speed_per_second
			on_floor = false
		end
		player_jumping = new_player_jumping
		direction = new_direction
		movement = new_movement
	end
	
	-- acceleration to speed calculation for gravity... 
	local fall_speed_delta = (fall_acceleration*time_step)
	-- speeds are positive for going up and negative for going down
	-- note, therefore, falling is downwards (which is in the minus sign of fall_acceleration
	player_vertical_speed = player_vertical_speed + fall_speed_delta
	-- cap the speed, however, to stop sillyness
	if player_vertical_speed < max_fall_speed_per_second then
		player_vertical_speed = max_fall_speed_per_second
	end
	
	-- now we want to calculate the distance we've travelled in this time_step
	local distance_delta = (player_vertical_speed*time_step)
	local temp_player_y = player_y - distance_delta
	-- calculate some flags for clarity
	local going_down = distance_delta < 0
	local going_up = distance_delta > 0
	
	if box_in_wall(player_x, temp_player_y, character_width, character_height) then
		if going_up then
			movement = 0		-- cancel movement if we hit a ceiling or wall
		end
		
		-- whatever happens if we hit a wall or a floor or a ceiling, we need to stop the veritical speed
		player_vertical_speed = 0

		-- if we were going down and we hit something, we must be on the 'floor'
		if going_down then
			on_floor = true
			going_down_before = false
			going_down = false
			
			-- need to ensure that we are on the floor
			player_y = return_floor_above(player_y+character_height)-character_height
		end
					
		-- cancel the jump flags
		player_jumping = false
		new_player_jumping = false
	else
		-- move up/down is valid
		player_y = temp_player_y
		if going_down then
			on_floor = false
		end
	end

	-- do falling sound
	if going_down then

		if not going_down_before then
			going_down_before = true
			sound_fall:play()
		end
	else
		sound_fall:stop()
	end

	--
	-- Now deal with left/right movement
	-- 
	if movement ~= 0 then
	
		-- now let's do the actual movement
		local temp_player_x = player_x + (direction * time_step * movement_speed_per_second)
		
		if not box_in_wall(temp_player_x, player_y, character_width, character_height) then
			player_x = temp_player_x
		else
			-- maybe make it as close to the wall as possible?
		end

	end
	
	if new_movement ~= 0 then
		-- left/right animation is done on a time bases, 5 times per second
		accumulated_time = accumulated_time + time_step
		if accumulated_time > 0.2 then
			accumulated_time = accumulated_time - 0.2
			animation_step = animation_step + 1
			if animation_step > 3 then
				animation_step = 0
			end
			-- cap the time to 2 seconds (very slow machine)
			if accumulated_time > 2 then
				accumulated_time = 1
			end
		end
	end
	
end


function draw_character()
	local animation
	if new_direction == 0 then
		animation = 9
	elseif new_direction < 0 then
		animation = animation_step + 12
	else
		animation = animation_step + 4
	end
	love.graphics.drawq(characterImage, characterQuads[animation], player_x, player_y)
end

sound_fall_on = false
sound_jump_on = false

function setup_sound()
	sound_fall = love.audio.newSource("media/fall1.wav", "static") -- the "static" tells LÖVE to load the file into memory, good for short sound 
	sound_fall:setVolume(0.3)
	sound_jump = love.audio.newSource("media/jump1.wav", "static") -- the "static" tells LÖVE to load the file into memory, good for short sound 
end

function play_sound(sound)
	if sound == "fall" and not sound_fall_on then
		sound_fall_on = true
		sound_fall:play()		-- same as love.audio.play(sound)
	end
	if sound == "jump" then
		sound_jump_on = true
		sound_jump:stop()
		sound_jump:play()		-- same as love.audio.play(sound)
	end
end

function stop_sound(sound)
	if sound == "fall" and sound_fall_on then
		sound_fall_on = false
		sound_fall:stop()
	end
	if sound == "jump" and sound_jump_on then
		sound_jump_on = false
		sound_jump:stop()
	end
end

-- love.update is called continuously and will probably be where most of your 
-- math is done. 'dt' stands for "delta time" and is the amount of seconds since 
-- the last time this function was called (which is usually a small value like 
-- 0.025714).
--

function love.update(dt)
	if gameIsPaused then return end
	
	move_player(dt)

end

-- love.draw is where all the drawing happens (if that wasn't obvious enough 
-- already) and if you call any of the love.graphics.draw outside of this 
-- function then it's not going to have any effect. This function is also 
-- called continuously so keep in mind that if you change the 
-- font/color/mode/etc at the end of the function then it will have a effect on 
-- things at the beginning of the function. 
-- 
function love.draw()
    --love.graphics.print("Hello World", 400, 300)
	--for i=1, 10 do
	--	love.graphics.print(i*100, i*100, 300)
	--end
	
	love.graphics.draw(tilesetBatch)
	draw_character()
	love.graphics.print("FPS: "..love.timer.getFPS(), 10, 20)
end

-- This function is called whenever a mouse button is pressed and it receives 
-- the button and the coordinates of where it was pressed. The button can be 
-- any of the constants. This function goes very well along with 
-- love.mousereleased.
--
function love.mousepressed(x, y, button)
   if button == 'l' then
      imgx = x -- move image to where mouse clicked
      imgy = y
	  
	  --direction = 0 - direction
   end
end

-- This function is called whenever a mouse button is released and it receives 
-- the button and the coordinates of where it was released. You can have this 
-- function together with love.mousepressed or separate, they aren't connected 
-- in any way.
--
function love.mousereleased(x, y, button)
   if button == 'l' then
      -- fireSlingshot(x,y) -- this totally awesome custom function is defined elsewhere
   end
end

-- This function is called whenever the user clicks off and on the LOVE window. 
-- For instance, if he is playing a windowed game and a user clicks on his 
-- Internet browser, the game could be notified and automatically pause the game.
function love.focus(f)
  if not f then
    --print("LOST FOCUS")
  else
    --print("GAINED FOCUS")
  end
  gameIsPaused = not f
end

-- This function is called whenever the user clicks the windows close button 
-- (often an X). For instance, if the user decides he is done playing, he could 
-- click the close button. Then, before it closes, the game can save its state.
function love.quit()
  --print("Thanks for playing! Come back soon!")
end

-- This function is called whenever a keyboard key is pressed and receives the key that was pressed. The key can be any of the constants. This functions goes very well along with love.keyreleased.
function love.keypressed(key, unicode)
	if key == 'escape' then
		if love.event.quit then
			love.event.quit()
		else
			love.event.push('q')
		end
	elseif (key == 'right' or key == 'd') then
		new_direction = 1
		new_movement = 1
		last_movement_key = key
	elseif (key == 'left' or key == 'a') then
		new_direction = -1
		new_movement = 1
		last_movement_key = key
	elseif key == 'up' or key == ' ' or key == 'w' then
		new_player_jumping = true
	end
end

-- This function is called whenever a keyboard key is released and receives the key that was released. You can have this function together with love.keypressed or separate, they aren't connected in any way.
function love.keyreleased(key, unicode)
	if key == 'up' or key == ' ' or key == 'w' then
		new_player_jumping = false
	elseif key == last_movement_key then
		new_movement = 0
	end
end


