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
-- OptionSelect: A control for selecting one option from a list
local cwd = select(1, ...):match(".+%.") or ""
local GUIElement = require(cwd .. "GUIElement")
local OptionSelect = GUIElement:extend()
local GUIContext = require(cwd .. "GUIContext")

local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType    
local InputEvent = InputEventUtils.InputEvent
local TooltipsMixin = require(cwd .. "TooltipsMixin")

OptionSelect:implement(TooltipsMixin)

function OptionSelect:init(x, y, width, height, options, defaultOption)
    OptionSelect.super.init(self, x, y, width, height)
    self.options = options or {}
    self.selectedOption = defaultOption or (options and options[1]) or nil
    self.selectedIndex = defaultOption and table.indexof(options, defaultOption) or 1
    self.isOpen = false
    self.hoverIndex = nil
    self.itemHeight = 30  -- Height of each option item
    self.maxVisibleItems = 5  -- Maximum number of visible items when dropdown is open
    self.scrollOffset = 0  -- New: Scroll offset for the list
    self.scrollbarWidth = 10  -- New: Width of the scrollbar
    -- Default Z-index is already set in GUIElement:new()
    self.tag = 'OptionSelect'
    self.highligtable = true

    TooltipsMixin.TooltipsMixin_init(self, options)
end

function OptionSelect:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    self:drawSelf()
    love.graphics.pop()
end

function OptionSelect:drawSelf()
    -- Draw the main control
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    
    -- Draw the selected option
    if self.selectedOption then
        love.graphics.printf(self.selectedOption, 5, self.height / 2 - love.graphics.getFont():getHeight() / 2, self.width - 30, "left")
    end
    
    -- Draw the dropdown arrow
    love.graphics.polygon("fill", self.width - 20, self.height / 2 - 5, self.width - 10, self.height / 2 - 5, self.width - 15, self.height / 2 + 5)
    
    if self.isOpen then
        local visibleItems = math.min(#self.options, self.maxVisibleItems)
        local dropdownHeight = visibleItems * self.itemHeight
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, self.height, self.width, dropdownHeight)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", 0, self.height, self.width, dropdownHeight)
        
        -- Set scissor to clip content
        love.graphics.setScissor(self.x, self.y + self.height, self.width, dropdownHeight)
        
        for i = 1, #self.options do
            local y = self.height + (i - 1 - self.scrollOffset) * self.itemHeight
            if y >= self.height and y < self.height + dropdownHeight then
                if i == self.hoverIndex then
                    love.graphics.setColor(0.9, 0.9, 0.9)
                    love.graphics.rectangle("fill", 0, y, self.width - self.scrollbarWidth, self.itemHeight)
                end
                love.graphics.setColor(0, 0, 0)
                love.graphics.printf(self.options[i], 5, y + self.itemHeight / 2 - love.graphics.getFont():getHeight() / 2, self.width - 15 - self.scrollbarWidth, "left")
            end
        end
        
        love.graphics.setScissor()
        
        -- Draw scrollbar if necessary
                -- Draw scrollbar if necessary
        if #self.options > self.maxVisibleItems then
            local scrollbarHeight = (self.maxVisibleItems / #self.options) * dropdownHeight
            local scrollbarY = self.height + (self.scrollOffset / (#self.options - self.maxVisibleItems)) * (dropdownHeight - scrollbarHeight)
            
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.rectangle("fill", self.width - self.scrollbarWidth, self.height, self.scrollbarWidth, dropdownHeight)
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", self.width - self.scrollbarWidth, scrollbarY, self.scrollbarWidth, scrollbarHeight)
        end
    end
end

local function handlePress(self, x, y, button)      
    
    if self:containsPoint(x, y) then
        if button == 1 then  -- Left mouse button
            if y < self.height then
                self.isOpen = not self.isOpen
                if self.isOpen then
                    self:setZIndex(GUIContext.ZIndexGroup.POPUP)
                else
                    self:setZIndex(GUIContext.ZIndexGroup.NORMAL)
                end
            elseif self.isOpen then
                if  x > self.width - self.scrollbarWidth and #self.options > self.maxVisibleItems then
                    self.isDraggingScrollbar = true
                    self:updateScrollFromMouseY(y) 
                else
                    local index = math.floor((y - self.height) / self.itemHeight) + 1 + self.scrollOffset
                    if index > 0 and index <= #self.options then
                        self.selectedOption = self.options[index]
                        self.selectedIndex = index
                        self.isOpen = false
                        self:setZIndex(GUIContext.ZIndexGroup.NORMAL)
                        if self.onChange then
                            self.onChange(self.selectedOption, self.selectedIndex)
                        end
                    end
                end
            end
            return true
        end
    elseif self.isOpen then
        self.isOpen = false
        self:setZIndex(GUIContext.ZIndexGroup.NORMAL)
        return true
    end
    
    return false
end

local function handleMove(self, x, y, dx, dy)

    if self.isOpen and self:containsPoint(x, y) then
        if self.isDraggingScrollbar then
            self:updateScrollFromMouseY(y)
            return true
        elseif y > self.height then
            self.hoverIndex = math.floor((y - self.height) / self.itemHeight) + 1 + self.scrollOffset
            if self.hoverIndex > #self.options then
                self.hoverIndex = nil
            end
        else
            self.hoverIndex = nil
        end
        return true
    end
    
    return false
end

local function handleRelease(self, x, y, button)
    if button == 1 and self.isDraggingScrollbar then
        self.isDraggingScrollbar = false
        return true
    end
    return false
end

local function handleWheel(self, dx, dy)
    if self.isOpen and #self.options > self.maxVisibleItems then
        self.scrollOffset = math.max(0, math.min(self.scrollOffset - dy, #self.options - self.maxVisibleItems))
        return true
    end
    return false
end

local function handleKeyPress(self, key)
    if self.isOpen then
        if key == "up" then
            self.hoverIndex = math.max(1, (self.hoverIndex or self.selectedIndex) - 1)
            self:ensureHoverIndexVisible()
            return true
        elseif key == "down" then
            self.hoverIndex = math.min(#self.options, (self.hoverIndex or self.selectedIndex) + 1)
            self:ensureHoverIndexVisible()
            return true
        elseif key == "return" then
            if self.hoverIndex then
                self.selectedOption = self.options[self.hoverIndex]
                self.selectedIndex = self.hoverIndex
                self.isOpen = false
                self:setZIndex(GUIElement.ZIndexGroup.NORMAL)
                if self.onChange then
                    self.onChange(self.selectedOption, self.selectedIndex)
                end
            end
            return true
        elseif key == "escape" then
            self.isOpen = false
            self:setZIndex(GUIElement.ZIndexGroup.NORMAL)
            return true
        end
    else
        if key == "return" or key == "space" then
            self.isOpen = true
            self:setZIndex(GUIElement.ZIndexGroup.POPUP)
            return true
        end
    end
    return false
end

function OptionSelect:handleInput(event)
    if event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED then
        return handlePress(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_MOVED or event.type == EventType.TOUCH_MOVED then
        return handleMove(self, event.data.x, event.data.y, event.data.dx, event.data.dy)
    elseif event.type == EventType.MOUSE_RELEASED or event.type == EventType.TOUCH_RELEASED then
        return handleRelease(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.WHEEL_MOVED then
        return handleWheel(self, event.data.dx, event.data.dy)
    elseif event.type == EventType.KEY_PRESSED and self:isFocused() then
        return handleKeyPress(self, event.data.key)
    end
    return false
end

function OptionSelect:ensureHoverIndexVisible()
    if self.hoverIndex <= self.scrollOffset then
        self.scrollOffset = self.hoverIndex - 1
    elseif self.hoverIndex > self.scrollOffset + self.maxVisibleItems then
        self.scrollOffset = self.hoverIndex - self.maxVisibleItems
    end
end

function OptionSelect:isPointInside(x, y)
    return self:containsPoint(x-self.x, y-self.y)
end

function OptionSelect:containsPoint(x, y)
    if not self.isOpen then
        return x >= 0 and x < self.width and y >= 0 and y < self.height
    else
        local dropdownHeight = math.min(#self.options, self.maxVisibleItems) * self.itemHeight
        return x >= 0 and x < self.width and y >= 0 and y < self.height + dropdownHeight
    end
end

function OptionSelect:updateScrollFromMouseY(localY)
    local dropdownHeight = math.min(#self.options, self.maxVisibleItems) * self.itemHeight
    local scrollableHeight = dropdownHeight - self.height
    local scrollPosition = math.max(0, math.min(1, (localY - self.height) / scrollableHeight))
    self.scrollOffset = math.floor(scrollPosition * (#self.options - self.maxVisibleItems))
end


function OptionSelect:getSelectedOption()
    return self.selectedOption
end

function OptionSelect:setOptions(options, defaultOption)
    self.options = options
    self.selectedOption = defaultOption or options[1] or nil
    self.selectedIndex = defaultOption and table.indexof(options, defaultOption) or 1
end

return OptionSelect