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
local utf8 = require("utf8")
local cwd = select(1, ...):match(".+%.") or ""
local GUIElement = require(cwd .. "GUIElement")
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType    
local InputEvent = InputEventUtils.InputEvent

local TextField = GUIElement:extend()

local function utf8_sub(str, start_index, end_index)
    if not end_index then
        end_index = -1
    end
    
    local start_byte = utf8.offset(str, start_index)
    local end_byte
    
    if end_index >= 0 then
        end_byte = utf8.offset(str, end_index + 1) - 1
    else
        end_byte = utf8.offset(str, utf8.len(str) + end_index + 1) - 1
    end
    
    return string.sub(str, start_byte, end_byte)
end

function TextField:init(options) 
    TextField.super.init(self, options)
    self.tag = "TextField"
    self.text = options.text or ""
    self.font = options.font or love.graphics.getFont()
    self.textColor = options.textColor or {1, 1, 1, 1}
    self.cursorColor = options.cursorColor or {1, 1, 1, 1}
    self.cursorPosition = utf8.len(self.text)
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    self.focusable = true
    self.focused = false
    self.padding = options.padding or 5
    self:setFocusable(true)
    
    -- New options for text length and input type limits
    self.maxLength = options.maxLength or math.huge
    self.inputType = options.inputType or "any"
    self.customValidate = options.customValidate or nil

    self.textOffset = 0  -- New property to track text offset

    self.selectionStart = nil
    self.selectionEnd = nil
    self.lastClickTime = 0
    self.isDragging = false
end

function TextField:update(dt)
    TextField.super.update(self, dt)
    if self:isFocused() then
        self.cursorBlinkTime = self.cursorBlinkTime + dt
        if self.cursorBlinkTime > 0.5 then
            self.cursorVisible = not self.cursorVisible
            self.cursorBlinkTime = self.cursorBlinkTime - 0.5
        end
    end
end

function TextField:setText(text)
    self.text = text
end

function TextField:onFocusGained()
    self.cursorVisible = true
    self.cursorBlinkTime = 0
end

function TextField:onFocusLost()
    self.cursorVisible = false
end


function TextField:onDraw()
    love.graphics.setColor(self.bgcolor.r, self.bgcolor.g, self.bgcolor.b)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    local globalx, globaly = self:getGlobalPosition()
    love.graphics.setScissor(globalx, globaly, self.width, self.height)
    
    love.graphics.setColor(unpack(self.textColor))
    love.graphics.setFont(self.font)
    
    -- Draw selection
    if self.selectionStart and self.selectionEnd then
        local startX = self.font:getWidth(utf8_sub(self.text, 1, self.selectionStart)) + self.padding - self.textOffset
        local endX = self.font:getWidth(utf8_sub(self.text, 1, self.selectionEnd)) + self.padding - self.textOffset
        love.graphics.setColor(0.5, 0.5, 1, 0.5)
        love.graphics.rectangle("fill", startX, self.padding, endX - startX, self.height - 2 * self.padding)
    end
    
    -- Draw text
    love.graphics.setColor(unpack(self.textColor))
    love.graphics.print(self.text, self.padding - self.textOffset, self.height / 2 - self.font:getHeight() / 2)
    
    -- Draw cursor
    if self:isFocused() and self.cursorVisible and not self.selectionStart then
        local cursorX = self.font:getWidth(utf8_sub(self.text, 1, self.cursorPosition)) + self.padding - self.textOffset
        love.graphics.setColor(unpack(self.cursorColor))
        love.graphics.line(cursorX, self.padding, cursorX, self.height - self.padding)
    end
    
    love.graphics.setScissor()
end

function TextField:getVisibleText()
    local textWidth = self.font:getWidth(self.text)
    local availableWidth = self.width - 2 * self.padding
    
    if textWidth <= availableWidth then
        self.textOffset = 0
        return self.text
    else
        local visibleText = self.text
        self.textOffset = textWidth - availableWidth
        return visibleText
    end
end


function TextField:validateInput(text)
    -- First, check custom validation if provided
    if self.customValidate then
        return self.customValidate(text)
    end

    if self.inputType == "any" then
        return true
    elseif self.inputType == "number" then
        return text:match("^%d+$") ~= nil
    elseif self.inputType == "alphabet" then
        return text:match("^%a+$") ~= nil
    elseif self.inputType == "alphanumeric" then
        return text:match("^%w+$") ~= nil
    end
    return false
end


function TextField:updateTextOffset()
    local textWidth = self.font:getWidth(self.text)
    local availableWidth = self.width - 2 * self.padding
    local cursorX = self.font:getWidth(utf8_sub(self.text, 1, self.cursorPosition))
    
    if textWidth > availableWidth then
        if cursorX - self.textOffset < self.padding then
            self.textOffset = cursorX - self.padding
        elseif cursorX - self.textOffset > availableWidth - self.padding then
            self.textOffset = cursorX - availableWidth + self.padding
        end
    else
        self.textOffset = 0
    end
    
    self.textOffset = math.max(0, math.min(self.textOffset, textWidth - availableWidth))
end

local function handleMousePress(self, x, y, button)
    if button == 1 then  -- Left mouse button
        self:setFocus()
        local relativeX = x + self.textOffset - self.padding
        local clickPosition = self:getClickPosition(relativeX)
        
        local currentTime = love.timer.getTime()
        if currentTime - self.lastClickTime < 0.3 then
            -- Double click
            self.selectionStart = 0
            self.selectionEnd = utf8.len(self.text)
        else
            -- Single click
            self.cursorPosition = clickPosition
            self.selectionStart = nil
            self.selectionEnd = nil
            self.isDragging = true
        end
        
        self.lastClickTime = currentTime
        self:updateTextOffset()
        return true
    end
    return false
end

local function handleMouseMove(self, x, y, dx, dy)
    if self.isDragging then
        local relativeX = x + self.textOffset - self.padding
        local dragPosition = self:getClickPosition(relativeX)
        
        if not self.selectionStart then
            self.selectionStart = self.cursorPosition
        end
        self.selectionEnd = dragPosition
        self.cursorPosition = dragPosition
        
        if self.selectionStart > self.selectionEnd then
            self.selectionStart, self.selectionEnd = self.selectionEnd, self.selectionStart
        end
        
        self:updateTextOffset()
        return true
    end
    return false
end

local function handleMouseRelease(self, x, y, button)
    if button == 1 then  -- Left mouse button
        self.isDragging = false
        return true
    end
    return false
end

local function handleKeyPress(self, key, scancode, isrepeat)
    if not self:isFocused() then return false end

    if key == "left" then
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            if not self.selectionStart then
                self.selectionStart = self.cursorPosition
            end
            self.cursorPosition = math.max(0, self.cursorPosition - 1)
            self.selectionEnd = self.cursorPosition
        else
            self.cursorPosition = math.max(0, self.cursorPosition - 1)
            self.selectionStart = nil
            self.selectionEnd = nil
        end
    elseif key == "right" then
        if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
            if not self.selectionStart then
                self.selectionStart = self.cursorPosition
            end
            self.cursorPosition = math.min(utf8.len(self.text), self.cursorPosition + 1)
            self.selectionEnd = self.cursorPosition
        else
            self.cursorPosition = math.min(utf8.len(self.text), self.cursorPosition + 1)
            self.selectionStart = nil
            self.selectionEnd = nil
        end
    elseif key == "backspace" then
        if self.selectionStart and self.selectionEnd then
            local before = utf8_sub(self.text, 1, self.selectionStart)
            local after = utf8_sub(self.text, self.selectionEnd + 1)
            self.text = before .. after
            self.cursorPosition = self.selectionStart
            self.selectionStart = nil
            self.selectionEnd = nil
        elseif self.cursorPosition > 0 then
            local before = utf8_sub(self.text, 1, self.cursorPosition - 1)
            local after = utf8_sub(self.text, self.cursorPosition + 1)
            self.text = before .. after
            self.cursorPosition = self.cursorPosition - 1
        end
    elseif key == "delete" then
        if self.selectionStart and self.selectionEnd then
            local before = utf8_sub(self.text, 1, self.selectionStart)
            local after = utf8_sub(self.text, self.selectionEnd + 1)
            self.text = before .. after
            self.cursorPosition = self.selectionStart
            self.selectionStart = nil
            self.selectionEnd = nil
        elseif self.cursorPosition < utf8.len(self.text) then
            local before = utf8_sub(self.text, 1, self.cursorPosition)
            local after = utf8_sub(self.text, self.cursorPosition + 2)
            self.text = before .. after
        end
    elseif key == "return" or key == "escape" then
        -- clear focus maybe no need
    end
    self:updateTextOffset()  -- Update text offset after changing cursor position or text
    return true
end

local function handleTextInput(self, text)
    if self:isFocused() then
        local newTextLength = utf8.len(self.text)
        local replacementLength = 0

        -- If there's a selection, calculate the length of text to be replaced
        if self.selectionStart and self.selectionEnd then
            newTextLength = newTextLength - (self.selectionEnd - self.selectionStart)
            replacementLength = self.selectionEnd - self.selectionStart
        end

        -- Check if adding the new text would exceed the maxLength
        if newTextLength + utf8.len(text) <= self.maxLength then
            -- Validate input based on inputType
            if self:validateInput(text) then
                if self.selectionStart and self.selectionEnd then
                    -- Replace selected text
                    local before = utf8_sub(self.text, 1, self.selectionStart)
                    local after = utf8_sub(self.text, self.selectionEnd + 1)
                    self.text = before .. text .. after
                    self.cursorPosition = self.selectionStart + utf8.len(text)
                    self.selectionStart = nil
                    self.selectionEnd = nil
                else
                    -- Insert text at cursor position
                    local before = utf8_sub(self.text, 1, self.cursorPosition)
                    local after = utf8_sub(self.text, self.cursorPosition + 1)
                    self.text = before .. text .. after
                    self.cursorPosition = self.cursorPosition + utf8.len(text)
                end
                self:updateTextOffset()  -- Update text offset after changing text
                return true
            end
        end
    end
    return false
end

local function handleTouchPress(self, id, x, y)
    -- Implement touch press handling (similar to mouse press)
    return self:handleMousePress(x, y, 1)
end

local function handleTouchMove(self, id, x, y, dx, dy)
    -- Implement touch move handling (similar to mouse move)
    return self:handleMouseMove(x, y, dx, dy)
end

local function handleTouchRelease(self, id, x, y)
    -- Implement touch release handling (similar to mouse release)
    return self:handleMouseRelease(x, y, 1)
end


function TextField:onInput(event)
    if TextField.super.onInput(self, event) then
        return true
    end

    if event.type == EventType.MOUSE_PRESSED then
        return handleMousePress(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_MOVED then
        return handleMouseMove(self, event.data.x, event.data.y, event.data.dx, event.data.dy)
    elseif event.type == EventType.MOUSE_RELEASED then
        return handleMouseRelease(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.KEY_PRESSED then
        return handleKeyPress(self, event.data.key, event.data.scancode, event.data.isrepeat)
    elseif event.type == EventType.TEXT_INPUT then
        return handleTextInput(self, event.data.text)
    elseif event.type == EventType.TOUCH_PRESSED then
        return handleTouchPress(self, event.data.id, event.data.x, event.data.y)
    elseif event.type == EventType.TOUCH_MOVED then
        return handleTouchMove(self, event.data.id, event.data.x, event.data.y, event.data.dx, event.data.dy)
    elseif event.type == EventType.TOUCH_RELEASED then
        return handleTouchRelease(self, event.data.id, event.data.x, event.data.y)
    end
    return false
end

function TextField:getClickPosition(relativeX)
    local clickPosition = utf8.len(self.text)
    for i = 1, utf8.len(self.text) do
        local width = self.font:getWidth(utf8_sub(self.text, 1, i))
        if width > relativeX then
            clickPosition = i - 1
            break
        end
    end
    return clickPosition
end

return TextField