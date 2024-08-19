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

-- this object class from SNKRX (https://github.com/a327ex/SNKRX/blob/master/engine/game/object.lua
-- OOP Base
Object = {}
Object.__index = Object


local DEBUG_DRAW = true

function Object:init() end

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




-- GUIElement: Base class for all GUI elements
local GUIElement = Object:extend()


local cwd = select(1, ...):match(".+%.") or ""
print('cwd:' .. cwd)
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType  
local InputEvent = InputEventUtils.InputEvent 

GUIElement.DEBUG_ALL = true
GUIElement.DEBUG_TYPE = {
    LOG = 1,    -- log
    WARN = 2,   -- warn
    ERROR = 3,  -- error    
}
function GUIElement.debug_print(type, ...)
    if type == GUIElement.DEBUG_TYPE.LOG then
        print('LOG: ' .. ...)
    elseif type == GUIElement.DEBUG_TYPE.WARN then
        print('WARN: ' .. ...)  
    elseif type == GUIElement.DEBUG_TYPE.ERROR then
        print('ERROR: ' .. ...)
    end
end

GUIElement.debug_print_error = function(...)
    GUIElement.debug_print(GUIElement.DEBUG_TYPE.ERROR, ...)
end

GUIElement.debug_print_log = function(...)
    GUIElement.debug_print(GUIElement.DEBUG_TYPE.LOG, ...)
end

GUIElement.debug_print_warn = function(...)
    GUIElement.debug_print(GUIElement.DEBUG_TYPE.WARN, ...)
end


if GUIElement.DEBUG_ALL then
    GUIElement.print_error = GUIElement.debug_print     
else
    GUIElement.print_error = function() end
end


GUIElement.ZIndexGroupNames = {
    SHADOW = 'SHADOW',
    NORMAL = 'NORMAL',
    MODAL_WINDOW = "MODAL_WINDOW",
    POPUP = 'POPUP'  -- Added for elements like dropdowns that should be on top
}

GUIElement.ZIndexGroup = {
    SHADOW = 10,
    NORMAL = 500,
    MODAL_WINDOW = 1000,
    POPUP = 1500  -- Added for elements like dropdowns that should be on top 
}

GUIElement.State = {
    NORMAL = "normal",
    HOVER = "hover",
    PRESSED = "pressed"
  }

local focusedElement = nil

  
function GUIElement:init(x, y, width, height, bgcolor)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 100
    self.height = height or 100
    self.children = {}
    self.parent = nil
    self.bgcolor = bgcolor or {r=0.5,g=0.5,b=0.5}
    self.state = GUIElement.State.NORMAL
    self.tag = "GUIElement"
    self.zIndex = GUIElement.ZIndexGroup.NORMAL
    self.DEBUG_DRAW = DEBUG_DRAW
    -- focus
    self.focusable = false
    -- self.focused = false

    self.visible = true  -- New property to control visibility
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
    return focusedElement == self
end


function GUIElement:setFocus()
    if self.focusable and focusedElement ~= self then
        if focusedElement then
            focusedElement:onFocusLost()
        end
        focusedElement = self
        self:onFocusGained()
    end
end

function GUIElement:clearFocus()
    if focusedElement == self then
        focusedElement = nil
        self:onFocusLost()
    end
end
function GUIElement:onFocusGained()
    -- Override this method in subclasses to handle gaining focus
end

function GUIElement:onFocusLost()
    -- Override this method in subclasses to handle losing focus
end




function GUIElement:setDebugDraw(debugDraw)
    self.DEBUG_DRAW = debugDraw
end

function GUIElement:setZIndex(zIndex)
    self.zIndex = zIndex
    if self.parent then
        self.parent:sortChildren()
    end
end


function GUIElement:addChild(child)
    table.insert(self.children, child)
    child.parent = self
    self:sortChildren()
end

function GUIElement:_stateChanged(new_state)
    if new_state == nil or self.state == nil then
       GUIElement.debug_print_log("! new state is nil")
    end
    if self.state ~= new_state then
       GUIElement.debug_print_log("tag:"..self.tag .. " state changed:" .. self.state .. '~>' .. new_state)
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
        return a.zIndex < b.zIndex
    end)
end


function GUIElement:update(dt)
    for _, child in ipairs(self.children) do
        child:update(dt)
    end
end

local function handlePositionalInput(self, event)
    if not self:isPointInside(event.data.x, event.data.y) then
        return false
    end
    
    local localX, localY = self:toLocalCoordinates(event.data.x, event.data.y)
    local handled = false
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child:isPointInside(localX, localY) then
            local localData = {}
            for k, v in pairs(event.data) do
                localData[k] = v
            end
            localData.x, localData.y = localX, localY
            local localEvent = InputEvent(event.type, localData)
            handled = child:handleInput(localEvent)
            if handled then
                if child:isFocusable() and (event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED) then
                    child:setFocus()
                end
                break
            end
        else
            child:clearFocus()
        end
    end

    if not handled then
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


-- Modify existing event handlers
function GUIElement:mousepressed(x, y, button)
    local event = InputEvent.mousepressed(x, y, button)
    return self:handleInput(event)
end

function GUIElement:mousemoved(x, y, dx, dy)
    local event = InputEvent.mousemoved(x, y, dx, dy)
    return self:handleInput(event)
end

function GUIElement:mousereleased(x, y, button)
    local event = InputEvent.mousereleased(x, y, button)
    return self:handleInput(event)
end

function GUIElement:touchpressed(id, x, y, dx, dy, pressure)
    local event = InputEvent.touchpressed(id, x, y, dx, dy, pressure)
    return self:handleInput(event)
end

function GUIElement:touchmoved(id, x, y, dx, dy, pressure)
    local event = InputEvent.touchmoved(id, x, y, dx, dy, pressure)
    return self:handleInput(event)
end

function GUIElement:touchreleased(id, x, y, dx, dy, pressure)
    local event = InputEvent.touchreleased(id, x, y, dx, dy, pressure)
    return self:handleInput(event)
end

-- Add handlers for non-positional events
function GUIElement:keypressed(key, scancode, isrepeat)
    local event = InputEvent.keypressed(key, scancode, isrepeat)
    return self:handleInput(event)
end

function GUIElement:keyreleased(key, scancode)
    local event = InputEvent.keyreleased(key, scancode)
    return self:handleInput(event)
end

function GUIElement:textinput(text)
    local event = InputEvent.textinput(text)
    return self:handleInput(event)
end

function GUIElement:wheelmoved(dx, dy)
    local event = InputEvent.wheelmoved(dx, dy)
    return self:handleInput(event)
end

-- onInput method remains the same
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
