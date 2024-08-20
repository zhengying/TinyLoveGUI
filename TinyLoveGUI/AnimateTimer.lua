-- --[[
-- Copyright (c) 2018 SSYGEN, Matthias Richter

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- Except as contained in this notice, the name(s) of the above copyright holders
-- shall not be used in advertising or otherwise to promote the sale, use or
-- other dealings in this Software without prior written authorization.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
-- ]]--



-- The base Timer class.
-- A global instance of this called "Timer" is available by default.
local cwd = select(1, ...):match(".+%.") or ""
local Object = require(cwd .. "Object")
local AnimateTimer = Object:extend()

local PI = math.pi
local PI2 = math.pi/2 
local LN2 = math.log(2)
local LN210 = 10*math.log(2)

local function random_float(min, max)
    -- Generate a random floating-point number between 0 and 1
    local rand = love.math.random()
    -- Scale and shift to the desired range
    return min + (max - min) * rand
end


function AnimateTimer.linear(t)
  return t
end


function AnimateTimer.sine_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return 1 - math.cos(t*PI2) end
end


function AnimateTimer.sine_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.sin(t*PI2) end
end


function AnimateTimer.sine_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return -0.5*(math.cos(t*PI) - 1) end
end


function AnimateTimer.sine_out_in(t)  
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then return 0.5*math.sin((t*2)*PI2)
  else return -0.5*math.cos((t*2-1)*PI2) + 1 end
end


function AnimateTimer.quad_in(t)
  return t*t
end


function AnimateTimer.quad_out(t)
  return -t*(t-2)
end


function AnimateTimer.quad_in_out(t)
  if t < 0.5 then
    return 2*t*t
  else
    t = t - 1
    return -2*t*t + 1
  end
end


  function AnimateTimer.quad_out_in(t)
  if t < 0.5 then
    t = t*2
    return -0.5*t*(t-2)
  else
    t = t*2 - 1
    return 0.5*t*t + 0.5
  end
end


function AnimateTimer.cubic_in(t)
  return t*t*t
end

function AnimateTimer.cubic_out(t)
  t = t - 1
  return t*t*t + 1
end


function AnimateTimer.cubic_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t
  else
    t = t - 2
    return 0.5*(t*t*t + 2)
  end
end


function AnimateTimer.cubic_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t + 1)
end


function AnimateTimer.quart_in(t)
  return t*t*t*t
end


function AnimateTimer.quart_out(t)
  t = t - 1
  t = t*t
  return 1 - t*t
end


function AnimateTimer.quart_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t
  else
    t = t - 2
    t = t*t
    return -0.5*(t*t - 2)
  end
end


function AnimateTimer.quart_out_in(t)
  if t < 0.5 then
    t = t*2 - 1
    t = t*t
    return -0.5*t*t + 0.5
  else
    t = t*2 - 1
    t = t*t
    return 0.5*t*t + 0.5
  end
end


function AnimateTimer.quint_in(t)
  return t*t*t*t*t
end


function AnimateTimer.quint_out(t)
  t = t - 1
  return t*t*t*t*t + 1
end


function AnimateTimer.quint_in_out(t)
  t = t*2
  if t < 1 then
    return 0.5*t*t*t*t*t
  else
    t = t - 2
    return 0.5*t*t*t*t*t + 1
  end
end


function AnimateTimer.quint_out_in(t)
  t = t*2 - 1
  return 0.5*(t*t*t*t*t + 1)
end


function AnimateTimer.expo_in(t)
  if t == 0 then return 0
  else return math.exp(LN210*(t - 1)) end
end


function AnimateTimer.expo_out(t)
  if t == 1 then return 1
  else return 1 - math.exp(-LN210*t) end
end


function AnimateTimer.expo_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1 end
  t = t*2
  if t < 1 then return 0.5*math.exp(LN210*(t - 1))
  else return 0.5*(2 - math.exp(-LN210*(t - 1))) end
end


function AnimateTimer.expo_out_in(t)
  if t < 0.5 then return 0.5*(1 - math.exp(-20*LN2*t))
  elseif t == 0.5 then return 0.5
  else return 0.5*(math.exp(20*LN2*(t - 1)) + 1) end
end


function AnimateTimer.circ_in(t)
  if t < -1 or t > 1 then return 0
  else return 1 - math.sqrt(1 - t*t) end
end


function AnimateTimer.circ_out(t)
  if t < 0 or t > 2 then return 0
  else return math.sqrt(t*(2 - t)) end
end


function AnimateTimer.circ_in_out(t)
  if t < -0.5 or t > 1.5 then return 0.5
  else
    t = t*2
    if t < 1 then return -0.5*(math.sqrt(1 - t*t) - 1)
    else
      t = t - 2
      return 0.5*(math.sqrt(1 - t*t) + 1)
    end
  end
end


function AnimateTimer.circ_out_in(t)
  if t < 0 then return 0
  elseif t > 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*math.sqrt(1 - t*t)
  else
    t = t*2 - 1
    return -0.5*((math.sqrt(1 - t*t) - 1) - 1)
  end
end


function AnimateTimer.bounce_in(t)
  t = 1 - t
  if t < 1/2.75 then return 1 - (7.5625*t*t)
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 1 - (7.5625*t*t + 0.75)
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 1 - (7.5625*t*t + 0.9375)
  else
    t = t - 2.625/2.75
    return 1 - (7.5625*t*t + 0.984375)
  end
end


function AnimateTimer.bounce_out(t)
  if t < 1/2.75 then return 7.5625*t*t
  elseif t < 2/2.75 then
    t = t - 1.5/2.75
    return 7.5625*t*t + 0.75
  elseif t < 2.5/2.75 then
    t = t - 2.25/2.75
    return 7.5625*t*t + 0.9375
  else
    t = t - 2.625/2.75
    return 7.5625*t*t + 0.984375
  end
end


function AnimateTimer.bounce_in_out(t)
  if t < 0.5 then
    t = 1 - t*2
    if t < 1/2.75 then return (1 - (7.5625*t*t))*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (1 - (7.5625*t*t + 0.75))*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (1 - (7.5625*t*t + 0.9375))*0.5
    else
      t = t - 2.625/2.75
      return (1 - (7.5625*t*t + 0.984375))*0.5
    end
  else
    t = t*2 - 1
    if t < 1/2.75 then return (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end


function AnimateTimer.bounce_out_in(t)
  if t < 0.5 then
    t = t*2
    if t < 1/2.75 then return (7.5625*t*t)*0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return (7.5625*t*t + 0.75)*0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return (7.5625*t*t + 0.9375)*0.5
    else
      t = t - 2.625/2.75
      return (7.5625*t*t + 0.984375)*0.5
    end
  else
    t = 1 - (t*2 - 1)
    if t < 1/2.75 then return 0.5 - (7.5625*t*t)*0.5 + 0.5
    elseif t < 2/2.75 then
      t = t - 1.5/2.75
      return 0.5 - (7.5625*t*t + 0.75)*0.5 + 0.5
    elseif t < 2.5/2.75 then
      t = t - 2.25/2.75
      return 0.5 - (7.5625*t*t + 0.9375)*0.5 + 0.5
    else
      t = t - 2.625/2.75
      return 0.5 - (7.5625*t*t + 0.984375)*0.5 + 0.5
    end
  end
end


local overshoot = 1.70158

function AnimateTimer.back_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return t*t*((overshoot + 1)*t - overshoot) end
end


function AnimateTimer.back_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return t*t*((overshoot + 1)*t + overshoot) + 1
  end
end


function AnimateTimer.back_in_out(t)  
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then return 0.5*(t*t*(((overshoot*1.525) + 1)*t - overshoot*1.525))
    else
      t = t - 2
      return 0.5*(t*t*(((overshoot*1.525) + 1)*t + overshoot*1.525) + 2)
    end
  end
end


function AnimateTimer.back_out_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  elseif t < 0.5 then
    t = t*2 - 1
    return 0.5*(t*t*((overshoot + 1)*t + overshoot) + 1)
  else
    t = t*2 - 1
    return 0.5*t*t*((overshoot + 1)*t - overshoot) + 0.5
  end
end


local amplitude = 1
local period = 0.0003

function AnimateTimer.elastic_in(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t - 1
    return -(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
  end
end


function AnimateTimer.elastic_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else return math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 1 end
end


function AnimateTimer.elastic_in_out(t)
  if t == 0 then return 0
  elseif t == 1 then return 1
  else
    t = t*2
    if t < 1 then
      t = t - 1
      return -0.5*(amplitude*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period))
    else
      t = t - 1
      return amplitude*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)*0.5 + 1
    end
  end
end


function AnimateTimer.elastic_out_in(t)
  if t < 0.5 then
    t = t*2
    if t == 0 then return 0
    else return (amplitude/2)*math.exp(-LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period) + 0.5 end
  else
    if t == 0.5 then return 0.5
    elseif t == 1 then return 1
    else
      t = t*2 - 1
      t = t - 1
      return -((amplitude/2)*math.exp(LN210*t)*math.sin((t*0.001 - period/4)*(2*PI)/period)) + 0.5
    end
  end
end
-- Lerps src to dst with lerp value.
-- v = math.lerp(0.2, self.x, self.x + 100)
function AnimateTimer.lerp(value, src, dst)
    return src*(1 - value) + dst*value
end

  

local function UUID()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end


function AnimateTimer:init()
  self.Timers = {}
  self.time = love.timer.getTime()
end


-- Calls the action every frame until it's cancelled via Timer:cancel.
-- The tag must be passed in otherwise there will be no way to stop this from running.
-- If after is passed in then it is called after the run is cancelled.
function AnimateTimer:run(action, after, tag)
  local tag = tag or UUID()
  local after = after or function() end
  self.Timers[tag] = {type = "run", timer = 0, after = after, action = action}
end


-- Calls the action after delay seconds.
-- Or calls the action after the condition is true.
-- If tag is passed in then any other Timer actions with the same tag are automatically cancelled.
-- Timer:after(2, function() print(1) end) -> prints 1 after 2 seconds
-- Timer:after(function() return self.should_print_1 end, function() print(1) end) -> prints 1 after self.should_print_1 is set to true
function AnimateTimer:after(delay, action, tag)
  local tag = tag or UUID()
  if type(delay) == "number" or type(delay) == "table" then
    self.Timers[tag] = {type = "after", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action}
  else
    self.Timers[tag] = {type = "conditional_after", condition = delay, action = action}
  end
end


-- Calls the action every delay seconds if the condition is true.
-- If the condition isn't true when delay seconds are up then it waits and only performs the action and resets the timer when that happens.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other Timer actions with the same tag are automatically cancelled.
-- Timer:cooldown(2, function() return #self:get_objects_in_shape(self.attack_sensor, enemies) > 0 end, function() self:attack() end) -> only attacks when 2 seconds have passed and there are more than 0 enemies around
function AnimateTimer:cooldown(delay, condition, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or UUID()
  self.Timers[tag] = {type = "cooldown", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), condition = condition, action = action, times = times, max_times = times, after = after, multiplier = 1}
end


-- Calls the action every delay seconds.
-- Or calls the action once every time the condition becomes true.
-- If times is passed in then it only calls action for that amount of times.
-- If after is passed in then it is called after the last time action is called.
-- If tag is passed in then any other Timer actions with the same tag are automatically cancelled.
-- Timer:every(2, function() print(1) end) -> prints 1 every 2 seconds
-- Timer:every(2, function() print(1) end, 5, function() print(2) end) -> prints 1 every 2 seconds 5 times, and then prints 2
-- Timer:every(function() return player.hit end, function() print(1) end) -> prints 1 every time the player is hit
-- Timer:every(function() return player.grounded end, function() print(1), 5, function() print(2) end) -> prints 1 every time the player becomes grounded 5 times, and then prints 2
-- Note that if using this as a condition, the action will only be Timered when the condition jumps from being false to true.
-- If the condition remains true for multiple frames then the action won't be Timered further, unless it becomes false and then becomes true again.
function AnimateTimer:every(delay, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or UUID()
  if type(delay) == "number" or type(delay) == "table" then
    self.Timers[tag] = {type = "every", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, times = times, max_times = times, after = after, multiplier = 1}
  else
    self.Timers[tag] = {type = "conditional_every", condition = delay, last_condition = false, action = action, times = times, max_times = times, after = after}
  end
end


-- Same as every except the action is called immediately when this function is called, and then every delay seconds.
function AnimateTimer:every_immediate(delay, action, times, after, tag)
  local times = times or 0
  local after = after or function() end
  local tag = tag or UUID()
  self.Timers[tag] = {type = "every", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, times = times, max_times = times, after = after, multiplier = 1}
  action()
end


-- Calls the action every frame for delay seconds.
-- Or calls the action every frame the condition is true.
-- If after is passed in then it is called after the duration ends or after the condition becomes false.
-- If tag is passed in then any other Timer actions with the same tag are automatically cancelled.
-- Timer:during(5, function() print(random:float(0, 100)) end)
-- Timer:during(function() return self.should_print_random_float end, function() print(random:float(0, 100)) end) -> prints the random float as long as self.should_print_random_float is true
function AnimateTimer:during(delay, action, after, tag)
  local after = after or function() end
  local tag = tag or UUID()
  if type(delay) == "number" or type(delay) == "table" then
    self.Timers[tag] = {type = "during", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), action = action, after = after}
  elseif type(delay) == "function" then
    self.Timers[tag] = {type = "conditional_during", condition = delay, last_condition = false, action = action, after = after}
  end
end


-- Tweens the target's values specified by the source table for delay seconds using the given tweening method.
-- All tween methods can be found in the math/math file.
-- If after is passed in then it is called after the duration ends.
-- If tag is passed in then any other Timer actions with the same tag are automatically cancelled.
-- Timer:tween(0.2, self, {sx = 0, sy = 0}, math.linear) -> tweens this object's scale variables to 0 linearly over 0.2 seconds
-- Timer:tween(0.2, self, {sx = 0, sy = 0}, math.linear, function() self.dead = true end) -> tweens this object's scale variables to 0 linearly over 0.2 seconds and then kills it
function AnimateTimer:tween(delay, target, source, method, after, tag)
  local method = method or AnimateTimer.linear
  local after = after or function() end
  local tag = tag or UUID()
  local initial_values = {}
  for k, _ in pairs(source) do initial_values[k] = target[k] end
  self.Timers[tag] = {type = "tween", timer = 0, unresolved_delay = delay, delay = self:resolve_delay(delay), target = target, initial_values = initial_values, source = source, method = method, after = after}
end


-- Cancels a Timer action based on its tag.
-- This is automatically called if repeated tags are given to Timer actions.
function AnimateTimer:cancel(tag)
  if self.Timers[tag] and self.Timers[tag].type == "run" then
    self.Timers[tag].after()
  end
  self.Timers[tag] = nil
end


-- Resets the timer for a tag.
-- Useful when you need to start counting that tag from 0 after an event happens.
function AnimateTimer:reset(tag)
  self.Timers[tag].timer = 0
end


-- Returns the delay of a given tag.
-- This is useful when delays are set randomly (Timer:every({2, 4}, ...) would set the delay at a random number between 2 and 4) and you need to know what the value chosen was.
function AnimateTimer:get_delay(tag)
  return self.Timers[tag].delay
end


-- Returns the current iteration of an every Timer action with the given tag.
-- Useful if you need to know that its the nth time an every action has been called.
function AnimateTimer:get_every_iteration(tag)
  return self.Timers[tag].max_times - self.Timers[tag].times 
end


-- Sets a multiplier for an every tag.
-- This is useful when you need the event to happen in a varying interval, like based on the player's attack speed, which might change every frame based on buffs.
-- Call this on the update function with the appropriate multiplier.
function AnimateTimer:set_every_multiplier(tag, multiplier)
  if not self.Timers[tag] then return end
  self.Timers[tag].multiplier = multiplier or 1
end


function AnimateTimer:get_every_multiplier(tag)
  if not self.Timers[tag] then return end
  return self.Timers[tag].multiplier
end


-- Returns the elapsed time of a given Timer as a number between 0 and 1.
-- Useful if you need to know where you currently are in the duration of a during call.
function AnimateTimer:get_during_elapsed_time(tag)
  if not self.Timers[tag] then return end
  return self.Timers[tag].timer/self.Timers[tag].delay
end


function AnimateTimer:get_timer_and_delay(tag)
  if not self.Timers[tag] then return end
  return self.Timers[tag].timer, self.Timers[tag].delay
end


function AnimateTimer:get_time()
  self.time = love.timer.getTime()
  return self.time
end


function AnimateTimer:resolve_delay(delay)
  if type(delay) == "table" then
    return random_float(delay[1], delay[2])
  else
    return delay
  end
end


function AnimateTimer:destroy()
  self.Timers = nil
end


function AnimateTimer:update(dt)
  self.time = self.time + dt

  for tag, Timer in pairs(self.Timers) do
    if Timer.timer then
      Timer.timer = Timer.timer + dt
    end

    if Timer.type == "run" then
      Timer.action()

    elseif Timer.type == "cooldown" then
      if Timer.timer > Timer.delay*Timer.multiplier and Timer.condition() then
        Timer.action()
        Timer.timer = 0
        Timer.delay = self:resolve_delay(Timer.unresolved_delay)
        if Timer.times > 0 then
          Timer.times = Timer.times - 1
          if Timer.times <= 0 then
            Timer.after()
            self.Timers[tag] = nil
          end
        end
      end

    elseif Timer.type == "after" then
      if Timer.timer > Timer.delay then
        Timer.action()
        self.Timers[tag] = nil
      end

    elseif Timer.type == "conditional_after" then
      if Timer.condition() then
        Timer.action()
        self.Timers[tag] = nil
      end

    elseif Timer.type == "every" then
      if Timer.timer > Timer.delay*Timer.multiplier then
        Timer.action()
        Timer.timer = Timer.timer - Timer.delay*Timer.multiplier
        Timer.delay = self:resolve_delay(Timer.unresolved_delay)
        if Timer.times > 0 then
          Timer.times = Timer.times - 1
          if Timer.times <= 0 then
            Timer.after()
            self.Timers[tag] = nil
          end
        end
      end

    elseif Timer.type == "conditional_every" then
      local condition = Timer.condition()
      if condition and not Timer.last_condition then
        Timer.action()
        if Timer.times > 0 then
          Timer.times = Timer.times - 1
          if Timer.times <= 0 then
            Timer.after()
            self.Timers[tag] = nil
          end
        end
      end
      Timer.last_condition = condition

    elseif Timer.type == "during" then
      Timer.action(dt)
      if Timer.timer > Timer.delay then
        Timer.after()
        self.Timers[tag] = nil
      end

    elseif Timer.type == "conditional_during" then
      local condition = Timer.condition()
      if condition then
        Timer.action()
      end
      if Timer.last_condition and not condition then
        Timer.after()
      end
      Timer.last_condition = condition

    elseif Timer.type == "tween" then
      local t = Timer.method(Timer.timer/Timer.delay)
      for k, v in pairs(Timer.source) do
        Timer.target[k] = AnimateTimer.lerp(t, Timer.initial_values[k], v)
      end
      if Timer.timer > Timer.delay then
        Timer.after()
        self.Timers[tag] = nil
      end
    end
  end
end

return AnimateTimer
