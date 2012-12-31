-- Map Manager for Platformer
--
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

require('libs.middleclass')

local init_map = { 
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
	"--------------------------------", -- 24
	objects = {
		--{ type = "diamond", x = 160, y = 200 },
	}
}

local second_map = { 
--              11111111112222222222333
--     12345678901234567890123456789012
	"--------------------------------", -- 1
	"-     -                        -", -- 2
	"-     -                        -", -- 3
	"-     ------------------     ---", -- 4
	"-                            ---", -- 5
	"-                         ------", -- 6
	"-                ---------------", -- 7
	"------                         -", -- 8
	"-    -----                     -", -- 9
	"-         -----                -", -- 10
	"-           ------          ----", -- 11
	"-  --------              -------", -- 12
	"-                      -----   -", -- 13
	"-                    ---       -", -- 14
	"-                 ---          -", -- 15
	"-                -----  --------", -- 16
	"-                ---------     -", -- 17
	"-     ----                     -", -- 18
	"-       -----                  -", -- 19
	"-          -----               -", -- 20
	"-              ----            -", -- 21
	"-               ------         -", -- 22
	"-           ------------       -", -- 23
	"---------------------------  ---", -- 24
	objects = {
		--{ type = "diamond", x = 160, y = 200 },
	}

}

MapManager = class('MapManager')
function MapManager:initialize(mapWidth, mapHeight, empty_value, wall_value)

	self._mapWidth = mapWidth
	self._mapHeight = mapHeight
	self._empty_value = empty_value
	self._wall_value = wall_value
	
	self:_load_named(init_map)
	
end

function MapManager:set(x,y, value)
	if x < 1 or x > self._mapWidth then
		return
	end
	if y < 1 or y > self._mapHeight then
		return
	end
	self._map[x][y] = value
end

function MapManager:get(x,y)
	if x < 1 or x > self._mapWidth then
		return self._empty_value
	end
	if y < 1 or y > self._mapHeight then
		return self._empty_value
	end
	return self._map[x][y]
end

function MapManager:get_object_list()
	return self._current.objects
end

function MapManager:switch_maps()
	
	local map = init_map
	if self._current == init_map then
		map = second_map
	end
	
	self:_load_named(map)
end

function MapManager:_load_named(map_name)
	self._map = {}		-- stores tiledata
	
	-- random stuff in the map
	for x = 1, self._mapWidth do
		self._map[x] = {}
		for y=1, self._mapHeight do
			--local k = math.random(0,3)
			--if k ~= wallValue then
			--	k = 0
			--end
			local c = map_name[y]:sub(x, x)
			local k = self._empty_value
			if c == "-" or c == nil then
				k = self._wall_value
			end
			print(x, y, k)
			self._map[x][y] = k
		end
	end
	
	self._current = map_name
end




