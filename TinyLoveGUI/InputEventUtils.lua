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

local InputEvent = Object:extend()

-- Define an enum-like table for event types
local EventType = {
    -- Mouse events
    MOUSE_PRESSED = "mousepressed",
    MOUSE_RELEASED = "mousereleased",
    MOUSE_MOVED = "mousemoved",
    
    -- Touch events
    TOUCH_PRESSED = "touchpressed",
    TOUCH_RELEASED = "touchreleased",
    TOUCH_MOVED = "touchmoved",
    
    -- Keyboard events
    KEY_PRESSED = "keypressed",
    KEY_RELEASED = "keyreleased",
    TEXT_INPUT = "textinput",
    
    -- Wheel event
    WHEEL_MOVED = "wheelmoved",
    
    -- Gamepad events (if needed)
    GAMEPAD_PRESSED = "gamepadpressed",
    GAMEPAD_RELEASED = "gamepadreleased",
    GAMEPAD_AXIS = "gamepadaxis",
    
    -- Add more event types as needed
}

local KeyCode = {
    A = "a",
    B = "b",
    C = "c",
    D = "d",
    E = "e",
    F = "f",
    G = "g",
    H = "h",
    I = "i",
    J = "j",
    K = "k",
    L = "l",
    M = "m",
    N = "n",
    O = "o",
    P = "p",
    Q = "q",
    R = "r",
    S = "s",
    T = "t",
    U = "u",
    V = "v",
    W = "w",
    X = "x",
    Y = "y",
    Z = "z",
    TAB = "tab",
    RETURN = "return",
    ESCAPE = "escape",
    SPACE = "space",
    LEFT = "left",
    RIGHT = "right",
    UP = "up",
    DOWN = "down",
    F1 = "f1",
    F2 = "f2",
    F3 = "f3",
    F4 = "f4",
    F5 = "f5",
    F6 = "f6",
    F7 = "f7",
    F8 = "f8",
    F9 = "f9",
    F10 = "f10",
    F11 = "f11",
    F12 = "f12",
    M1 = "m1",
    M2 = "m2",
    M3 = "m3",
}


function InputEvent:init(eventType, data)
    self.type = eventType  -- "pressed", "released", "moved"
    self.data = data or {}
end


local function hasPosition(event)
    return event.data.x ~= nil and event.data.y ~= nil
end

function InputEvent.mousepressed(x, y, button, istouch, presses)
    return InputEvent("mousepressed", {x = x, y = y, button = button, istouch = istouch, presses = presses})
end

function InputEvent.mousereleased(x, y, button, istouch, presses)
    return InputEvent("mousereleased", {x = x, y = y, button = button, istouch = istouch, presses = presses})
end

function InputEvent.mousemoved(x, y, dx, dy)
    return InputEvent("mousemoved", {x = x, y = y, dx = dx, dy = dy})
end

function InputEvent.textinput(text)
    return InputEvent("textinput", {text = text})
end

function InputEvent.keypressed(key, scancode, isrepeat)
    return InputEvent("keypressed", {key = key, scancode = scancode, isrepeat = isrepeat})
end

function InputEvent.keyreleased(key, scancode, isrepeat)
    return InputEvent("keyreleased", {key = key, scancode = scancode, isrepeat = isrepeat})
end

function InputEvent.wheelmoved(dx, dy)
    local x, y = love.mouse.getPosition() 
    return InputEvent("wheelmoved", {x = x, y = y, dx = dx, dy = dy})
end 

function InputEvent.touchpressed(id, x, y, dx, dy, pressure)
    return InputEvent("touchpressed", {id = id, x = x, y = y, dx = dx, dy = dy, pressure = pressure})
end
function InputEvent.touchreleased(id, x, y, dx, dy, pressure)
    return InputEvent("touchreleased", {id = id, x = x, y = y, dx = dx, dy = dy, pressure = pressure})
end

function InputEvent.touchmoved(id, x, y, dx, dy, pressure)
    return InputEvent("touchmoved", {id = id, x = x, y = y, dx = dx, dy = dy, pressure = pressure})
end

function InputEvent.gamepadpressed(joystick, button)
    return InputEvent("gamepadpressed", {joystick = joystick, button = button})
end

function InputEvent.gamepadreleased(joystick, button)
    return InputEvent("gamepadreleased", {joystick = joystick, button = button})
end

function InputEvent.gamepadaxis(joystick, axis, value)
    return InputEvent("gamepadaxis", {joystick = joystick, axis = axis, value = value})
end 

function InputEvent.gamepadhat(joystick, hat, direction)
    return InputEvent("gamepadhat", {joystick = joystick, hat = hat, direction = direction})
end 

function InputEvent.gamepadadded(joystick)
    return InputEvent("gamepadadded", {joystick = joystick})
end

function InputEvent.gamepadremoved(joystick)
    return InputEvent("gamepadremoved", {joystick = joystick})
end

function InputEvent.joystickadded(joystick)
    return InputEvent("joystickadded", {joystick = joystick})
end

function InputEvent.joystickremoved(joystick)
    return InputEvent("joystickremoved", {joystick = joystick})
end

function InputEvent.joystickaxis(joystick, axis, value)
    return InputEvent("joystickaxis", {joystick = joystick, axis = axis, value = value})
end

function InputEvent.joystickhat(joystick, hat, direction)
    return InputEvent("joystickhat", {joystick = joystick, hat = hat, direction = direction})
end 

function InputEvent.joystickpressed(joystick, button)
    return InputEvent("joystickpressed", {joystick = joystick, button = button})
end

function InputEvent.joystickreleased(joystick, button)
    return InputEvent("joystickreleased", {joystick = joystick, button = button})
end


return {
    EventType = EventType,
    InputEvent = InputEvent,
    KeyCode = KeyCode,
    hasPosition = hasPosition
}