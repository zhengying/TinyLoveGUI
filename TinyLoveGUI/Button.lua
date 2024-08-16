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
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType  
local InputEvent = InputEventUtils.InputEvent


-- Button: A clickable GUI element
local Button = GUIElement:extend()

---@class ButtonOptions
---@field mode? string
---@field text? string
---@field font? love.Font
---@field textColor? table
---@field normalColor? table
---@field hoverColor? table
---@field pressedColor? table
---@field normalImage? love.Image
---@field hoverImage? love.Image
---@field pressedImage? love.Image
---@field onClick? function

---@param x number
---@param y number
---@param width number
---@param height number
---@param options? ButtonOptions
function Button:init(x, y, width, height, options)
    Button.super.init(self, x, y, width, height)
    self.options = options or {}
    self.mode = self.options.mode or "simple"
    self.text = self.options.text or ""
    self.font = self.options.font or love.graphics.getFont()
    self.textColor = self.options.textColor or {1, 1, 1, 1}
    
    if self.mode == "simple" then
        self.colors = {
            [GUIElement.State.NORMAL] = self.options.normalColor or {0.5, 0.5, 0.5, 1},
            [GUIElement.State.HOVER] = self.options.hoverColor or {0.7, 0.7, 0.7, 1},
            [GUIElement.State.PRESSED] = self.options.pressedColor or {0.3, 0.3, 0.3, 1}
        }
    elseif self.mode == "image" then
        self.images = {
            [GUIElement.State.NORMAL] = self.options.normalImage,
            [GUIElement.State.HOVER] = self.options.hoverImage,
            [GUIElement.State.PRESSED] = self.options.pressedImage
        }
        self.imageColors = {
            [GUIElement.State.NORMAL] = {1, 1, 1, 1},
            [GUIElement.State.HOVER] = {0.8, 0.8, 0.8, 1},
            [GUIElement.State.PRESSED] = {0.6, 0.6, 0.6, 1}
        }
    end

    self.tag = 'Button'
    
    self.onClick = self.options.onClick or function() end
end

function Button:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    if self.mode == "simple" then
        love.graphics.setColor(unpack(self.colors[self.state]))
        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    elseif self.mode == "image" then
        local image = self.images[self.state] or self.images[GUIElement.State.NORMAL]
        if image then
            love.graphics.setColor(unpack(self.imageColors[self.state]))
            love.graphics.draw(image, 0, 0, 0, self.width / image:getWidth(), self.height / image:getHeight())
        end
    end
    
    love.graphics.setColor(unpack(self.textColor))
    local textWidth = self.font:getWidth(self.text)
    local textHeight = self.font:getHeight()
    love.graphics.print(self.text, self.width/2 - textWidth/2, self.height/2 - textHeight/2)
    
    love.graphics.pop()
end

function Button:onInput(event)
    if event.type == EventType.MOUSE_PRESSED then
        return self:handlePress(event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_RELEASED then
        return self:handleRelease(event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.TOUCH_PRESSED then
        return self:handlePress(event.data.x, event.data.y)
    elseif event.type == EventType.TOUCH_RELEASED then
        return self:handleRelease(event.data.x, event.data.y)
    elseif event.type == EventType.KEY_PRESSED and self:isFocused() then
        return self:handleKeyPress(event.data.key)
    end
    return false
end


function Button:handlePress(x, y, button)
    if button and button ~= 1 then return false end  -- Only handle left mouse button
    self:_stateChanged(GUIElement.State.PRESSED)
    return true
end

function Button:handleRelease(x, y, button)
    if button and button ~= 1 then return false end  -- Only handle left mouse button
    if self.state == GUIElement.State.PRESSED then
        self:_stateChanged(GUIElement.State.HOVER)
        self.onClick()
    end
    return true
end

function Button:handleKeyPress(key)
    if key == "return" or key == "space" then
        self:_stateChanged(GUIElement.State.PRESSED)
        self.onClick()
        self:_stateChanged(GUIElement.State.NORMAL)
        return true
    end
    return false
end

-- You can keep this method for backwards compatibility if needed
function Button:onMousepressed(x, y, button)
    return self:handlePress(x, y, button)
end


return Button