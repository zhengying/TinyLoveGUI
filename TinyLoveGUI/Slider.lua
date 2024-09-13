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
local TooltipsMixin = require(cwd .. "TooltipsMixin")
local GUIContext = require(cwd .. "GUIContext")

-- Slider
local Slider = GUIElement:extend()
Slider:implement(TooltipsMixin)

function Slider:init(x, y, width, height, min, max, value)
    Slider.super.init(self, x, y, width, height)
    self.min = min or 0
    self.max = max or 100
    self.value = value or self.min
    self.onChange = function(value) end
    self.dragging = false
    self.tag = 'Slider'

    -- Local helper function
    local function updateValue(slider, x)
        local newValue = slider.min + (x / slider.width) * (slider.max - slider.min)
        slider.value = math.max(slider.min, math.min(slider.max, newValue))
        slider.onChange(slider.value)
    end

    -- Local event handler functions
    local function handlePress(slider, x, y, button)
        if button == 1 then  -- Left mouse button
            slider.dragging = true
            updateValue(slider, x - slider.x)
            return true
        end
        return false
    end

    local function handleMove(slider, x, y, dx, dy)
        if slider.dragging then
            updateValue(slider, x - slider.x)
            return true
        end
        return false
    end

    local function handleRelease(slider, x, y, button)
        if button == 1 then  -- Left mouse button
            slider.dragging = false
            return true
        end
        return false
    end

    -- Modify handleInput to use local functions
    self.handleInput = function(slider, event)
        if Slider.super.handleInput(slider, event) then
            return true
        end

        if event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED then
            return handlePress(slider, event.data.x, event.data.y, event.data.button)
        elseif event.type == EventType.MOUSE_MOVED or event.type == EventType.TOUCH_MOVED then
            return handleMove(slider, event.data.x, event.data.y, event.data.dx, event.data.dy)
        elseif event.type == EventType.MOUSE_RELEASED or event.type == EventType.TOUCH_RELEASED then
            return handleRelease(slider, event.data.x, event.data.y, event.data.button)
        end
        return false
    end
end

function Slider:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", 0, self.height / 2 - 2, self.width, 4)
    local knobX = (self.value - self.min) / (self.max - self.min) * self.width
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.circle("fill", knobX, self.height / 2, 8)
    
    love.graphics.pop()
end

function Slider:onAddToContext()
    self.context:registerLocalEvent(GUIContext.LocalEvents.HIGHLIGHT_CHANGED,self,self.onHighlightChanged,nil)
end

function Slider:onHighlightChanged(element)
    if element ~= self then
        self.dragging = false
    end
end

function Slider:onFocusGained()
    -- Override this method in subclasses to handle gaining focus
end

function Slider:onFocusLost()
    -- Override this method in subclasses to handle losing focus
    self.dragging = false
end


return Slider