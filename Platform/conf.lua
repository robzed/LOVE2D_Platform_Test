-- see https://love2d.org/wiki/Config_Files
function love.conf(t)
    t.window = t.window or t.screen
    
    t.title = "Platform"        -- The title of the window the game is in (string)
    t.author = "Rob Probin"     -- The author of the game (string)
	-- t.url = nil                 -- The website of the game (string)
    -- t.identity = "Robs_Platformer"    -- The name of the save directory (string)
    --t.version = "0.8.0"         -- The LÖVE version this game was made for (string)
    --t.console = false           -- Attach a console (boolean, Windows only)
    --t.release = false           -- Enable release mode (boolean)
    t.window.width = 1024       -- The window width (number)
    t.window.height = 768       -- The window height (number)
	-- t.screen.fullscreen = false -- Enable fullscreen (boolean)
    
    t.screen = t.screen or t.window
end


