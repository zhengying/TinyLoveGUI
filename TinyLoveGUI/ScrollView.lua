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

local ScrollView = GUIElement:extend()

function ScrollView:init(x, y, width, height)
    ScrollView.super.init(self, x, y, width, height)
    self.offsetX = 0
    self.offsetY = 0
    self.contentWidth = width
    self.contentHeight = height
    self.scrollbarWidth = 10
    self.isDraggingVerticalScrollbar = false
    self.isDraggingHorizontalScrollbar = false
    self.scrollbarGrabOffset = 0
    self.scrollview = true
    self.tag = 'ScrollView'
    
end

function ScrollView:addChild(child)
    ScrollView.super.addChild(self, child)
    self:updateContentSize()
end


function ScrollView:updateContentSize()
    self.contentWidth = 0
    self.contentHeight = 0
    for _, child in ipairs(self.children) do
        self.contentWidth = math.max(self.contentWidth, child.x + child.width)
        self.contentHeight = math.max(self.contentHeight, child.y + child.height)
    end
end

function ScrollView:draw()
    if self.DEBUG_DRAW then
        love.graphics.setColor(0.5,0,1,1)
        love.graphics.rectangle("line",self.x,self.y,self.width, self.height)
        print('scrollview w:' .. tostring(self.width) .. "h:" .. tostring(self.height))
        print('scrollview cw:' .. tostring(self.contentWidth) .. "ch:" .. tostring(self.contentHeight))


        
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.setColor(1,0,1,1)

    local globalx, globaly = self:getGlobalPosition()
    if self.width > 0 and self.height > 0 then
        love.graphics.intersectScissor(self.x, self.y, self.width, self.height)
        love.graphics.push()
        love.graphics.translate(-self.offsetX, -self.offsetY)
        self:onDraw()
        for _, child in ipairs(self.children) do
            child:draw()
        end 
        love.graphics.pop()
        love.graphics.setScissor()
    else
        print("Warning: Invalid ScrollView dimensions. Skipping scissor.")
    end

    love.graphics.pop()

    self:drawScrollbars()
end

function ScrollView:onDraw()
    -- override this function to draw custom content
end

function ScrollView:drawScrollbars()
    -- Vertical scrollbar
    if self.contentHeight > self.height then
        local scrollbarHeight = self:getVerticalScrollbarHeight()
        local scrollbarY = self.y + (self.offsetY / (self.contentHeight - self.height)) * (self.height - scrollbarHeight)
        
        love.graphics.setColor(0.5, 0.5, 0.5) -- Gray color for scrollbar track
        love.graphics.rectangle("fill", self.x + self.width - self.scrollbarWidth, self.y, self.scrollbarWidth, self.height)
        love.graphics.setColor(0.7, 0.7, 0.7) -- Lighter gray for scrollbar
        love.graphics.rectangle("fill", self.x + self.width - self.scrollbarWidth, scrollbarY, self.scrollbarWidth, scrollbarHeight)
    end

    -- Horizontal scrollbar
    if self.contentWidth > self.width then
        local scrollbarWidth = self:getHorizontalScrollbarWidth()
        local scrollbarX = self.x + (self.offsetX / (self.contentWidth - self.width)) * (self.width - scrollbarWidth)
        
        love.graphics.setColor(0.5, 0.5, 0.5) -- Gray color for scrollbar track
        love.graphics.rectangle("fill", self.x, self.y + self.height - self.scrollbarWidth, self.width, self.scrollbarWidth)
        love.graphics.setColor(0.7, 0.7, 0.7) -- Lighter gray for scrollbar
        love.graphics.rectangle("fill", scrollbarX, self.y + self.height - self.scrollbarWidth, scrollbarWidth, self.scrollbarWidth)
    end

    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

function ScrollView:update(dt)
    ScrollView.super.update(self, dt)
    -- Add any scrollbar-specific update logic here if needed
end


local function handlePress(self,x, y, button)
    if button ~= 1 then return false end  -- Only handle left mouse button
    self.isDraggingVerticalScrollbar = false
    self.isDraggingHorizontalScrollbar = false  

    if self:isMouseOverVerticalScrollbar(x, y) then

        self.isDraggingVerticalScrollbar = true
        local scrollbarY = self.y + (self.offsetY / (self.contentHeight - self.height)) * (self.height - self:getVerticalScrollbarHeight())
        self.scrollbarGrabOffset = y - scrollbarY
        print("isMouseOverVerticalScrollbar" .. tostring(self.scrollbarGrabOffset))
        return true
    elseif self:isMouseOverHorizontalScrollbar(x, y) then
        self.isDraggingHorizontalScrollbar = true
        local scrollbarX = self.x + (self.offsetX / (self.contentWidth - self.width)) * (self.width - self:getHorizontalScrollbarWidth())
        self.scrollbarGrabOffset = x - scrollbarX
        return true
    elseif self:isMouseOverVerticalScrollbarTrack(x, y) then
        local clickPosition = (y - self.y) / self.height
        self:scrollVerticalTo((self.contentHeight - self.height) * clickPosition)
        return true
    elseif self:isMouseOverHorizontalScrollbarTrack(x, y) then
        local clickPosition = (x - self.x) / self.width
        self:scrollHorizontalTo((self.contentWidth - self.width) * clickPosition)
        return true
    end
    return false
end

local function handleMove(self, x, y, dx, dy)
    if self.context:checkKeyPress(GUIContext.keycodes.M1) then
        if self.isDraggingVerticalScrollbar then
            local scrollableHeight = self.contentHeight - self.height
            local scrollbarHeight = self:getVerticalScrollbarHeight()
            local maxScrollbarY = self.height - scrollbarHeight
            local newScrollbarY = y - self.y - self.scrollbarGrabOffset
            local scrollPercentage = newScrollbarY / maxScrollbarY
            self:scrollVerticalTo(scrollableHeight * scrollPercentage)
            return true
        elseif self.isDraggingHorizontalScrollbar then
            local scrollableWidth = self.contentWidth - self.width
            local scrollbarWidth = self:getHorizontalScrollbarWidth()
            local maxScrollbarX = self.width - scrollbarWidth
            local newScrollbarX = x - self.x - self.scrollbarGrabOffset
            local scrollPercentage = newScrollbarX / maxScrollbarX
            self:scrollHorizontalTo(scrollableWidth * scrollPercentage)
            return true
        end
    end
    return false
end

local function handleRelease(self, x, y, button)
    if button == 1 then  -- Left mouse button
        self.isDraggingVerticalScrollbar = false
        self.isDraggingHorizontalScrollbar = false
        return true
    end
    
    return false
end

local function handleWheel(self, dx, dy)
    local scrollSpeed = 50 -- Adjust this value to change scroll speed
    if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
        self:scrollHorizontalTo(self.offsetX - dx * scrollSpeed)
    else
        self:scrollVerticalTo(self.offsetY - dy * scrollSpeed)
    end
    return true
end

function ScrollView:handleInput(event)
    if ScrollView.super.handleInput(self, event) then
        return true
    end

    if event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED then
        return handlePress(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_MOVED or event.type == EventType.TOUCH_MOVED then
        return handleMove(self, event.data.x, event.data.y, event.data.dx, event.data.dy)
    elseif event.type == EventType.MOUSE_RELEASED or event.type == EventType.TOUCH_RELEASED then
        return handleRelease(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.WHEEL_MOVED then
        return handleWheel(self, event.data.dx, event.data.dy)
    end
    return false
end

function ScrollView:scrollVerticalTo(newOffsetY)
    self.offsetY = math.max(0, math.min(newOffsetY, self.contentHeight - self.height))
end

function ScrollView:scrollHorizontalTo(newOffsetX)
    self.offsetX = math.max(0, math.min(newOffsetX, self.contentWidth - self.width))
end

function ScrollView:isMouseOverVerticalScrollbar(x, y)
    if self.contentHeight <= self.height then return false end
    local scrollbarHeight = self:getVerticalScrollbarHeight()
    local scrollbarY = self.y + (self.offsetY / (self.contentHeight - self.height)) * (self.height - scrollbarHeight)
    return x >= self.x + self.width - self.scrollbarWidth and x <= self.x + self.width
       and y >= scrollbarY and y <= scrollbarY + scrollbarHeight
end

function ScrollView:isMouseOverHorizontalScrollbar(x, y)
    if self.contentWidth <= self.width then return false end
    local scrollbarWidth = self:getHorizontalScrollbarWidth()
    local scrollbarX = self.x + (self.offsetX / (self.contentWidth - self.width)) * (self.width - scrollbarWidth)
    return y >= self.y + self.height - self.scrollbarWidth and y <= self.y + self.height
       and x >= scrollbarX and x <= scrollbarX + scrollbarWidth
end

function ScrollView:isMouseOverVerticalScrollbarTrack(x, y)
    return x >= self.x + self.width - self.scrollbarWidth and x <= self.x + self.width
       and y >= self.y and y <= self.y + self.height
end

function ScrollView:isMouseOverHorizontalScrollbarTrack(x, y)
    return y >= self.y + self.height - self.scrollbarWidth and y <= self.y + self.height
       and x >= self.x and x <= self.x + self.width
end

function ScrollView:getVerticalScrollbarHeight()
    return (self.height / self.contentHeight) * self.height
end

function ScrollView:getHorizontalScrollbarWidth()
    return (self.width / self.contentWidth) * self.width
end

function ScrollView:updateScrollbars()
    self.contentWidth = math.max(self.contentWidth, self.width)
    self.contentHeight = math.max(self.contentHeight, self.height)
    
    -- Adjust offsets if they're out of bounds
    self.offsetX = math.min(self.offsetX, self.contentWidth - self.width)
    self.offsetY = math.min(self.offsetY, self.contentHeight - self.height)
    self.offsetX = math.max(self.offsetX, 0)
    self.offsetY = math.max(self.offsetY, 0)
end

return ScrollView