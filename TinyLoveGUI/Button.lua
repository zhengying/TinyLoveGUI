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
local GUIContext = require(cwd .. "GUIContext")
local PopupWindow = require(cwd .. "PopupWindow")
local TooltipsMixin = require(cwd .. "TooltipsMixin")


-- Button: A clickable GUI element
local Button = GUIElement:extend()
Button:implement(TooltipsMixin)

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
---@field tooltips_enabled? boolean
---@field tooltips_text? string
---@param x number
---@param y number
---@param width number
---@param height number
---@param options? ButtonOptions
function Button:init(x, y, width, height, options)
    Button.super.init(self, x, y, width, height)
    self.options = options or {}
    TooltipsMixin.TooltipsMixin_init(self, options)
    self.mode = self.options.mode or "simple"
    self.text = self.options.text or ""
    self.font = self.options.font or love.graphics.getFont()
    self.textColor = self.options.textColor or {1, 1, 1, 1}
    self.highligtable = true
    
    if self.mode == "simple" then
        self.colors = {
            [GUIContext.State.NORMAL] = self.options.normalColor or {0.5, 0.5, 0.5, 1},
            [GUIContext.State.HOVER] = self.options.hoverColor or {0.7, 0.7, 0.7, 1},
            [GUIContext.State.PRESSED] = self.options.pressedColor or {0.3, 0.3, 0.3, 1}
        }
    elseif self.mode == "image" then
        self.images = {
            [GUIContext.State.NORMAL] = self.options.normalImage,
            [GUIContext.State.HOVER] = self.options.hoverImage,
            [GUIContext.State.PRESSED] = self.options.pressedImage
        }
        self.imageColors = {
            [GUIContext.State.NORMAL] = {1, 1, 1, 1},
            [GUIContext.State.HOVER] = {0.8, 0.8, 0.8, 1},
            [GUIContext.State.PRESSED] = {0.6, 0.6, 0.6, 1}
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
        local image = self.images[self.state] or self.images[GUIContext.State.NORMAL]
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

local function handlePress(self, x, y, button)
    if button and button ~= 1 then return false end  -- Only handle left mouse button
    self:_stateChanged(GUIContext.State.PRESSED)
    return true
end

local function handleRelease(self, x, y, button)
    if button and button ~= 1 then return false end  -- Only handle left mouse button
    if self.state == GUIContext.State.PRESSED then
        self:_stateChanged(GUIContext.State.HOVER)
        self.onClick()
    end
    return true
end

-- local function handleHover(self, x, y)
--     self:_stateChanged(GUIContext.State.HOVER)
--     -- if self.tooltips_enabled then
--     --     self:showTooltip()
--     -- end
--     return true
-- end

local function handleKeyPress(self, key)
    if key == "return" or key == "space" then
        self:_stateChanged(GUIContext.State.PRESSED)
        self.onClick()
        self:_stateChanged(GUIContext.State.NORMAL)
        return true
    end
    return false
end

function Button:onPointerEnter()
    print('Button:'..self.options.text ..' onPointerEnter')
    self:_stateChanged(GUIContext.State.HOVER)
    return true
end

function Button:onPointerLeave()
        print('Button:'..self.options.text ..' onPointerLeave')
    self:_stateChanged(GUIContext.State.NORMAL)
    return true
end

-- local function handleHover(self,x, y)
--     self.context:setHighlight(self)
--     self:_stateChanged(GUIContext.State.HOVER)
--     return true
-- end

function Button:onInput(event)
    if event.type == EventType.MOUSE_PRESSED then
        return handlePress(self, event.data.x, event.data.y, event.data.button)  
    elseif event.type == EventType.MOUSE_RELEASED then
        return handleRelease(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.TOUCH_PRESSED then
        return handlePress(self, event.data.x, event.data.y)
    elseif event.type == EventType.TOUCH_RELEASED then
        return handleRelease(self, event.data.x, event.data.y)
    -- elseif event.type == EventType.MOUSE_MOVED then
    --     return handleHover(self, event.data.x, event.data.y)    
    elseif event.type == EventType.KEY_PRESSED and self:isFocused() then
        return handleKeyPress(self, event.data.key)
    end
    return false
end


-- -- You can keep this method for backwards compatibility if needed
-- function Button:onMousepressed(x, y, button)
--     return self:handlePress(x, y, button)
-- end


return Button