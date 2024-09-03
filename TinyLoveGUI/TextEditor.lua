local cwd = select(1, ...):match(".+%.") or ""
local GUIElement = require(cwd .. "GUIElement")
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType
local InputEvent = InputEventUtils.InputEvent
local utf8 = require("utf8")

local function utf8_sub(str, start_index, end_index)
    if str == "" then return "" end
    
    start_index = start_index or 1
    end_index = end_index or -1

    if start_index < 1 then start_index = 1 end
    if end_index < 0 then end_index = utf8.len(str) + end_index + 1 end

    if start_index > end_index then return "" end

    local start_byte = utf8.offset(str, start_index)
    local end_byte = utf8.offset(str, end_index + 1)

    if not start_byte then start_byte = 1 end
    if not end_byte then end_byte = #str + 1 end

    return string.sub(str, start_byte, end_byte - 1)
end

-- local function utf8_sub(str, start_index, end_index)
--     if not end_index then
--         end_index = -1
--     end
    
--     local start_byte = utf8.offset(str, start_index)
--     local end_byte
    
--     if end_index >= 0 then
--         end_byte = utf8.offset(str, end_index + 1) - 1
--     else
--         end_byte = utf8.offset(str, utf8.len(str) + end_index + 1) - 1
--     end
    
--     return string.sub(str, start_byte, end_byte)
-- end


-- local a = utf8_sub("1234567890", 1)
-- print(a)

utf8.sub = utf8_sub
local TextEditor = GUIElement:extend()

function TextEditor:init(x, y, width, height, options)
    TextEditor.super.init(self, x, y, width, height)
    self.tag = "TextEditor"
    options = options or {}
    self.text = options.text or ""
    self.font = options.font or love.graphics.getFont()
    self.textColor = options.textColor or {1, 1, 1, 1}
    self.cursorColor = options.cursorColor or {1, 1, 1, 1}
    self.lines = self:splitLines(self.text)
    self.cursorX = 1
    self.cursorY = 1
    self.scrollX = 0
    self.scrollY = 0
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    self.padding = options.padding or 5
    self:setFocusable(true)
    
    self.maxLines = options.maxLines or math.huge
    self.lineHeight = self.font:getHeight() * 1.2

    self.selectionStart = nil
    self.selectionEnd = nil
    self.selectionColor = options.selectionColor or {0.5, 0.5, 1, 0.5}

    self.lastClickTime = 0
    self.clickCount = 0
    self.doubleClickTime = 0.3  -- Adjust this value to change the double-click speed
end

function TextEditor:splitLines(text)
    local lines = {}
    for line in (text.."\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    return lines
end

function TextEditor:joinLines()
    return table.concat(self.lines, "\n")
end

function TextEditor:setText(text)
    self.text = text
    self.lines = self:splitLines(text)
    self.cursorX = 1
    self.cursorY = 1
    self:updateScroll()
end

function TextEditor:getText()
    return self:joinLines()
end

function TextEditor:updateScroll()
    self.cursorY = math.max(1, math.min(self.cursorY, #self.lines))
    local visibleLines = math.floor((self.height - 2 * self.padding) / self.lineHeight)
    
    -- Vertical scrolling
    if self.cursorY < self.scrollY + 1 then
        self.scrollY = self.cursorY - 1
    elseif self.cursorY > self.scrollY + visibleLines then
        self.scrollY = self.cursorY - visibleLines
    end
    
    -- Horizontal scrolling
    local line = self.lines[self.cursorY] or ""
    local lineWidth = self.font:getWidth(utf8_sub(line, 1, self.cursorX - 1))
    if lineWidth < self.scrollX then
        self.scrollX = lineWidth
    elseif lineWidth > self.scrollX + self.width - 2 * self.padding then
        self.scrollX = lineWidth - (self.width - 2 * self.padding)
    end
end

function TextEditor:moveCursor(dx, dy)
    self.cursorY = math.max(1, math.min(self.cursorY + dy, #self.lines))
    local line = self.lines[self.cursorY] or ""
    local lineLength = utf8.len(line)
    if self.cursorX < 1 then
        if self.cursorY > 1 then
            self.cursorY = self.cursorY - 1
            self.cursorX = utf8.len(self.lines[self.cursorY]) + 1
        else
            self.cursorX = 1
        end
    elseif self.cursorX > lineLength + 1 then
        if self.cursorY < #self.lines then
            self.cursorY = self.cursorY + 1
            self.cursorX = 1
        else
            self.cursorX = lineLength + 1
        end
    else
        self.cursorX = self.cursorX + dx
    end
    
    self:updateScroll()
end

function TextEditor:insertCharacter(char)
    local line = self.lines[self.cursorY] or ""
    local before = utf8_sub(line, 1, self.cursorX - 1)
    local after = utf8_sub(line, self.cursorX)
    self.lines[self.cursorY] = before .. char .. after
    self:moveCursor(1, 0)
end

function TextEditor:deleteCharacter()
    local line = self.lines[self.cursorY] or ""
    if self.cursorX > 1 then
        local before = utf8_sub(line, 1, self.cursorX - 2)
        local after = utf8_sub(line, self.cursorX)
        self.lines[self.cursorY] = before .. after
        self:moveCursor(-1, 0)
    elseif self.cursorY > 1 then
        local previousLine = self.lines[self.cursorY - 1] or ""
        self.cursorX = utf8.len(previousLine) + 1
        self.lines[self.cursorY - 1] = previousLine .. line
        table.remove(self.lines, self.cursorY)
        self:moveCursor(0, -1)
    end
end

function TextEditor:insertNewline()
    if #self.lines < self.maxLines then
        local line = self.lines[self.cursorY] or ""
        local before = utf8_sub(line, 1, self.cursorX - 1)
        local after = utf8_sub(line, self.cursorX)
        self.lines[self.cursorY] = before
        table.insert(self.lines, self.cursorY + 1, after)
        self:moveCursor(-self.cursorX + 1, 1)
    end
end

function TextEditor:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Draw background
    love.graphics.setColor(self.bgcolor.r, self.bgcolor.g, self.bgcolor.b)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    -- Set up scissor to clip text
    local globalX, globalY = self:getGlobalPosition()
    love.graphics.setScissor(globalX, globalY, self.width, self.height)
    
    -- Draw text
    love.graphics.setColor(unpack(self.textColor))
    love.graphics.setFont(self.font)
    
    local visibleLines = math.floor((self.height - 2 * self.padding) / self.lineHeight)
    for i = 1, visibleLines do
        local lineIndex = i + self.scrollY
        if lineIndex <= #self.lines then
            local y = (i - 1) * self.lineHeight + self.padding
            love.graphics.print(self.lines[lineIndex], self.padding - self.scrollX, y)
        end
    end
    
    -- Draw cursor
    if self:isFocused() and self.cursorVisible then
        local line = self.lines[self.cursorY] or ""
        local cursorX = self.font:getWidth(utf8_sub(line, 1, self.cursorX - 1)) + self.padding - self.scrollX
        local cursorY = (self.cursorY - self.scrollY - 1) * self.lineHeight + self.padding
        love.graphics.setColor(unpack(self.cursorColor))
        love.graphics.line(cursorX, cursorY, cursorX, cursorY + self.lineHeight)
    end

    -- Draw selection
    if self:hasSelection() then
        local start, endSel = self:getSelectionRange()
        love.graphics.setColor(unpack(self.selectionColor))
        if start and endSel then
        for y = start.y, endSel.y do

            local line = self.lines[y] or ""
            local startX = (y == start.y) and self.font:getWidth(utf8_sub(line, 1, start.x - 1)) or 0
            local endX = (y == endSel.y) and self.font:getWidth(utf8_sub(line, 1, endSel.x - 1)) or self.font:getWidth(line)
            local drawY = (y - self.scrollY - 1) * self.lineHeight + self.padding
            love.graphics.rectangle("fill", self.padding + startX - self.scrollX, drawY, endX - startX, self.lineHeight)
            end
        end
    end
    
    love.graphics.setScissor()
    love.graphics.pop()
end

function TextEditor:update(dt)
    TextEditor.super.update(self, dt)
    if self:isFocused() then
        self.cursorBlinkTime = self.cursorBlinkTime + dt
        if self.cursorBlinkTime > 0.5 then
            self.cursorVisible = not self.cursorVisible
            self.cursorBlinkTime = self.cursorBlinkTime - 0.5
        end
    end
end

-- function TextEditor:onInput(event)
--     if TextEditor.super.onInput(self, event) then
--         return true
--     end

--     if event.type == EventType.KEY_PRESSED then
--         if event.data.key == "left" then
--             self:moveCursor(-1, 0)
--         elseif event.data.key == "right" then
--             self:moveCursor(1, 0)
--         elseif event.data.key == "up" then
--             self:moveCursor(0, -1)
--         elseif event.data.key == "down" then
--             self:moveCursor(0, 1)
--         elseif event.data.key == "backspace" then
--             self:deleteCharacter()
--         elseif event.data.key == "return" then
--             self:insertNewline()
--         end
--         return true
--     elseif event.type == EventType.TEXT_INPUT then
--         self:insertCharacter(event.data.text)
--         return true
--     elseif event.type == EventType.MOUSE_PRESSED then
--         return self:handleMousePress(event.data.x, event.data.y, event.data.button)
--     elseif event.type == EventType.MOUSE_MOVED then
--         return self:handleMouseMove(event.data.x, event.data.y, event.data.dx, event.data.dy)
--     elseif event.type == EventType.MOUSE_RELEASED then
--         return self:handleMouseRelease(event.data.x, event.data.y, event.data.button)
--     elseif event.type == EventType.TOUCH_PRESSED then
--         return self:handleTouchPress(event.data.id, event.data.x, event.data.y)
--     elseif event.type == EventType.TOUCH_MOVED then
--         return self:handleTouchMove(event.data.id, event.data.x, event.data.y, event.data.dx, event.data.dy)
--     elseif event.type == EventType.TOUCH_RELEASED then
--         return self:handleTouchRelease(event.data.id, event.data.x, event.data.y)
--     end
--     return false
-- end

function TextEditor:onInput(event)
    if TextEditor.super.onInput(self, event) then
        return true
    end

    if event.type == EventType.KEY_PRESSED or event.type == EventType.KEY_REPEATED then
        local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        
        if event.data.key == "left" then
            if shift and not self:hasSelection() then
                self:startSelection()
            end
            self:moveCursor(-1, 0)
            if shift then
                self:updateSelection()
            else
                self:clearSelection()
            end
        elseif event.data.key == "right" then
            if shift and not self:hasSelection() then
                self:startSelection()
            end
            self:moveCursor(1, 0)
            if shift then
                self:updateSelection()
            else
                self:clearSelection()
            end
        elseif event.data.key == "up" then
            if shift and not self:hasSelection() then
                self:startSelection()
            end
            self:moveCursor(0, -1)
            if shift then
                self:updateSelection()
            else
                self:clearSelection()
            end
        elseif event.data.key == "down" then
            if shift and not self:hasSelection() then
                self:startSelection()
            end
            self:moveCursor(0, 1)
            if shift then
                self:updateSelection()
            else
                self:clearSelection()
            end
        elseif event.data.key == "backspace" then
            if self:hasSelection() then
                self:deleteSelectedText()
            else
                self:deleteCharacter()
            end
        elseif event.data.key == "delete" then
            if self:hasSelection() then
                self:deleteSelectedText()
            else
                self:deleteCharacterForward()
            end
        elseif event.data.key == "return" or event.data.key == "keypadenter" then
            if self:hasSelection() then
                self:deleteSelectedText()
            end
            self:insertNewline()
        end
        return true
    elseif event.type == EventType.TEXT_INPUT then
        if self:hasSelection() then
            self:deleteSelectedText()
        end
        self:insertCharacter(event.data.text)
        return true
    elseif event.type == EventType.MOUSE_PRESSED then
        return self:handleMousePress(event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_MOVED then
        return self:handleMouseMove(event.data.x, event.data.y, event.data.dx, event.data.dy)
    elseif event.type == EventType.MOUSE_RELEASED then
        return self:handleMouseRelease(event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.TOUCH_PRESSED then
        return self:handleTouchPress(event.data.id, event.data.x, event.data.y)
    elseif event.type == EventType.TOUCH_MOVED then
        return self:handleTouchMove(event.data.id, event.data.x, event.data.y, event.data.dx, event.data.dy)
    elseif event.type == EventType.TOUCH_RELEASED then
        return self:handleTouchRelease(event.data.id, event.data.x, event.data.y)
    end
    return false
end

function TextEditor:handleMousePress(x, y, button)
    if button == 1 then  -- Left mouse button
        self:setFocus()
        local currentTime = love.timer.getTime()
        if currentTime - self.lastClickTime < self.doubleClickTime then
            self.clickCount = self.clickCount + 1
        else
            self.clickCount = 1
        end
        self.lastClickTime = currentTime

        local relativeX = x - self.x + self.scrollX - self.padding
        local relativeY = y - self.y + self.scrollY - self.padding
        self.cursorY = math.floor(relativeY / self.lineHeight) + 1
        self.cursorY = math.max(1, math.min(self.cursorY, #self.lines))
        self.cursorX = self:getClickPosition(self.lines[self.cursorY], relativeX)

        if self.clickCount == 1 then
            self:startSelection()
        elseif self.clickCount == 2 then
            self:selectWord()
        elseif self.clickCount >= 3 then
            self:selectLine()
        end

        self:updateScroll()
        return true
    end
    return false
end

function TextEditor:handleMouseMove(x, y, dx, dy)
    if love.mouse.isDown(1) then  -- Left mouse button
        local relativeX = x - self.x + self.scrollX - self.padding
        local relativeY = y - self.y + self.scrollY - self.padding
        self.cursorY = math.floor(relativeY / self.lineHeight) + 1
        self.cursorY = math.max(1, math.min(self.cursorY, #self.lines))
        self.cursorX = self:getClickPosition(self.lines[self.cursorY], relativeX)
        self:updateSelection()
        self:updateScroll()
        return true
    end
    return false
end

function TextEditor:handleMouseRelease(x, y, button)
    if button == 1 then  -- Left mouse button
        if self.clickCount == 1 and self.selectionStart.x == self.cursorX and self.selectionStart.y == self.cursorY then
            self:clearSelection()
        end
        return true
    end
    return false
end

function TextEditor:handleTouchPress(id, x, y)
    return self:handleMousePress(x, y, 1)
end

function TextEditor:handleTouchMove(id, x, y, dx, dy)
    return self:handleMouseMove(x, y, dx, dy)
end

function TextEditor:handleTouchRelease(id, x, y)
    return self:handleMouseRelease(x, y, 1)
end

function TextEditor:getClickPosition(line, relativeX)
    if not line then
        return 1
    end

    local clickPosition = utf8.len(line)
    for i = 1, utf8.len(line) do
        local width = self.font:getWidth(utf8_sub(line, 1, i))
        if width > relativeX then
            clickPosition = i - 1
            break
        end
    end
    return clickPosition + 1
end

function TextEditor:startSelection()
    self.selectionStart = {x = self.cursorX, y = self.cursorY}
    self.selectionEnd = {x = self.cursorX, y = self.cursorY}
end

function TextEditor:updateSelection()
    self.selectionEnd = {x = self.cursorX, y = self.cursorY}
end

function TextEditor:clearSelection()
    self.selectionStart = nil
    self.selectionEnd = nil
end

function TextEditor:hasSelection()
    return self.selectionStart ~= nil and self.selectionEnd ~= nil
end

function TextEditor:getSelectionRange()
    if not self:hasSelection() then return nil end
    
    local start = self.selectionStart
    local endSel = self.selectionEnd
    
    if start.y > endSel.y or (start.y == endSel.y and start.x > endSel.x) then
        start, endSel = endSel, start
    end
    
    return start, endSel
end

function TextEditor:getSelectedText()
    if not self:hasSelection() then return "" end
    
    local start, endSel = self:getSelectionRange()
    local text = ""
    
    for y = start.y, endSel.y do
        local line = self.lines[y] or ""
        if y == start.y and y == endSel.y then
            text = text .. utf8_sub(line, start.x, endSel.x - 1)
        elseif y == start.y then
            text = text .. utf8_sub(line, start.x) .. "\n"
        elseif y == endSel.y then
            text = text .. utf8_sub(line, 1, endSel.x - 1)
        else
            text = text .. line .. "\n"
        end
    end
    
    return text
end

function TextEditor:deleteSelectedText()
    if not self:hasSelection() then return end
    
    local start, endSel = self:getSelectionRange()
    
    if start.y == endSel.y then
        local line = self.lines[start.y]
        self.lines[start.y] = utf8_sub(line, 1, start.x - 1) .. utf8_sub(line, endSel.x)
    else
        local firstLine = self.lines[start.y]
        local lastLine = self.lines[endSel.y]
        self.lines[start.y] = utf8_sub(firstLine, 1, start.x - 1) .. utf8_sub(lastLine, endSel.x)
        for y = endSel.y, start.y + 1, -1 do
            table.remove(self.lines, y)
        end
    end
    
    self.cursorX = start.x
    self.cursorY = start.y
    self:clearSelection()
    self:updateScroll()
end

function TextEditor:selectWord()
    local line = self.lines[self.cursorY] or ""
    local startX, endX = self:findWordBoundaries(line, self.cursorX)
    self.selectionStart = {x = startX, y = self.cursorY}
    self.selectionEnd = {x = endX, y = self.cursorY}
    self.cursorX = endX
end

function TextEditor:selectLine()
    local line = self.lines[self.cursorY] or ""
    self.selectionStart = {x = 1, y = self.cursorY}
    self.selectionEnd = {x = utf8.len(line) + 1, y = self.cursorY}
    self.cursorX = utf8.len(line) + 1
end

function TextEditor:findWordBoundaries(line, cursorX)
    local startX, endX = cursorX, cursorX
    local pattern = "[%w_]"  -- Consider alphanumeric characters and underscore as part of a word

    -- Find start of the word
    while startX > 1 and utf8_sub(line, startX - 1, startX - 1):match(pattern) do
        startX = startX - 1
    end

    -- Find end of the word
    while endX <= utf8.len(line) and utf8_sub(line, endX, endX):match(pattern) do
        endX = endX + 1
    end

    return startX, endX
end

function TextEditor:onFocusGained()
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    self.isOldRepeat = false
    self.previousKeyRepeatState = love.keyboard.hasKeyRepeat()
    love.keyboard.setKeyRepeat(true)
end

function TextEditor:onFocusLost()
    self.cursorVisible = false
    love.keyboard.setKeyRepeat(self.previousKeyRepeatState)
end

return TextEditor