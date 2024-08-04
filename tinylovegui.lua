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

-- this object class from SNKRX (https://github.com/a327ex/SNKRX/blob/master/engine/game/object.lua)
local Object = {}
Object.__index = Object
function Object:init()
end
function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end
function Object:implement(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end
function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end
function Object:__tostring()
  return "Object"
end
function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:init(...)
  return obj
end

-- Helper function to split string into lines
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function table.indexof(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

---  START 
-- Base class for all GUI elements
local GUIElement = Object:extend()

GUIElement.ZIndexNames = {
    SHADOW = 'SHADOW',
    NORMAL = 'NORMAL',
    MODAL_WINDOW = 'MODAL_WINDOW',
    POPUP = 'POPUP'  -- Added for elements like dropdowns that should be on top
}

GUIElement.State = {
    NORMAL = "normal",
    HOVER = "hover",
    PRESSED = "pressed"
  }
  

-- Define zIndex groups
GUIElement.ZIndexGroups = {
    SHADOW = 10,
    NORMAL = 500,
    MODAL_WINDOW = 1000,
    POPUP = 2000  -- Added for elements like dropdowns that should be on top
}

GUIElement.focusedElement = nil

function GUIElement:init(x, y, width, height)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 100
    self.children = {}
    self.parent = nil
    self.visible = true
    self.enabled = true
    self.zIndex = GUIElement.ZIndexGroups.NORMAL
    self.zIndexOffset = 0
    self.focusable = false
    self.focused = false
    self.tag = ""

    -- Scrolling properties
    self.scrollOffset = {x = 0, y = 0}
    self.scrollSpeed = 20
    self.scrollBarWidth = 10
    self.scrollBarVisible = {x = false, y = false}
    self.scrollBarGrabbed = {x = false, y = false}
    self.scrollBarClickOffset = {x = 0, y = 0}
    self.scrollBarEnable = false
    self.state = GUIElement.State.NORMAL
end

function GUIElement:updateScrollBars()
    local contentWidth, contentHeight = self:getContentDimensions()

    self.scrollBarVisible.x = contentWidth > self.width
    self.scrollBarVisible.y = contentHeight > self.height

    if self.scrollBarVisible.x then
        local maxScrollX = contentWidth - self.width
        self.scrollOffset.x = math.min(self.scrollOffset.x, maxScrollX)
    else
        self.scrollOffset.x = 0
    end

    if self.scrollBarVisible.y then
        local maxScrollY = contentHeight - self.height
        self.scrollOffset.y = math.min(self.scrollOffset.y, maxScrollY)
    else
        self.scrollOffset.y = 0
    end
end

function GUIElement:getContentDimensions()
    local maxWidth, maxHeight = 0, 0
    for _, child in ipairs(self.children) do
        maxWidth = math.max(maxWidth, child.x + child.width)
        maxHeight = math.max(maxHeight, child.y + child.height)
    end
    return maxWidth, maxHeight
end

function GUIElement:draw()
    if not self.visible then return end

    table.sort(self.children, function(a, b)
        return a:getZIndex() < b:getZIndex()
    end)

    
    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    if self.scrollBarEnable then
        if GUIElement.focusedElement == nil then
            self.focusable = true
            self.focused = true
            GUIElement.focusedElement = self
        end
        -- Set scissor to clip content
        local scissorX, scissorY = self:getGlobalPosition()
        love.graphics.setScissor(scissorX, scissorY, self.width, self.height)

        -- Draw self and children
        love.graphics.push()
        love.graphics.translate(-self.scrollOffset.x, -self.scrollOffset.y)
        self:drawSelf()
        for _, child in ipairs(self.children) do
            child:draw()
        end
        love.graphics.pop()

        love.graphics.setScissor()

        -- Draw scroll bars
        self:drawScrollBars()
    else
        self:drawSelf()
        for _, child in ipairs(self.children) do
            child:draw()
        end
    end

    love.graphics.pop()
end

function GUIElement:drawScrollBars()
    if self.scrollBarVisible.y then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", self.width - self.scrollBarWidth, 0, self.scrollBarWidth, self.height)
        
        local contentHeight = select(2, self:getContentDimensions())
        local scrollBarHeight = (self.height / contentHeight) * self.height
        local scrollBarY = (self.scrollOffset.y / (contentHeight - self.height)) * (self.height - scrollBarHeight)
        
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", self.width - self.scrollBarWidth, scrollBarY, self.scrollBarWidth, scrollBarHeight)
    end

    if self.scrollBarVisible.x then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", 0, self.height - self.scrollBarWidth, self.width, self.scrollBarWidth)
        
        local contentWidth = select(1, self:getContentDimensions())
        local scrollBarWidth = (self.width / contentWidth) * self.width
        local scrollBarX = (self.scrollOffset.x / (contentWidth - self.width)) * (self.width - scrollBarWidth)
        
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", scrollBarX, self.height - self.scrollBarWidth, scrollBarWidth, self.scrollBarWidth)
    end
end

function GUIElement:update(dt)
    if not self.enabled then return end

    -- Check if the focused element is still valid
    if self.parent == nil then
        if GUIElement.focusedElement and not GUIElement.focusedElement.visible then
            GUIElement.focusedElement:unsetFocus()
        end
    end

    if self.scrollBarEnable then
        self:updateScrollBars()
    end
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

-- Add new methods for focus handling
function GUIElement:setFocus()
    if GUIElement.focusedElement ~= self then
        if GUIElement.focusedElement then
            GUIElement.focusedElement:unsetFocus()
        end
        GUIElement.focusedElement = self
        self.focused = true
        self:onFocusGained()
    end
end

function GUIElement:unsetFocus()
    if GUIElement.focusedElement == self then
        GUIElement.focusedElement = nil
        self.focused = false
        self:onFocusLost()
    end
end

function GUIElement:_stateChanged(new_state)
    if new_state == nil or self.state == nil then
        print('! new state is nil')
    end
    if self.state ~= new_state then
        print("tag:"..self.tag .. " state changed:" .. self.state .. '~>' .. new_state)
    end

    self.state = new_state
end

function GUIElement:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    local localX, localY = x - self.x + self.scrollOffset.x, y - self.y + self.scrollOffset.y

    if self.scrollBarEnable then
        if button == 1 then
            if self.scrollBarVisible.y and x > self.width - self.scrollBarWidth then
                self.scrollBarGrabbed.y = true
                local contentHeight = select(2, self:getContentDimensions())
                local scrollBarHeight = (self.height / contentHeight) * self.height
                local scrollBarY = (self.scrollOffset.y / (contentHeight - self.height)) * (self.height - scrollBarHeight)
                self.scrollBarClickOffset.y = y - scrollBarY
                return true
            elseif self.scrollBarVisible.x and y > self.height - self.scrollBarWidth then
                self.scrollBarGrabbed.x = true
                local contentWidth = select(1, self:getContentDimensions())
                local scrollBarWidth = (self.width / contentWidth) * self.width
                local scrollBarX = (self.scrollOffset.x / (contentWidth - self.width)) * (self.width - scrollBarWidth)
                self.scrollBarClickOffset.x = x - scrollBarX
                return true
            end
        end
    end

    if self:containsPoint(localX, localY) then
        -- Set focus to this element if it's clickable
        if self.focusable then
            self:setFocus()
        end

        for i = #self.children, 1, -1 do
            if self.children[i]:mousepressed(localX, localY, button) then
                return true
            end
        end
        self:_stateChanged(GUIElement.State.PRESSED)

        return self:onMousePressed(localX, localY, button)
    else
        self:_stateChanged(GUIElement.State.NORMAL)
       -- Remove focus if clicking outside the element
       self:unsetFocus()
    end
    return false
end

function GUIElement:mousereleased(x, y, button)
    if not self.visible or not self.enabled then return false end
        local localX, localY = x - self.x + self.scrollOffset.x, y - self.y + self.scrollOffset.y

        if self.scrollBarEnable then
            if button == 1 then
                self.scrollBarGrabbed.x = false
                self.scrollBarGrabbed.y = false
            end
        end

    if self:containsPoint(localX, localY) then
        for i = #self.children, 1, -1 do
            if self.children[i]:mousereleased(localX, localY, button) then
                return true
            end
        end

        if button == 1 and self.state == GUIElement.State.PRESSED then
            if self.onClick then
                self.onClick()
            end

            self:_stateChanged(GUIElement.State.HOVER)
            return true
        end

        return self:onMouseReleased(localX, localY, button)
    end
    return false
end

function GUIElement:mousemoved(x, y, dx, dy)
    if not self.visible or not self.enabled then return false end
    local localX, localY = x - self.x + self.scrollOffset.x, y - self.y + self.scrollOffset.y
    local localDX, localDY = dx, dy

    if self.scrollBarEnable then
        if self.scrollBarGrabbed.y then
            self:updateVerticalScrollFromMouse(y)
            return true
        elseif self.scrollBarGrabbed.x then
            self:updateHorizontalScrollFromMouse(x)
            return true
        end
    end

    local containsPoint = self:containsPoint(localX, localY)
    local childHandled = false

    for i = #self.children, 1, -1 do
        if self.children[i]:mousemoved(localX, localY, localDX, localDY) then
            childHandled = true
            break
        end
    end

    if containsPoint then
        if not childHandled and self.state ~= GUIElement.State.PRESSED then
            self:_stateChanged(GUIElement.State.HOVER)
        end
        return self:onMouseMoved(localX, localY, localDX, localDY) or childHandled
    else
        if self.state == GUIElement.State.HOVER then
            self:_stateChanged(GUIElement.State.NORMAL)
        end
    end

    return childHandled
end

function GUIElement:updateVerticalScrollFromMouse(y)
    local contentHeight = select(2, self:getContentDimensions())
    local scrollBarHeight = (self.height / contentHeight) * self.height
    local scrollableHeight = self.height - scrollBarHeight
    
    local newScrollBarY = y - self.scrollBarClickOffset.y
    newScrollBarY = math.max(0, math.min(newScrollBarY, scrollableHeight))
    
    local scrollRatio = newScrollBarY / scrollableHeight
    self.scrollOffset.y = scrollRatio * (contentHeight - self.height)
    self.scrollOffset.y = math.max(0, math.min(self.scrollOffset.y, contentHeight - self.height))
end

function GUIElement:updateHorizontalScrollFromMouse(x)
    local contentWidth = select(1, self:getContentDimensions())
    local scrollBarWidth = (self.width / contentWidth) * self.width
    local scrollableWidth = self.width - scrollBarWidth
    
    local newScrollBarX = x - self.scrollBarClickOffset.x
    newScrollBarX = math.max(0, math.min(newScrollBarX, scrollableWidth))
    
    local scrollRatio = newScrollBarX / scrollableWidth
    self.scrollOffset.x = scrollRatio * (contentWidth - self.width)
    self.scrollOffset.x = math.max(0, math.min(self.scrollOffset.x, contentWidth - self.width))
end

function GUIElement:wheelmoved(x, y)
    if not self.visible or not self.enabled then return false end
    for i = #self.children, 1, -1 do
        if self.children[i]:wheelmoved(x, y) then
            return true
        end
    end

    if self.focused then
        if self.scrollBarVisible.y then
            self.scrollOffset.y = math.max(0, math.min(self.scrollOffset.y - y * self.scrollSpeed, select(2, self:getContentDimensions()) - self.height))
            return true
        end
        return self:onWheelMoved(x, y)
    end
end

function GUIElement:getGlobalPosition()
    local x, y = self.x, self.y
    local parent = self.parent
    while parent do
        x = x + parent.x
        y = y + parent.y
        parent = parent.parent
    end
    return x, y
end


function GUIElement:setZIndexGroup(group)
    if GUIElement.ZIndexGroups[group] then
        self.zIndex = GUIElement.ZIndexGroups[group]
    else
        error("Invalid zIndex group: " .. tostring(group))
    end
end

function GUIElement:setZIndexOffset(offset)
    self.zIndexOffset = offset
end

function GUIElement:getZIndex()
    return self.zIndex + self.zIndexOffset
end

function GUIElement:addChild(child)
    table.insert(self.children, child)
    child.parent = self
    child:setZIndexOffset(#self.children)  -- Set offset based on add order
end

function GUIElement:removeChild(child)
    for i, v in ipairs(self.children) do
        if v == child then
            table.remove(self.children, i)
            child.parent = nil
            break
        end
    end
end

function GUIElement:drawSelf()
    -- Implement in subclasses

end



function GUIElement:keypressed(key, scancode, isrepeat)
    if not self.visible or not self.enabled then return false end
    for i = #self.children, 1, -1 do
        if self.children[i]:keypressed(key, scancode, isrepeat) then
            return true
        end
    end
    return self:onKeyPressed(key, scancode, isrepeat)
end

function GUIElement:textinput(text)
    if not self.visible or not self.enabled then return false end
    for i = #self.children, 1, -1 do
        if self.children[i]:textinput(text) then
            return true
        end
    end
    return self:onTextInput(text)
end

function GUIElement:containsPoint(x, y)
    return x >= 0 and x < self.width and y >= 0 and y < self.height
end

-- Event handlers (to be overridden in subclasses)
function GUIElement:onMousePressed(x, y, button) return false end
function GUIElement:onMouseReleased(x, y, button) return false end
function GUIElement:onMouseMoved(x, y, dx, dy) return false end
function GUIElement:onWheelMoved(x, y) return false end
function GUIElement:onKeyPressed(key, scancode, isrepeat) return false end
function GUIElement:onTextInput(text) return false end
function GUIElement:onFocusGained() end
function GUIElement:onFocusLost() end

-- RowLayout: Arranges children horizontally
local RowLayout = GUIElement:extend()

function RowLayout:init(x, y, width, height, padding)
    RowLayout.super.init(self, x, y, width, height)
    self.padding = padding or 5
end

function RowLayout:addChild(child)
    RowLayout.super.addChild(self, child)
    self:updateChildrenPositions()
end

function RowLayout:updateChildrenPositions()
    local currentX = 0
    for _, child in ipairs(self.children) do
        child.x = currentX
        child.y = 0
        currentX = currentX + child.width + self.padding
    end
end

function RowLayout:drawSelf()
    -- Optionally, draw a background or border for the layout
end

-- ColumnLayout: Arranges children vertically
local ColumnLayout = GUIElement:extend()

function ColumnLayout:init(x, y, width, height, padding)
    ColumnLayout.super.init(self, x, y, width, height)
    self.padding = padding or 5
end

function ColumnLayout:addChild(child)
    ColumnLayout.super.addChild(self, child)
    self:updateChildrenPositions()
end

function ColumnLayout:updateChildrenPositions()
    local currentY = 0
    for _, child in ipairs(self.children) do
        child.x = 0
        child.y = currentY
        currentY = currentY + child.height + self.padding
    end
end

function ColumnLayout:drawSelf()
    -- Optionally, draw a background or border for the layout
end

-- Button
local Button = GUIElement:extend()

function Button:init(x, y, width, height, text)
    Button.super.init(self, x, y, width, height)
    self.text = text or "Button"
    self.onClick = function() end
end

function Button:drawSelf()
    local colors = {
        normal = {0.7, 0.7, 0.7},
        hover = {0.8, 0.8, 0.8},
        pressed = {0.6, 0.6, 0.6}
    }
    love.graphics.setColor(unpack(colors[self.state]))
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.text, 0, self.height / 2 - love.graphics.getFont():getHeight() / 2, self.width, "center")
end

-- function Button:onMousePressed(x, y, button)
--     if button == 1 then
--         self.state = "pressed"
--         return true
--     end
--     return false
-- end

-- function Button:onMouseReleased(x, y, button)
--     if button == 1 and self.state == "pressed" then
--         self.onClick()
--         self.state = "hover"
--         return true
--     end
--     return false
-- end

-- function Button:onMouseMoved(x, y, dx, dy)
--     if self:containsPoint(x, y) then
--         if self.state ~= "pressed" then
--             self.state = "hover"
--         end
--     else
--         self.state = "normal"
--     end
--     return true
-- end

-- function Button:mousemoved(x, y, dx, dy)
--     local localX, localY = x - self.x, y - self.y
--     self:onMouseMoved(localX, localY, dx, dy)
--     return self:containsPoint(localX, localY)
-- end

-- Slider
local Slider = GUIElement:extend()

function Slider:init(x, y, width, height, min, max, value)
    Slider.super.init(self, x, y, width, height)
    self.min = min or 0
    self.max = max or 100
    self.value = value or self.min
    self.onChange = function(value) end
    self.dragging = false
end

function Slider:drawSelf()
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.rectangle("fill", 0, self.height / 2 - 2, self.width, 4)
    local knobX = (self.value - self.min) / (self.max - self.min) * self.width
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.circle("fill", knobX, self.height / 2, 8)
end

function Slider:onMousePressed(x, y, button)
    if button == 1 then
        self.dragging = true
        self:updateValue(x)
        return true
    end
    return false
end

function Slider:onMouseReleased(x, y, button)
    if button == 1 then
        self.dragging = false
        return true
    end
    return false
end

function Slider:onMouseMoved(x, y, dx, dy)
    if self.dragging then
        self:updateValue(x)
        return true
    end
    return false
end

function Slider:updateValue(x)
    local newValue = self.min + (x / self.width) * (self.max - self.min)
    self.value = math.max(self.min, math.min(self.max, newValue))
    self.onChange(self.value)
end

local TextArea = GUIElement:extend()

function TextArea:init(x, y, width, height, text, multiline)
    TextArea.super.init(self, x, y, width, height)
    self.text = text or ""
    self.multiline = multiline or false
    self.cursorPosition = #self.text + 1
    self.font = love.graphics.getFont()
    self._scrollOffset = 0
    self.scrollSpeed = 20
    self.scrollBarWidth = 10
    self._scrollBarVisible = false
    self._scrollBarGrabbed = false
    self.scrollBarPosition = 0
    self.contentHeight = 0
    self.scrollBarClickOffset = 0  -- New variable to store the click offset
    self.focusable = true  -- Make TextArea focusable
end

function TextArea:drawSelf()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    
    -- Calculate global coordinates for scissor
    local globalX, globalY = self:getGlobalPosition()
    
    -- Set scissor to clip text content using global coordinates
    love.graphics.setScissor(
        globalX, 
        globalY, 
        self.width - (self._scrollBarVisible and self.scrollBarWidth or 0), 
        self.height
    )
    
    if self.multiline then
        local wrappedText = self:wrapText(self.text, self.width - 10 - (self._scrollBarVisible and self.scrollBarWidth or 0))
        love.graphics.printf(wrappedText, 5, 5 - self._scrollOffset, self.width - 10 - (self._scrollBarVisible and self.scrollBarWidth or 0))
    else
        love.graphics.print(self.text, 5, self.height / 2 - self.font:getHeight() / 2)
    end

    if self.focused then
        local cursorX, cursorY = self:getCursorPosition()
        love.graphics.line(cursorX, cursorY - self._scrollOffset, cursorX, cursorY + self.font:getHeight() - self._scrollOffset)
    end

    love.graphics.setScissor()

   -- Draw scroll bar if necessary
   if self._scrollBarVisible then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.rectangle("fill", self.width - self.scrollBarWidth, 0, self.scrollBarWidth, self.height)
        
        local scrollBarHeight = (self.height / self.contentHeight) * self.height
        local scrollBarY = (self._scrollOffset / (self.contentHeight - self.height)) * (self.height - scrollBarHeight)
        
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", self.width - self.scrollBarWidth, scrollBarY, self.scrollBarWidth, scrollBarHeight)
    end
end

function TextArea:updateScrollBar()
    local _, textHeight = self.font:getWrap(self.text, self.width - 10 - self.scrollBarWidth)
    self.contentHeight = #textHeight * self.font:getHeight()
    self._scrollBarVisible = self.contentHeight > self.height
    
    if self._scrollBarVisible then
        local maxScroll = self.contentHeight - self.height
        self._scrollOffset = math.min(self._scrollOffset, maxScroll)
    else
        self._scrollOffset = 0
    end
end

function TextArea:onMousePressed(x, y, button)
    if button == 1 then
        if x > self.width - self.scrollBarWidth and self._scrollBarVisible then
            self._scrollBarGrabbed = true
            local scrollBarHeight = (self.height / self.contentHeight) * self.height
            local scrollBarY = (self._scrollOffset / (self.contentHeight - self.height)) * (self.height - scrollBarHeight)
            self.scrollBarClickOffset = y - scrollBarY  -- Store the offset where the user clicked on the scroll bar
        else
            self:setCursorFromMouse(x, y + self._scrollOffset)
        end
        return true
    end
    return false
end

function TextArea:onMouseReleased(x, y, button)
    if button == 1 then
        self._scrollBarGrabbed = false
        return true
    end
    return false
end

function TextArea:onMouseMoved(x, y, dx, dy)
    if self._scrollBarGrabbed then
        self:updateScrollFromMouse(y)
        return true
    end
    return false
end

-- Add focus event handlers
function TextArea:onFocusGained()
    -- You can add any specific behavior when the TextArea gains focus
end

function TextArea:onFocusLost()
    -- You can add any specific behavior when the TextArea loses focus
end

function TextArea:updateScrollFromMouse(y)
    local scrollBarHeight = (self.height / self.contentHeight) * self.height
    local scrollableHeight = self.height - scrollBarHeight
    
    -- Calculate the new scroll bar position, taking into account the click offset
    local newScrollBarY = y - self.scrollBarClickOffset
    
    -- Clamp the new position to prevent the scroll bar from going out of bounds
    newScrollBarY = math.max(0, math.min(newScrollBarY, scrollableHeight))
    
    -- Calculate the new scroll offset based on the scroll bar position
    local scrollRatio = newScrollBarY / scrollableHeight
    self._scrollOffset = scrollRatio * (self.contentHeight - self.height)
    
    -- Ensure the scroll offset stays within bounds
    self._scrollOffset = math.max(0, math.min(self._scrollOffset, self.contentHeight - self.height))
end

function TextArea:onWheelMoved(x, y)
    if self.focused then
        if self._scrollBarVisible then
            self._scrollOffset = math.max(0, math.min(self._scrollOffset - y * self.scrollSpeed, self.contentHeight - self.height))
            return true
        end
    end
    return false
end

function TextArea:onTextInput(text)
    if self.focused then
        self.text = self.text:sub(1, self.cursorPosition - 1) .. text .. self.text:sub(self.cursorPosition)
        self.cursorPosition = self.cursorPosition + #text
        self:updateScrollBar()
        return true
    end
    return false
end

function TextArea:onKeyPressed(key, scancode, isrepeat)
    if not self.focused then return false end

    if key == "backspace" then
        if self.cursorPosition > 1 then
            self.text = self.text:sub(1, self.cursorPosition - 2) .. self.text:sub(self.cursorPosition)
            self.cursorPosition = self.cursorPosition - 1
        end
    elseif key == "return" and self.multiline then
        self.text = self.text:sub(1, self.cursorPosition - 1) .. "\n" .. self.text:sub(self.cursorPosition)
        self.cursorPosition = self.cursorPosition + 1
    elseif key == "left" then
        if self.cursorPosition > 1 then
            self.cursorPosition = self.cursorPosition - 1
        end
    elseif key == "right" then
        if self.cursorPosition <= #self.text then
            self.cursorPosition = self.cursorPosition + 1
        end
    elseif key == "up" then
        self:moveCursorVertically(-1)
    elseif key == "down" then
        self:moveCursorVertically(1)
    end
    
    self:updateScrollBar()
    self:ensureCursorVisible()
    return true
end

function TextArea:moveCursorVertically(direction)
    if not self.multiline then return end

    local currentLine, currentColumn = self:getCurrentLineAndColumn()
    local lines = self:getLines()
    local newLine = currentLine + direction

    if newLine >= 1 and newLine <= #lines then
        local targetColumn = math.min(currentColumn, #lines[newLine])
        self.cursorPosition = self:getPositionFromLineAndColumn(newLine, targetColumn)
    end
end


function TextArea:getCurrentLineAndColumn()
    local lines = self:getLines()
    local currentPosition = 0
    for i, line in ipairs(lines) do
        if currentPosition + #line >= self.cursorPosition then
            return i, self.cursorPosition - currentPosition
        end
        currentPosition = currentPosition + #line + 1  -- +1 for newline character
    end
    return #lines, #lines[#lines] + 1
end

function TextArea:getLines()
    return self:wrapText(self.text, self.width - 10 - (self._scrollBarVisible and self.scrollBarWidth or 0)):split("\n")
end

function TextArea:getPositionFromLineAndColumn(line, column)
    local lines = self:getLines()
    local position = 0
    for i = 1, line - 1 do
        position = position + #lines[i] + 1  -- +1 for newline character
    end
    return position + column
end

function TextArea:ensureCursorVisible()
    local cursorX, cursorY = self:getCursorPosition()
    local visibleTop = self._scrollOffset
    local visibleBottom = visibleTop + self.height

    if cursorY < visibleTop then
        self._scrollOffset = cursorY
    elseif cursorY + self.font:getHeight() > visibleBottom then
        self._scrollOffset = cursorY + self.font:getHeight() - self.height
    end

    self._scrollOffset = math.max(0, math.min(self._scrollOffset, self.contentHeight - self.height))
end

-- Helper functions for TextArea 
function TextArea:wrapText(text, limit)
    local wrappedText = ""
    local width, lines = self.font:getWrap(text, limit)
    for i, line in ipairs(lines) do
        wrappedText = wrappedText .. line
        if i < #lines then
            wrappedText = wrappedText .. "\n"
        end
    end
    return wrappedText
end

function TextArea:getGlobalPosition()
    local x, y = self.x, self.y
    local parent = self.parent
    while parent do
        x = x + parent.x
        y = y + parent.y
        parent = parent.parent
    end
    return x, y
end

function TextArea:getCursorPosition()
    local textBeforeCursor = self.text:sub(1, self.cursorPosition - 1)
    local wrappedText, lines = self.font:getWrap(textBeforeCursor, self.width - 10)
    local cursorX = 5 + self.font:getWidth(lines[#lines])
    local cursorY = 5 + (#lines - 1) * self.font:getHeight()
    return cursorX, cursorY
end

function TextArea:setCursorFromMouse(x, y)
    local lines = {}
    if self.multiline then
        _, lines = self.font:getWrap(self.text, self.width - 10)
    else
        lines[1] = self.text
    end

    local lineHeight = self.font:getHeight()
    local lineIndex = math.floor((y - 5) / lineHeight) + 1
    lineIndex = math.max(1, math.min(lineIndex, #lines))

    local cursorPosInLine = self:getCursorPosInLine(lines[lineIndex], x - 5)
    local cursorPosition = 0
    for i = 1, lineIndex - 1 do
        cursorPosition = cursorPosition + #lines[i] + 1
    end
    cursorPosition = cursorPosition + cursorPosInLine
    self.cursorPosition = math.max(1, math.min(cursorPosition, #self.text + 1))
end

function TextArea:getCursorPosInLine(line, x)
    local width = 0
    for i = 1, #line do
        width = width + self.font:getWidth(line:sub(i, i))
        if width >= x then
            return i
        end
    end
    return #line + 1
end

-- OptionSelect: A control for selecting one option from a list
local OptionSelect = GUIElement:extend()

function OptionSelect:init(x, y, width, height, options, defaultOption)
    OptionSelect.super.init(self, x, y, width, height)
    self.options = options or {}
    self.selectedOption = defaultOption or (options and options[1]) or nil
    self.selectedIndex = defaultOption and table.indexof(options, defaultOption) or 1
    self.isOpen = false
    self.hoverIndex = nil
    self.itemHeight = 30  -- Height of each option item
    self.maxVisibleItems = 5  -- Maximum number of visible items when dropdown is open
    self:setZIndexGroup(GUIElement.ZIndexNames.NORMAL)  -- Default to NORMAL group
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
    
    -- Draw the dropdown if it's open
    if self.isOpen then
        local visibleItems = math.min(#self.options, self.maxVisibleItems)
        local dropdownHeight = visibleItems * self.itemHeight
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, self.height, self.width, dropdownHeight)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", 0, self.height, self.width, dropdownHeight)
        
        for i, option in ipairs(self.options) do
            if i > self.maxVisibleItems then break end
            local y = self.height + (i - 1) * self.itemHeight
            if i == self.hoverIndex then
                love.graphics.setColor(0.9, 0.9, 0.9)
                love.graphics.rectangle("fill", 0, y, self.width, self.itemHeight)
            end
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf(option, 5, y + self.itemHeight / 2 - love.graphics.getFont():getHeight() / 2, self.width - 10, "left")
        end
    end
end

function OptionSelect:mousepressed(x, y, button)
    if not self.visible or not self.enabled then return false end
    local localX, localY = x - self.x, y - self.y
    
    if self:containsPoint(localX, localY) then
        if button == 1 then
            if localY < self.height then
                self.isOpen = not self.isOpen
                if self.isOpen then
                    self:setZIndexGroup(GUIElement.ZIndexNames.POPUP)
                else
                    self:setZIndexGroup(GUIElement.ZIndexNames.NORMAL)
                end
            elseif self.isOpen then
                local index = math.floor((localY - self.height) / self.itemHeight) + 1
                if index > 0 and index <= #self.options and index <= self.maxVisibleItems then
                    self.selectedOption = self.options[index]
                    self.selectedIndex = index
                    self.isOpen = false
                    self:setZIndexGroup(GUIElement.ZIndexNames.NORMAL)
                    if self.onChange then
                        self.onChange(self.selectedOption, self.selectedIndex)
                    end
                end
            end
            return true
        end
    elseif self.isOpen then
        self.isOpen = false
        self:setZIndexGroup(GUIElement.ZIndexNames.NORMAL)
        return true
    end
    
    return false
end

function OptionSelect:mousemoved(x, y, dx, dy)
    if not self.visible or not self.enabled then return false end
    local localX, localY = x - self.x, y - self.y
    
    if self.isOpen and self:containsPoint(localX, localY) then
        if localY > self.height then
            self.hoverIndex = math.floor((localY - self.height) / self.itemHeight) + 1
            if self.hoverIndex > self.maxVisibleItems or self.hoverIndex > #self.options then
                self.hoverIndex = nil
            end
        else
            self.hoverIndex = nil
        end
        return true
    end
    
    return false
end

function OptionSelect:mousereleased(x, y, button)
    return false  -- We handle everything in mousepressed, so no need for mousereleased
end

function OptionSelect:containsPoint(x, y)
    if not self.isOpen then
        return x >= 0 and x < self.width and y >= 0 and y < self.height
    else
        local dropdownHeight = math.min(#self.options, self.maxVisibleItems) * self.itemHeight
        return x >= 0 and x < self.width and y >= 0 and y < self.height + dropdownHeight
    end
end

function OptionSelect:getSelectedOption()
    return self.selectedOption
end

function OptionSelect:setOptions(options, defaultOption)
    self.options = options
    self.selectedOption = defaultOption or options[1] or nil
    self.selectedIndex = defaultOption and table.indexof(options, defaultOption) or 1
end

-- ProgressBar: A control for displaying progress
local ProgressBar = GUIElement:extend()

function ProgressBar:init(x, y, width, height, value, max, color)
    ProgressBar.super.init(self, x, y, width, height)
    self.value = value or 0
    self.max = max or 100
    self.color = color or {0.2, 0.6, 1} -- Default to a light blue color
    self.backgroundColor = {0.8, 0.8, 0.8} -- Light gray background
    self.borderColor = {0.5, 0.5, 0.5} -- Medium gray border
end

function ProgressBar:drawSelf()
    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    -- Draw progress
    local progressWidth = (self.value / self.max) * self.width
    love.graphics.setColor(unpack(self.color))
    love.graphics.rectangle("fill", 0, 0, progressWidth, self.height)
    
    -- Draw border
    love.graphics.setColor(unpack(self.borderColor))
    love.graphics.rectangle("line", 0, 0, self.width, self.height)
    
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

-- Popup: A control for displaying temporary messages
local Popup = GUIElement:extend()

function Popup:init(x, y, width, height, text)
    Popup.super.init(self, x, y, width, height)
    self.text = text or ""
    self.visible = false
    self.lifetime = 0
    self.maxLifetime = 2  -- seconds
    self.backgroundColor = {0.2, 0.2, 0.2, 0.8}
    self.textColor = {1, 1, 1}
end

function Popup:drawSelf()
    if self.visible then
        love.graphics.setColor(unpack(self.backgroundColor))
        love.graphics.rectangle("fill", 0, 0, self.width, self.height)
        love.graphics.setColor(unpack(self.textColor))
        love.graphics.printf(self.text, 0, self.height / 2 - love.graphics.getFont():getHeight() / 2, self.width, "center")
    end
end

function Popup:update(dt)
    if self.visible then
        self.lifetime = self.lifetime + dt
        if self.lifetime >= self.maxLifetime then
            self.visible = false
            self.lifetime = 0
        end
    end
end

function Popup:show(text)
    self.text = text or self.text
    self.visible = true
    self.lifetime = 0
end

function Popup:hide()
    self.visible = false
    self.lifetime = 0
end

function Popup:setMaxLifetime(seconds)
    self.maxLifetime = seconds
end

function Popup:setBackgroundColor(color)
    self.backgroundColor = color
end

function Popup:setTextColor(color)
    self.textColor = color
end

-- Main GUI table
local GUI = {
    GUIElement = GUIElement,
    RowLayout = RowLayout,
    ColumnLayout = ColumnLayout,
    Button = Button,
    Slider = Slider,
    TextArea = TextArea,
    OptionSelect = OptionSelect,
    ProgressBar = ProgressBar,
    Popup = Popup,
    -- ScrollView = ScrollView
    -- Add other GUI elements here as they are implemented
}

return GUI