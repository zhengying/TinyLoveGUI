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
local Object = require(cwd .. "Object")
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType  
local InputEvent = InputEventUtils.InputEvent 
local KeyCode = InputEventUtils.KeyCode


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


-- GUIElement: Base class for all GUI elements
local GUIElement = Object:extend()

GUIElement.Animate_type = {
    STATIC = "STATIC",
    ALPHA = "ALPHA",
    DOWN_TOP = "DOWN_TOP",
    TOP_DOWN = "TOP_DOWN",
    LEFT_RIGHT = "LEFT_RIGHT",
    RIGHT_LEFT = "RIGHT_LEFT"
}

local GUIContext = require(cwd .. "GUIContext")


  
function GUIElement:init(x, y, width, height, bgcolor)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 100
    -- if type(self.width) ~= "number" or type(self.height) ~= "number" then
    --     print("Warning: GUIElement initialized with invalid dimensions", self.tag, self.width, self.height)
    --     self.width = self.width or 100
    --     self.height = self.height or 100
    -- end
    self.children = {}
    self.parent = nil
    self.bgcolor = bgcolor or {r=0.5,g=0.5,b=0.5}
    self.state = GUIContext.State.NORMAL
    self.tag = "GUIElement"
    self.zIndex = GUIContext.ZIndexGroup.NORMAL
    self.DEBUG_DRAW = DEBUG_DRAW
    self.context = nil
    -- focus
    self.focusable = true
    self.highligtable = true
    self.cid = 0
    -- self.focused = false

    self.visible = true  -- New property to control visibility
end

function GUIElement:setContext(context)
    self.context = context
    if self.onAddToContext then
        self.onAddToContext()
    end
end

function GUIElement:hide()
    self.visible = false
end

function GUIElement:show()
    self.visible = true
end

function GUIElement:isVisible()
    return self.visible
end

function GUIElement:setFocusable(focusable)
    self.focusable = focusable
end

function GUIElement:isFocusable()
    return self.focusable
end

function GUIElement:isFocused()
    return self.context.focusedElement == self
end

function GUIElement:setFocus()
    self.context:setFocus(self)
end

-- function GUIElement:setFocus()
--     -- if self.focusable and self.context.focusedElement ~= self then
--     --     if self.context.focusedElement then
--     --         self.context.focusedElement:onFocusLost()
--     --         self.context:setFocus(nil)
--     --     end
--     --     self.context:setFocus(self)
--     --     self:onFocusGained()
--     -- end
--     self.context:setFocus(self)
-- end

-- function GUIElement:clearFocus()
--     -- if focusedElement == self then
--     --     focusedElement = nil
--     --     self:onFocusLost()
--     -- end
--     self.context:setFocus(nil)
-- end

function GUIElement:getAllElementsAtPosition(x, y)
    local elements = {}
    
    -- Check if the point is within this element's bounds
    if self.tag == "FlowLayout" then
        print("FlowLayout:getAllElementsAtPosition", x, y)
    end
    if self:containsPoint(x, y) and self.visible then
        table.insert(elements, self)
        self:sortChildren()
        -- Check children
        for i = #self.children, 1, -1 do
            local child = self.children[i]
            local childElements = child:getAllElementsAtPosition(x - self.x, y - self.y)
            for _, element in ipairs(childElements) do
                table.insert(elements, element)
            end
        end
    end
    
    return elements
end

function GUIElement:containsPoint(x, y)
    return self:isPointInside(x, y)
end

function GUIElement:onFocusGained()
    -- Override this method in subclasses to handle gaining focus
end

function GUIElement:onFocusLost()
    -- Override this method in subclasses to handle losing focus
end

function GUIElement:removeFromParent()
    if self.parent then
        self.parent:removeChild(self)
    end
end

function GUIElement:setZIndex(zIndex)
    self.zIndex = zIndex
    if self.parent then
        self.parent:sortChildren()
    end
end

function GUIElement:addChild(child)
    assert(child.parent == nil, "child.parent is already set")
    assert(self.context ~= nil, "parent context is not set")
    assert(child.zIndex ~= GUIContext.ZIndexGroup.MODAL_WINDOW, "child zIndex is MODAL_WINDOW, ModalWindow should not be added to parent")

    table.insert(self.children, child)
    child.parent = self
    child.context = self.context
    child.cid = self.context:nextCID()
    if child.onAddToContext then
        child:onAddToContext(self.context)
    end
    self:sortChildren()
end

function GUIElement:_stateChanged(new_state)
    if new_state == nil or self.state == nil then
        GUIContext.debug_print_log("! new state is nil")
    end
    if self.state ~= new_state then
       GUIContext.debug_print_log("tag:"..self.tag .. " state changed:" .. self.state .. '~>' .. new_state)
    end

    self.state = new_state
end

function GUIElement:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            child.parent = nil
            break
        end
    end
end

function GUIElement:draw()
    if not self.visible then return end  -- Skip drawing if not visible

    love.graphics.push()

    if self.DEBUG_DRAW then
        love.graphics.setColor(1, 1, 1)
        local w, h = self:getRealSize()
        love.graphics.rectangle("line", self.x, self.y, w, h)
        love.graphics.setColor(1, 1, 1)
    end

    love.graphics.setColor(self.bgcolor.r, self.bgcolor.g, self.bgcolor.b)
    love.graphics.translate(self.x, self.y)
    self:drawSelf()
    for _, child in ipairs(self.children) do
        child:draw()
    end
    
    love.graphics.pop()
end



function GUIElement:drawSelf()
    -- draw...
end


function GUIElement:sortChildren()
    table.sort(self.children, function(a, b)
        if a.zIndex == b.zIndex then
            return a.cid < b.cid
        end
        return a.zIndex < b.zIndex
    end)
end


function GUIElement:update(dt)
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

-- function GUIElement:updatePointerState(x, y)
--     local isInside = self:isPointInside(x, y)
--     local wasInside = self.pointerInside or false

--     if isInside and not wasInside then
--         self:pointerEnter()
--     elseif not isInside and wasInside then
--         self:pointerLeave()
--     end

--     -- Update children
--     for _, child in ipairs(self.children) do
--         child:updatePointerState(x - self.x, y - self.y)
--     end

--     self.pointerInside = isInside
-- end

-- function GUIElement:pointerEnter()
--     self.pointerInside = true
--     if self.onPointerEnter then
--         self:onPointerEnter()
--     end
-- end

-- function GUIElement:pointerLeave()
--     self.pointerInside = false
--     if self.onPointerLeave then
--         self:onPointerLeave()
--     end
-- end

local function handlePositionalInput(self, event)
    if (not self:isPointInside(event.data.x, event.data.y)) or self.visible == false then
        self.context.debug_print_log("==== not point inside:" .. self.tag)
        return false
    end

    if event.type == EventType.MOUSE_PRESSED then
        print("==== mouse pressed:" .. self.tag)
    end

    self.context.debug_print_log("==== point inside:" .. self.tag)
    
    local localX, localY = self:toLocalCoordinates(event.data.x, event.data.y)
    local handled = false
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child:isPointInside(localX, localY) and child.visible == true then

            if event.type == EventType.MOUSE_PRESSED then
                print("==== mouse pressed:" .. self.tag)
            end


            local localData = {}
            for k, v in pairs(event.data) do
                localData[k] = v
            end
            localData.x, localData.y = localX, localY
            local localEvent = InputEvent(event.type, localData)
            handled = child:handleInput(localEvent)
            if handled then
                if event.type == EventType.MOUSE_PRESSED then
                    print("==== mouse pressed:" .. self.tag)
                end
                if child:isFocusable() and (event.type == EventType.MOUSE_MOVED or event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED) then
                    child:setFocus()
                end
                break
            elseif child.highligtable == true then
                if event.type == EventType.MOUSE_MOVED then
                    self.context:setHighlight(child)
                end
                break
            end
        end
    end

    if not handled then
        self.context.debug_print_log("==== current handled:" .. self.tag)
        handled = self:onInput(event)
        if handled and self:isFocusable() and (event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED) then
            self:setFocus()
        end
    end

    return handled
end

local function handleNonPositionalInput(self, event)
    -- First, check if this element is focused
    if self:isFocused() then
        local handled = self:onInput(event)
        if handled then
            return true
        end
    end

    -- If not handled by this element, propagate to children
    for i = #self.children, 1, -1 do
        local handled = self.children[i]:handleInput(event)
        if handled then
            return true
        end
    end

    return false
end

function GUIElement:handleInput(event)
    if InputEventUtils.hasPosition(event) then
        return handlePositionalInput(self,event)
    else
        return handleNonPositionalInput(self,event)
    end
end

-- Add this helper function to invert colors
function GUIElement:invertColor(color)
    return {1 - color[1], 1 - color[2], 1 - color[3], color[4]}
end


function GUIElement:getGlobalPosition()

    local x, y = self.x, self.y
    local parent = self.parent
    while parent do
        local offsetX = 0
        local offsetY = 0
        if parent.scrollview == true then
            offsetX = parent.offsetX
            offsetY = parent.offsetY
        end
        x = x + parent.x - offsetX
        y = y + parent.y - offsetY
        parent = parent.parent
    end
    return x, y
end

function GUIElement:toLocalCoordinates(x, y)
    local localX, localY = x, y
    local current = self
    while current do
        localX = localX - current.x
        localY = localY - current.y
        current = current.parent
    end
    return localX, localY
end

function GUIElement:isPointInside(x, y, dx, dy)
    dx = dx or 0  -- Default to 0 if not provided
    dy = dy or dx  -- Use dx for dy if dy is not provided

    local w, h = self:getRealSize()
    return x >= (self.x - dx) and x <= (self.x + w + dx) and
           y >= (self.y - dy) and y <= (self.y + h + dy)
end


function GUIElement:getRealSize()
    return self.width, self.height
end

function GUIElement:onInput(event)
    -- Default implementation, to be overridden in subclasses
    if (event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED) then
        if event.data.button == 2 then
            if self.onRightClick then
                self.onRightClick(self, event.data.x, event.data.y)
            end
        end
    end
    return false
end

return GUIElement