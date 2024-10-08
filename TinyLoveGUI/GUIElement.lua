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
local Layout = require(cwd .. "Layout")
local FlowLayout = require(cwd .. "FlowLayout")
local XYLayout = require(cwd .. "XYLayout")

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

function table.sortedTable(tbl, compareFunc)
    -- Create a new table with the same elements
    local newTable = {}
    for i, v in ipairs(tbl) do
        newTable[i] = v
    end
    
    -- Sort the new table
    table.sort(newTable, compareFunc)
    
    return newTable
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


--- comment 
--- @param options table {x: number, y: number, width: number, height: number, bgcolor: table, state: table, tag: string, zIndex: number}
function GUIElement:init(options)
    options = options or {}   

    self.x = options.x or 0
    self.y = options.y or 0
    self.width = options.width or 100
    self.height = options.height or 100
    self.resizing = false
    -- if type(self.width) ~= "number" or type(self.height) ~= "number" then
    --     print("Warning: GUIElement initialized with invalid dimensions", self.tag, self.width, self.height)
    --     self.width = self.width or 100
    --     self.height = self.height or 100
    -- end
    self.parent = nil
    if options.bgcolor ~= nil and options.bgcolor.r == nil then
        options.bgcolor = {options.bgcolor[1],options.bgcolor[2],options.bgcolor[3]}
    end
    self.bgcolor = options.bgcolor or {0.5,0.5,0.5}
    if #self.bgcolor == 3 then
        self.bgcolor[4] = 1
    end
    
    self.state = options.state or GUIContext.State.NORMAL
    self.tag = options.tag or "GUIElement"
    self:setZIndex(options.zIndex or GUIContext.ZIndexGroup.NORMAL)

    self.DEBUG_DRAW = TINYLOVEGUI_DEBUG
    self.context =  options.context
    -- focus
    self.focusable = false
    self.highligtable = false
    self.cid = 0
    self.layout = options.layout or XYLayout()

    if self.layout then
        self.layout.owner = self    
    end
    -- self.focused = false
    --self.padding = {left=0, right=0, top=0, bottom=0}
    self.popups = {}

    self.visible = true  -- New property to control visibility
end

function GUIElement:setContext(context)
    self.context = context
    if self.onAddToContext then
        self.onAddToContext()
    end
end

function GUIElement:setLayout(layout)
    self.layout = layout
    self.layout.owner = self
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

function GUIElement:resize(width, height)
    assert(self.resizing == false, "seems loop reize the element")

    self.context.debug_print_log('start reizing:' .. self.tag)
    self.width = width
    self.height = height
    self.resizing = true

    self:updateLayout()

    self.resizing = false
end

function GUIElement:updateLayout()
    self.layout:updateLayout()
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

function GUIElement:setNeedSortChildren(needSortChildren)
    self.layout:setNeedSortChildren(needSortChildren)
end

function GUIElement:setZIndex(zIndex)
    self.zIndex = zIndex
    -- if self.parent then
    --     self.parent:sortChildren()
    -- end
    if self.parent then
        self.parent:setNeedSortChildren(true)
    end
end


function GUIElement:getHeight()
    return self.height
end

function GUIElement:getWidth()
    return self.width
end 

function GUIElement:addChild(child, options)
    assert(child.parent == nil, "child.parent is already set")
    assert(self.context ~= nil, "parent context is not set")

    if child.zIndex == GUIContext.ZIndexGroup.MODAL_WINDOW then
        print("child zIndex is MODAL_WINDOW, ModalWindow should not be added to parent")
    end

    assert(child.zIndex ~= GUIContext.ZIndexGroup.MODAL_WINDOW, "child zIndex is MODAL_WINDOW, ModalWindow should not be added to parent")

    --table.insert(self.layout.children, child)


    child.parent = self
    child.context = self.context
    child.cid = self.context:nextCID()

    self.layout:addChild(child, options)


    if child.onAddToContext then
        child:onAddToContext(self.context)
    end
    --self:sortChildren()

    -- Check if child extends beyond parent boundaries
    self:checkChildBounds(child)
end

function GUIElement:checkChildBounds(child)
    local childRight = child.x + child.width
    local childBottom = child.y + child.height

    if child.x < 0 or child.y < 0 or childRight > self.width or childBottom > self.height then
        self.context.debug_print_warn(string.format("Child '%s' (%.2f, %.2f, %.2f, %.2f) extends beyond parent '%s' (0, 0, %.2f, %.2f)",
            child.tag, child.x, child.y, child.width, child.height,
            self.tag, self.width, self.height))
    end
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

function GUIElement:onPointerEnter()
    self:_stateChanged(GUIContext.State.HOVER)
    return true
end

function GUIElement:onPointerLeave()
    self:_stateChanged(GUIContext.State.NORMAL)
    return true
end

function GUIElement:removeChild(child)
    for i, c in ipairs(self:getChildren()) do
        if c == child then
            table.remove(self:getChildren(), i)
            self:setNeedSortChildren(true)
            child.parent = nil
            break
        end
    end
end

function GUIElement:draw()

    if not self.visible then return end  -- Skip drawing if not visible

    love.graphics.push()
    love.graphics.setColor(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3], self.bgcolor[4])
    love.graphics.translate(self.x, self.y)
    if self.DEBUG_DRAW then
        love.graphics.setColor(1, 0, 0)
        if self.old_width ~= self.width or self.old_height ~= self.height then
            print("draw:" .. tostring(self.width) .. " " .. tostring(self.height))
            self.old_width = self.width
            self.old_height = self.height
        end
        love.graphics.rectangle("line", 0, 0, self.width, self.height)
        love.graphics.setColor(1, 1, 1)
    end
    local children = self:sortChildren()
    self:onDraw()
    if children then
        for _, child in ipairs(children) do
            child:draw()
        end
    end
    
    love.graphics.pop()
end



function GUIElement:onDraw()
    -- draw...
end

function GUIElement:getChildren()
    if not self.layout  then
        print("layout is nil")
        return {}
    end
    return self.layout:getChildren()
end


function GUIElement:sortChildren()
    return self.layout:sortChildren()
end

function GUIElement:getNeedSortChildren()
    return self.layout:getNeedSortChildren()
end

function GUIElement:update(dt)
    for _, child in ipairs(self:getChildren()) do
        if child:getNeedSortChildren() then
            self:sortChildren()
        end
        child:update(dt)
    end
end

local function print_event_info(self, event)
    local Utils = require(cwd .. "Utils")
    Utils.print_table(event)
end

local function handlePositionalInput(self, event)
    if event.type ~= EventType.MOUSE_MOVED then
        self.context.debug_print_log("--- EVENT COMING ---")
        print_event_info(self,event)
    end

    if self.cid == 'playgoundView' then
        print('playgoundView')
    end

    if (not self:isPointInside(event.data.x, event.data.y)) or self.visible == false then
        --self.context.debug_print_log("==== not point inside:" .. self.tag)
        return false
    end
    
    local localX, localY = self:toLocalCoordinates(event.data.x, event.data.y)
    local handled = false
    local sortedChildren = self:sortChildren()

    for i = #sortedChildren, 1, -1 do
        local child = sortedChildren[i]
        if child:isPointInside(localX, localY) and child.visible == true then

            local localData = {}
            for k, v in pairs(event.data) do
                localData[k] = v
            end
            localData.x, localData.y = localX, localY
            local localEvent = InputEvent(event.type, localData)
            
            handled = child:handleInput(localEvent)
            if handled then
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
        -- self.context.debug_print_log("==== current handled:" .. self.tag)
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
    local sortedChildren = self:sortChildren()
    -- If not handled by this element, propagate to children
    for i = #sortedChildren, 1, -1 do
        local handled = sortedChildren[i]:handleInput(event)
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

function GUIElement:getGlobalPositionByLocalXY(x, y)
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
    local localX = x - self.x
    local localY = y - self.y

    return localX, localY
end

function GUIElement:isPointInside(x, y, dx, dy)
    dx = dx or 0  -- Default to 0 if not provided
    dy = dy or dx  -- Use dx for dy if dy is not provided

    local w, h = self:getSize()
    return x >= (self.x - dx) and x <= (self.x + w + dx) and
           y >= (self.y - dy) and y <= (self.y + h + dy)
end


function GUIElement:getSize()
    return self.width, self.height
end

function GUIElement:onInput(event)
    -- Default implementation, to be overridden in subclasses
    if (event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED) then

        if event.data.button == 2 then
            if self.onRightClick then
                self.context.debug_print_log('mouse right clicked!')
                self.onRightClick(self, event.data.x, event.data.y)
            end
        end
    end
    return false
end

return GUIElement   