local state = {}

function state:enter()
	local kernel = soup.kernel()
		:add_system("physics", {
			all = set(),
			create = function(self, args)
				args = args or {}
				local c = {
					pos = args.pos or vec2(),
					vel = args.vel or vec2(),
					acc = args.acc or vec2(),
				}
				self.all:add(c)
				return c
			end,
			added = function(self, component)
				if component.pos and component.vel and component.acc then
					self.all:add(component)
				end
			end,
			removed = function(self, component)
				self.all:remove(component)
			end,
			update = function(self, dt)
				for _, v in self.all:ipairs() do
					v.vel:fmai(v.acc, dt)
					v.pos:fmai(v.vel, dt)
				end
			end,
			order = 1000,
		})
	self.k = kernel

	kernel:add({
		pos = vec2(100, 100),
		t = 0,
		update = function(self, dt)
			if not self.opos then
				self.opos = self.pos:copy()
			end
			self.t = self.t + dt
			self.pos:vset(self.opos)
				:saddi(math.sin(self.t) * 50, math.cos(self.t * 2.5) * 10)
		end,
		draw = function()
			lg.print("test guy")
		end,
	})

	kernel:add({
		timer = 0,
		time = 0.005,
		update = function(self, dt)
			self.timer = self.timer + dt
			if self.timer >= self.time then
				self.timer = self.timer - self.time
				local e = kernel:entity()
				local phys = e:add_named_from_system("physics", "physics", {
					pos = vec2(love.mouse.getPosition()),
					vel = vec2(
						love.math.randomNormal(),
						love.math.randomNormal()
					):smuli(10),
					acc = vec2(0, 50),
				})
				local expire = e:add_named("expire", {
					timer = 0,
					time = 5,
					factor = function(self)
						return math.clamp01(self.timer / self.time)
					end,
					update = function(self, dt)
						self.timer = self.timer + dt
						if self.timer >= self.time then
							e:destroy()
						end
					end,
				})
				local dot = e:add_named("dot", {
					pos = phys.pos,
					draw = function(self)
						lg.setColor(1, 1, 1, math.lerp(1, 0, expire:factor()))
						lg.circle("fill", 0, 0, 2)
					end,
				})
			end
		end,
	})

	UPDATE_TIME = 0
	DRAW_TIME = 0
	kernel:add({
		pos = vec2(10, 10),
		draw = function()
			TOTAL_TIME = UPDATE_TIME + DRAW_TIME + main_loop.garbage_time
			lg.print(([[
				%04.2fms total (%d maximum fps - %d ticks %d draws)
				%04.2fms update
				%04.2fms draw
				%04.2fmb
				%d components
			]]):dedent():format(
				TOTAL_TIME * 1000,
				1 / math.max(0.0001, TOTAL_TIME),
				main_loop.ticks_per_second:get(),
				main_loop.frames_per_second:get(),
				UPDATE_TIME * 1000,
				DRAW_TIME * 1000,
				collectgarbage("count") / 1024,
				#kernel.all
			))
		end,
	})
end
function state:update(dt)
	local start_time = love.timer.getTime()
	self.k:update(dt)
	local end_time = love.timer.getTime()
	UPDATE_TIME = (end_time - start_time)
end
function state:draw()
	local start_time = love.timer.getTime()
	self.k:draw()
	local end_time = love.timer.getTime()
	DRAW_TIME = (end_time - start_time)
end

return state