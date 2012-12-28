-- Platformer ... a simple platform game/demo
-- Written by Rob Probin
--
-- A flip-screen-based platformer http://en.wikipedia.org/wiki/Flip-screen
-- Examples of flip-sceen http://www.giantbomb.com/flip-screen/92-2123/
--
-- SpriteBatch tile based on https://love2d.org/wiki/Tutorial:Efficient_Tile-based_Scrolling
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

function draw_room()
	
end


--
function setup_map()
	mapWidth = screenWidth / tileSize
	mapHeight = screenHeight / tileSize

	map = {}
	
	-- random stuff in the map
	for x = 1, mapWidth do
		map[x] = {}
		for y=1,mapHeight do
			local k = math.random(0,3)
			if k == 1 or k == 3 then
				k = 0
			end
			map[x][y] = k
		end
	end
	
	-- bottom and top border
	for x = 1, mapWidth do
		map[x][1] = 2
		map[x][mapHeight] = 2
	end
	
	-- left and right border
	for y = 1, mapWidth do
		map[1][y] = 2
		map[mapWidth][y] = 2
	end
	
	-- ensure start position is clear
	map[2][mapHeight-1] = 1
	map[2][mapHeight-2] = 1
	map[3][mapHeight-1] = 1
	map[3][mapHeight-2] = 1
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
	characterImage = love.graphics.newImage( "media/warrior.png" )
	local count = 0
	for y = 0, 3 do
		for x = 0, 3 do			
			characterQuads[count] = imagequad(x, y, characterImage, 28, 38)
			count = count + 1
		end
	end
	
	accumulated_time = 0
	animation_step = 0
	direction = 1
	movement = 0
	
	player_x = 1.5 * tileSize
	player_y = (mapHeight-2.1) * tileSize
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
end



function draw_character()
	local animation
	if direction == 0 then
		animation = 9
	elseif direction < 0 then
		animation = animation_step + 12
	else
		animation = animation_step + 4
	end
	love.graphics.drawq(characterImage, characterQuads[animation], player_x, player_y)
end


-- love.update is called continuously and will probably be where most of your 
-- math is done. 'dt' stands for "delta time" and is the amount of seconds since 
-- the last time this function was called (which is usually a small value like 
-- 0.025714).
--

function love.update(dt)
	if gameIsPaused then return end
	
	if movement ~= 0 then
		
		player_x = player_x + (direction * dt * 60)
		
		accumulated_time = accumulated_time + dt
		if accumulated_time > 0.2 then
			accumulated_time = accumulated_time - 0.2
			animation_step = animation_step + 1
			if animation_step > 3 then
				animation_step = 0
			end
		end

	end

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
    print("LOST FOCUS")
  else
    print("GAINED FOCUS")
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
		print("quit0")
		if love.event.quit then
			print("quit1")
			love.event.quit()
		else
			print("quit2")
			love.event.push('q')
		end
	elseif key == 'right' or key == 'd' then
		direction = 1
		movement = 1
		last_movement_key = key
	elseif key == 'left' or key == 'a' then
		direction = -1
		movement = 1
		last_movement_key = key
	elseif key == 'up' or key == 'space' then
	end
end

-- This function is called whenever a keyboard key is released and receives the key that was released. You can have this function together with love.keypressed or separate, they aren't connected in any way.
function love.keyreleased(key, unicode)
	if key == last_movement_key then
		movement = 0
	end
end


