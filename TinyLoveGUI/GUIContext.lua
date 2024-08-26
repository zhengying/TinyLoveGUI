local cwd = select(1, ...):match(".+%.") or ""
local Object = require(cwd .. "Object")
local InputEventUtils = require(cwd .. "InputEventUtils")

---@class GUIContext
local GUIContext = Object:extend()
GUIContext.EventType = InputEventUtils.EventType
local AnimateTimer = require(cwd .. "AnimateTimer")



GUIContext.ZIndexGroupNames = {
    SHADOW = 'SHADOW',
    NORMAL = 'NORMAL',
    MODAL_WINDOW = "MODAL_WINDOW",
    POPUP = 'POPUP'  -- Added for elements like dropdowns that should be on top
}

GUIContext.ZIndexGroup = {
    SHADOW = 10,
    NORMAL = 500,
    MODAL_WINDOW = 1000,
    POPUP = 1500  -- Added for elements like dropdowns that should be on top 
}

GUIContext.State = {
    NORMAL = "normal",
    HOVER = "hover",
    PRESSED = "pressed"
  }

  GUIContext.LocalEvents = {
    HIGHLIGHT_CHANGED = "HIGHLIGHT_CHANGED",
  }

GUIContext.DEBUG_ALL = true

GUIContext.DEBUG_TYPE = {
    LOG = 1,    -- log
    WARN = 2,   -- warn
    ERROR = 3,  -- error    
}
function GUIContext.debug_print(type, ...)
    if type == GUIContext.DEBUG_TYPE.LOG then
        print('LOG: ' .. ...)
    elseif type == GUIContext.DEBUG_TYPE.WARN then
        print('WARN: ' .. ...)  
    elseif type == GUIContext.DEBUG_TYPE.ERROR then
        print('ERROR: ' .. ...)
    end
end

GUIContext.keycodes = InputEventUtils.KeyCode

GUIContext.debug_print_error = function(...)
    GUIContext.debug_print(GUIContext.DEBUG_TYPE.ERROR, ...)
end

GUIContext.debug_print_log = function(...)
    GUIContext.debug_print(GUIContext.DEBUG_TYPE.LOG, ...)
end

GUIContext.debug_print_warn = function(...)
    GUIContext.debug_print(GUIContext.DEBUG_TYPE.WARN, ...)
end

function GUIContext:setDebugDraw(debugDraw)
    self.DEBUG_DRAW = debugDraw
end


if GUIContext.DEBUG_ALL then
    GUIContext.print_error = GUIContext.debug_print     
else
    GUIContext.print_error = function() end
end

function GUIContext:addChild(element)
    self.root:addChild(element)
end

function GUIContext:init()
    self.focusedElement = nil
    self.highlightElement = nil
    self.modalStack = {}
    self.root = nil
    self.pointerX = 0
    self.pointerY = 0
    self.timer = AnimateTimer()
    self.event_listeners = {}
    self.cid_current = 0
    

    local w, h =  love.window.getMode()
    self.w = w
    self.h = h
    local GUIElement = require(cwd .. "GUIElement")
    local mainView = GUIElement(0, 0, w, h)
    self:setRoot(mainView)
end

function GUIContext:nextCID()
    self.cid_current = self.cid_current + 1
    return self.cid_current
end

function GUIContext:registerLocalEvent(name,target,callback)
    assert(name,'event name should be not nil')
    assert(callback, 'event callback should be not nil')
    assert(target, 'target callback should be not nil')

    if not self.event_listeners[name] then
        self.event_listeners[name] = {}
    end

    for _, value in ipairs(self.event_listeners) do
        if value.name == name and value.target == target and value.callback == callback then
            self.debug_print_error('duplicating event:' .. name)
            return false
        end
    end

    table.insert(self.event_listeners[name], {callback = callback, target = target})
    return true
end

function GUIContext:emitLocalEvent(name, data)
    for k, v in pairs(self.event_listeners) do
        if k == name then
            for k, v in ipairs(v) do
                local callback, target = v.callback, v.target
                callback(target, data)
            end

        end
    end
end

function GUIContext:unregisterLocalEvent(name, target)
    for i = #self.event_listeners, 1, -1 do
        if self.event_listeners[i].name == name then
            if target and self.event_listeners[i].target == target  then
                table.remove(self.event_listeners, i)
                return
            end
            table.remove(self.event_listeners, i)
        end
    end
    return
end

function GUIContext:setHighlight(element)
    if element ~= nil and element ~=  self.highlightElement then
        self.highlightElement = element
        if self.highlightElement.onPointerLeave then
            self.highlightElement:onPointerEnter()
        end
        self:emitLocalEvent(self.LocalEvents.HIGHLIGHT_CHANGED,element)
    end
    self.highlightElement = element
end

function GUIContext:clearHighlight()
    if self.highlightElement == nil then return end

    if self.highlightElement.onPointerLeave then
        self.highlightElement:onPointerLeave()
    end

    self:emitLocalEvent(self.LocalEvents.HIGHLIGHT_CHANGED,nil)

    self.highlightElement = nil
end

function GUIContext:setRoot(rootElement)
    self.root = rootElement
    rootElement:setContext(self)
end

function GUIContext:setFocus(element)
    if element == self.focusedElement then
        return
    end
    
    GUIContext.debug_print_log("focus: " .. tostring(self.focusedElement and self.focusedElement.tag or 'nil') .. '->' .. tostring(element and element.tag or 'nil'))
    if self.focusedElement then
        self.focusedElement:onFocusLost()
    end
    self.focusedElement = element
    if element then
        element:onFocusGained()
    end
end

function GUIContext:update(dt)
    if self.root then
        self.root:update(dt)
    end
    self.timer:update(dt)
end

-- function GUIContext:elementAtPosition(x, y)
--     local elements = self:getAllElementsAtPosition(x, y)
--     table.sort(elements, function(a, b)
--         if a.zIndex == nil or b.zIndex == nil then
--             return false
--         end

--         if a.zIndex == b.zIndex then
--             return a.zIndex > b.zIndex
--         end
--         return a.zIndex > b.zIndex
--     end)
--     return elements[#elements]
-- end

-- function GUIContext:getAllElementsAtPosition(x, y)
--     local elements = {}
    
--     -- -- Check modal windows first
--     -- for i = #self.modalStack, 1, -1 do
--     --     local modalElement = self.modalStack[i]
--     --     local modalElements = modalElement:getAllElementsAtPosition(x, y)
--     --     for _, element in ipairs(modalElements) do
--     --         table.insert(elements, element)
--     --     end
--     -- end
    
--     -- -- Then check the root element and its children
--     -- if self.root then
--     --     local rootElements = self.root:getAllElementsAtPosition(x, y)
--     --     for _, element in ipairs(rootElements) do
--     --         table.insert(elements, element)
--     --     end
--     -- end
    
--     -- return elements
--     return self.root:getAllElementsAtPosition(x, y)    
-- end

function GUIContext:pushModal(modalElement)
    table.insert(self.modalStack, modalElement)
    modalElement:setZIndex(GUIContext.ZIndexGroup.MODAL_WINDOW)
    self:setFocus(modalElement)
end

function GUIContext:popModal()
    local modalElement = table.remove(self.modalStack)
    if modalElement then
        modalElement:setZIndex(GUIContext.ZIndexGroup.NORMAL)
        self:setFocus(nil)
    end
    return modalElement
end

function GUIContext:getTopModal()
    return self.modalStack[#self.modalStack]
end

function GUIContext:hasModalWindow()
    return #self.modalStack > 0
end

function GUIContext:updateMousePosition(x, y)
    self.pointerX = x
    self.pointerY = y
end

function GUIContext:setOnRightClick(callback)
    self.root.onRightClick = callback
end


local love2dMouseKeyCodes = {[GUIContext.keycodes.M1]=1,[GUIContext.keycodes.M2]=2,[GUIContext.keycodes.M3]=3}
--- check if a key is pressed
---@param keycode any
---@return boolean
function GUIContext:checkKeyPress(keycode)
    if keycode == GUIContext.keycodes.M1 or keycode == GUIContext.keycodes.M2 or keycode == GUIContext.keycodes.M3 then
        return love.mouse.isDown(love2dMouseKeyCodes[keycode])
    else
        return love.keyboard.isDown(keycode)
    end
end

function GUIContext:handleHighlight(event)
    if InputEventUtils.hasPosition(event) then
        if self.highlightElement then
            if not self.highlightElement:isPointInside(event.data.x, event.data.y) then
                self:clearHighlight()
            end
        end
    end
end

function GUIContext:handleInput(event)
    self:handleHighlight(event)
    if self:hasModalWindow() then
        local modalWindow = self:getTopModal()
        local blhandled = modalWindow:handleInput(event)
        if not blhandled then
            if event.type == GUIContext.EventType.MOUSE_PRESSED or event.type == GUIContext.EventType.TOUCH_PRESSED then
                modalWindow:dismiss()
            end
        end
        return blhandled
    elseif self.root then
        return self.root:handleInput(event)
    end
    return false
end

function GUIContext:draw()
    if self.root then
        self.root:draw()
    end
    -- Draw modal windows on top
    for _, modalElement in ipairs(self.modalStack) do
        modalElement:draw()
    end
end

-- Modify existing event handlers
function GUIContext:mousepressed(x, y, button)
    local event = InputEventUtils.InputEvent.mousepressed(x, y, button)
    return self:handleInput(event)
end

function GUIContext:mousemoved(x, y, dx, dy)
    --self.root:updatePointerState(x, y)
    local event = InputEventUtils.InputEvent.mousemoved(x, y, dx, dy)
    return self:handleInput(event)
end

function GUIContext:mousereleased(x, y, button)
    local event = InputEventUtils.InputEvent.mousereleased(x, y, button)
    return self:handleInput(event)
end

function GUIContext:touchpressed(id, x, y, dx, dy, pressure)
    local event = InputEventUtils.InputEvent.touchpressed(id, x, y, dx, dy, pressure)
    return self:handleInput(event)
end

function GUIContext:touchmoved(id, x, y, dx, dy, pressure)
    local event = InputEventUtils.InputEvent.touchmoved(id, x, y, dx, dy, pressure)
    return self:handleInput(event)
end

function GUIContext:touchreleased(id, x, y, dx, dy, pressure)
    local event = InputEventUtils.InputEvent.touchreleased(id, x, y, dx, dy, pressure)
    return self:handleInput(event)
end

-- Add handlers for non-positional events
function GUIContext:keypressed(key, scancode, isrepeat)
    local event = InputEventUtils.InputEvent.keypressed(key, scancode, isrepeat)
    return self:handleInput(event)
end

function GUIContext:keyreleased(key, scancode)
    local event = InputEventUtils.InputEvent.keyreleased(key, scancode)
    return self:handleInput(event)
end

function GUIContext:textinput(text)
    local event = InputEventUtils.InputEvent.textinput(text)
    return self:handleInput(event)
end

function GUIContext:wheelmoved(dx, dy)
    local event = InputEventUtils.InputEvent.wheelmoved(dx, dy)
    return self:handleInput(event)
end


return GUIContext