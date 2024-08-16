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

-- PopupMessage
local PopupMessage = GUIElement:extend()

function PopupMessage:init(x, y, width, height, message, duration)
    PopupMessage.super.init(self, x, y, width, height)
    self.message = message or "Popup Message"
    self.duration = duration or 2  -- Default duration of 3 seconds
    self.timeLeft = self.duration
    self.backgroundColor = {r=0.2, g=0.2, b=0.2, a=0.8}
    self.textColor = {r=1, g=1, b=1, a=1}
    self.padding = 10
    self.fontSize = 16
    self.font = love.graphics.newFont(self.fontSize)
    self.tag = "PopupMessage"
    self.zIndex = GUIElement.ZIndexGroup.POPUP --GUIElement.ZIndexGroup.Popup
end

function PopupMessage:update(dt)
    self.timeLeft = self.timeLeft - dt
    if self.timeLeft <= 0 then
        -- Remove self from parent when time is up
        if self.parent then
            self.parent:removeChild(self)
        end
    end
end

function PopupMessage:draw()
    love.graphics.push("all")
    love.graphics.translate(self.x, self.y)

    -- Draw background
    love.graphics.setColor(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, self.backgroundColor.a)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 5, 5)  -- Rounded corners

    -- Draw text
    love.graphics.setColor(self.textColor.r, self.textColor.g, self.textColor.b, self.textColor.a)
    love.graphics.setFont(self.font)
    love.graphics.printf(self.message, self.padding, self.height/2 - self.fontSize/2, self.width - 2*self.padding, "center")

    love.graphics.pop()
end

-- Static method to create and add a popup to a parent element
function PopupMessage.show(parent, message, duration, width, height)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    width = width or 200
    height = height or 50
    local x = (screenWidth - width) / 2
    local y = screenHeight - height - 20  -- 20 pixels from the bottom

    local popup = PopupMessage(x, y, width, height, message, duration)
    parent:addChild(popup)
    return popup
end

return PopupMessage