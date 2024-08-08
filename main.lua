--deps
require("batteries"):export()
soup = require("soup")

--setup the main loop
main_loop = soup.main_loop({
	--args?
})

--convenient globals
lg = love.graphics
input = soup.input

--
game_state = require("src.game_state")

function love.update(dt)
	input:update(dt)
	game_state:update(dt)
end

function love.draw()
	game_state:draw()
end

function love.keypressed(k)
	--inline restart or quit, handy for development
	if love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl") then
		if k == "r" then
			love.event.quit("restart")
		elseif k == "q" then
			love.event.quit()
		end
	end
	input.keyboard:keypressed(k)
end

function love.keyreleased(k)
	input.keyboard:keyreleased(k)
end

function love.mousepressed(x, y, b)
	input.mouse:mousepressed(x, y, b)
end

function love.mousereleased(x, y, b)
	input.mouse:mousereleased(x, y, b)
end

function love.wheelmoved(x, y)
	input.mouse:wheelmoved(x, y)
end

