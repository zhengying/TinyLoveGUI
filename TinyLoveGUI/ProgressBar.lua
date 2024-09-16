--[[
    Copyright (c) 2024 ZhengYing

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]
local cwd = select(1, ...):match(".+%.") or "" 
local GUIElement = require(cwd .. "GUIElement")

-- ProgressBar: A control for displaying progress
local ProgressBar = GUIElement:extend()

function ProgressBar:init(options)
    ProgressBar.super.init(self, options)
    self.value = options.value or 0
    self.max = options.max or 100
    self.color = options.color or {0.2, 0.6, 1} -- Default to a light blue color
    self.backgroundColor = options.backgroundColor or {0.8, 0.8, 0.8} -- Light gray background
    self.borderColor = options.borderColor or {0.5, 0.5, 0.5} -- Medium gray border
end

function ProgressBar:draw()
    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw progress
    local progressWidth = (self.value / self.max) * self.width
    love.graphics.setColor(unpack(self.color))
    love.graphics.rectangle("fill", self.x, self.y, progressWidth, self.height)
    
    -- Draw border
    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    
    -- Optionally, draw text showing the percentage
    love.graphics.setColor(0, 0, 0)
    local percentage = math.floor((self.value / self.max) * 100)
    love.graphics.printf(percentage .. "%", 0, self.height / 2 - love.graphics.getFont():getHeight() / 2, self.width, "center")
end

function ProgressBar:setValue(value)
    self.value = math.max(0, math.min(value, self.max))
end

function ProgressBar:setMax(max)
    self.max = max
    self.value = math.min(self.value, self.max)
end

function ProgressBar:setColor(color)
    self.color = color
end

function ProgressBar:setBackgroundColor(color)
    self.backgroundColor = color
end

function ProgressBar:setBorderColor(color)
    self.borderColor = color
end

function ProgressBar:getPercentage()
    return (self.value / self.max) * 100
end

return ProgressBar