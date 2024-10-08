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
local GUIContext = require(cwd .. "GUIContext")
local Utils = require(cwd .. "Utils")

-- PopupMessage
local PopupMessage = GUIElement:extend()

function PopupMessage:init(options) 
    PopupMessage.super.init(self, options)
    self.message = options.message or "Popup Message"
    self.duration = options.duration or 2  -- Default duration of 3 seconds
    self.timeLeft = self.duration
    self.backgroundColor = options.backgroundColor or {0.2, 0.2, 0.2, 0.8}
    self.textColor = options.textColor or {1, 1, 1, 1}
    self.padding = options.padding or 0
    self.fontSize = options.fontSize or 16
    self.font = options.font or love.graphics.newFont(self.fontSize)
    self.tag = "PopupMessage"
    self.zIndex = GUIContext.ZIndexGroup.POPUP --GUIElement.ZIndexGroup.Popup
    self.highligtable = false
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
    love.graphics.setColor(self.backgroundColor[1], self.backgroundColor[2], self.backgroundColor[3], self.backgroundColor[4])
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, 5, 5)  -- Rounded corners

    -- Draw text
    love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.textColor[4])
    love.graphics.setFont(self.font)
    love.graphics.printf(self.message, self.padding, self.height/2 - self.fontSize/2, self.width - 2*self.padding, "center")

    love.graphics.pop()
end

-- Static method to create and add a popup to a parent element
function PopupMessage.show(context, message, duration, width, height)
    local screenWidth, screenHeight = love.graphics.getDimensions()
    width = width or 200
    height = height or 50
    local x = (screenWidth - width) / 2
    local y = screenHeight - height - 20  -- 20 pixels from the bottom

    local popup = PopupMessage({x=x, y=y, width=width, height=height, message=message, duration=duration})
    -- popup = Utils.observable(popup, "timeLeft", function(key, oldValue, newValue)
    --     print("width changed to", newValue)
    -- end)
    context:addChild(popup)

    return popup
end

return PopupMessage