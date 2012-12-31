-- Object Manager for Platformer
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


ObjectControlBlockManager = class('ObjectControlBlockManager')
function ObjectControlBlockManager:initialize(object_list)
	self._objects = {}
	for k, v in ipairs(object_list) do
		if v.type == "diamond" then
			if v.x and v.y then
				local obj = { x = v.x, y = v.y }
				table.insert(self._objects, obj)
			end
		end
	end
end

function ObjectControlBlockManager:update(dt)
	for k, v in ipairs(self._objects) do
		-- nothing
	end
end

function ObjectControlBlockManager:draw()
	for k, v in ipairs(self._objects) do
		love.graphics.drawq(characterImage, characterQuads[0], v.x, v.y)
	end
end







