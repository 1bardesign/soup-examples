require("batteries"):export()

soup = require("soup")
--setup the main loop
main_loop = soup.main_loop({

})

--convenient globals
lg = love.graphics

game_state = state_machine({
	example = require("example"),
}, "example")

function love.update(dt)
	--todo: input stuff
	game_state:update(dt)
end

function love.draw()
	game_state:draw()
end

function love.keypressed(k)
	if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
		if k == "r" then
			love.event.quit("restart")
		elseif k == "q" then
			love.event.quit()
		end
	end
end