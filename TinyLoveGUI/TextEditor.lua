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

utf8.sub = utf8_sub
local TextEditor = GUIElement:extend()

function TextEditor:init(options) 
    TextEditor.super.init(self, options)
    self.tag = "TextEditor"
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
    self.lineHeight = self.font:getHeight() * 1.1

    self.selectionStart = nil
    self.selectionEnd = nil
    self.selectionColor = options.selectionColor or {0.5, 0.5, 1, 0.5}

    self.lastClickTime = 0
    self.clickCount = 0
    self.doubleClickTime = 0.3  -- Adjust this value to change the double-click speed

    self.scrollbarWidth = options.scrollbarWidth or 10
    self.scrollbarColor = options.scrollbarColor or {0.5, 0.5, 0.5, 1}
    self.scrollbarHandleColor = options.scrollbarHandleColor or {0.7, 0.7, 0.7, 1}
    self.isDraggingScrollbar = false
    self.scrollbarDragOffset = 0

    self.totalScrollableLines = 0
    self.visibleLines = 0
    self.maxLineWidth = 0
    self.horizontalScrollbarHeight = options.horizontalScrollbarHeight or 10
    self.horizontalScrollbarColor = options.horizontalScrollbarColor or {0.5, 0.5, 0.5, 1}
    self.horizontalScrollbarHandleColor = options.horizontalScrollbarHandleColor or {0.7, 0.7, 0.7, 1}
    self.isDraggingHorizontalScrollbar = false
    self.horizontalScrollbarDragOffset = 0
    
    self:updateScrollInfo()
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

function TextEditor:updateScrollInfo()
    self.visibleLines = math.floor((self.height - 2 * self.padding - self.horizontalScrollbarHeight) / self.lineHeight)
    self.totalScrollableLines = math.max(0, #self.lines - self.visibleLines)
    
    self.maxLineWidth = 0
    for _, line in ipairs(self.lines) do
        self.maxLineWidth = math.max(self.maxLineWidth, self.font:getWidth(line))
    end
end

function TextEditor:updateScroll()
    self:updateScrollInfo()
    self.scrollY = math.max(0, math.min(self.scrollY, self.totalScrollableLines))
    self.scrollX = math.max(0, math.min(self.scrollX, self.maxLineWidth - self.width + self.scrollbarWidth + 2 * self.padding))
end

function TextEditor:moveCursor(dx, dy)
    if dy ~= 0 then
        self.cursorY = math.max(1, math.min(self.cursorY + dy, #self.lines))
        local line = self.lines[self.cursorY] or ""
        self.cursorX = math.min(self.cursorX, utf8.len(line) + 1)
    else
        self:moveCursorByUTF8Chars(dx)
    end
    
    self:ensureCursorVisible()
end

function TextEditor:moveCursorByUTF8Chars(chars)
    local line = self.lines[self.cursorY] or ""
    local newCursorX = self.cursorX + chars
    
    if newCursorX > utf8.len(line) + 1 then
        newCursorX = utf8.len(line) + 1
    elseif newCursorX < 1 then
        newCursorX = 1
    end
    
    self.cursorX = newCursorX
    self:ensureCursorVisible()
end

function TextEditor:insertCharacter(text)
    local line = self.lines[self.cursorY] or ""
    local before = utf8_sub(line, 1, self.cursorX - 1)
    local after = utf8_sub(line, self.cursorX)
    self.lines[self.cursorY] = before .. text .. after
    self:moveCursorByUTF8Chars(utf8.len(text))
    self:updateScroll()
    self:ensureCursorVisible()
end

function TextEditor:deleteCharacter()
    local line = self.lines[self.cursorY] or ""
    if self.cursorX > 1 then
        local before = utf8_sub(line, 1, self.cursorX - 2)
        local after = utf8_sub(line, self.cursorX)
        self.lines[self.cursorY] = before .. after
        self:moveCursorByUTF8Chars(-1)
    elseif self.cursorY > 1 then
        local previousLine = self.lines[self.cursorY - 1] or ""
        self.cursorX = utf8.len(previousLine) + 1
        self.lines[self.cursorY - 1] = previousLine .. line
        table.remove(self.lines, self.cursorY)
        self.cursorY = self.cursorY - 1
    end
    self:updateScroll()
end

function TextEditor:deleteCharacterForward()
    local line = self.lines[self.cursorY] or ""
    if self.cursorX <= utf8.len(line) then
        local before = utf8_sub(line, 1, self.cursorX - 1)
        local after = utf8_sub(line, self.cursorX + 1)
        self.lines[self.cursorY] = before .. after
    elseif self.cursorY < #self.lines then
        local nextLine = self.lines[self.cursorY + 1] or ""
        self.lines[self.cursorY] = line .. nextLine
        table.remove(self.lines, self.cursorY + 1)
    end
    self:updateScroll()
end

function TextEditor:insertNewline()
    local currentLine = self.lines[self.cursorY] or ""
    local beforeCursor = utf8_sub(currentLine, 1, self.cursorX - 1)
    local afterCursor = utf8_sub(currentLine, self.cursorX)
    
    self.lines[self.cursorY] = beforeCursor
    table.insert(self.lines, self.cursorY + 1, afterCursor)
    
    self.cursorY = self.cursorY + 1
    self.cursorX = 1
    
    self:updateScroll()
    self:ensureCursorVisible()
end

function TextEditor:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Draw background
    love.graphics.setColor(self.bgcolor.r, self.bgcolor.g, self.bgcolor.b)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    -- Set up scissor to clip text
    local globalX, globalY = self:getGlobalPosition()
    
    local text_area_width = self.width - self.scrollbarWidth
    local text_area_height = self.height - self.horizontalScrollbarHeight

    if text_area_width < 0 then
        text_area_width = 50
    end
    if text_area_height < 0 then
        text_area_height = 50
    end 

    love.graphics.intersectScissor(globalX, globalY, text_area_width, text_area_height)
    
    -- Draw text
    love.graphics.setColor(unpack(self.textColor))
    love.graphics.setFont(self.font)
    
    for i = 1, self.visibleLines do
        local lineIndex = i + self.scrollY
        if lineIndex <= #self.lines then
            local y = (i - 1) * self.lineHeight + self.padding
            love.graphics.print(self.lines[lineIndex], self.padding - self.scrollX, y)
        end
    end
    
    -- Draw cursor only if it's within the visible area
    if self:isFocused() and self.cursorVisible and self.cursorY > self.scrollY and self.cursorY <= self.scrollY + self.visibleLines then
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
    
    -- Draw vertical scrollbar
    self:drawVerticalScrollbar()
    
    -- Draw horizontal scrollbar
    self:drawHorizontalScrollbar()
    
    love.graphics.pop()
end

function TextEditor:drawVerticalScrollbar()
    local totalLines = #self.lines
    local visibleLines = math.floor((self.height - 2 * self.padding - self.horizontalScrollbarHeight) / self.lineHeight)
    
    if totalLines > visibleLines then
        local scrollbarHeight = self.height - self.horizontalScrollbarHeight
        local handleHeight = math.max(20, scrollbarHeight * (visibleLines / totalLines))
        local handleY = (self.scrollY / self.totalScrollableLines) * (scrollbarHeight - handleHeight)
        
        -- Draw scrollbar background
        love.graphics.setColor(unpack(self.scrollbarColor))
        love.graphics.rectangle("fill", self.width - self.scrollbarWidth, 0, self.scrollbarWidth, scrollbarHeight)
        
        -- Draw scrollbar handle
        love.graphics.setColor(unpack(self.scrollbarHandleColor))
        love.graphics.rectangle("fill", self.width - self.scrollbarWidth, handleY, self.scrollbarWidth, handleHeight)
    end
end

function TextEditor:drawHorizontalScrollbar()
    local totalWidth = self.maxLineWidth + 2 * self.padding
    local visibleWidth = self.width - self.scrollbarWidth
    
    if totalWidth > visibleWidth then
        local scrollbarWidth = self.width - self.scrollbarWidth
        local handleWidth = math.max(20, scrollbarWidth * (visibleWidth / totalWidth))
        local handleX = (self.scrollX / (totalWidth - visibleWidth)) * (scrollbarWidth - handleWidth)
        
        -- Draw scrollbar background
        love.graphics.setColor(unpack(self.horizontalScrollbarColor))
        love.graphics.rectangle("fill", 0, self.height - self.horizontalScrollbarHeight, scrollbarWidth, self.horizontalScrollbarHeight)
        
        -- Draw scrollbar handle
        love.graphics.setColor(unpack(self.horizontalScrollbarHandleColor))
        love.graphics.rectangle("fill", handleX, self.height - self.horizontalScrollbarHeight, handleWidth, self.horizontalScrollbarHeight)
    end
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

function TextEditor:onInput(event)
    if TextEditor.super.onInput(self, event) then
        return true
    end

    if event.type == EventType.MOUSE_PRESSED then
        return self:handleMousePress(event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_MOVED then
        return self:handleMouseMove(event.data.x, event.data.y, event.data.dx, event.data.dy)
    elseif event.type == EventType.MOUSE_RELEASED then
        return self:handleMouseRelease(event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.WHEEL_MOVED then
        return self:handleMouseWheel(event.data.dy)
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
    end
    return false
end

function TextEditor:handleMousePress(x, y, button)
    if button == 1 then  -- Left mouse button
        local relativeX = x - self.x
        local relativeY = y - self.y
        
        -- Check if the click is on the vertical scrollbar area
        if relativeX >= self.width - self.scrollbarWidth and relativeY < self.height - self.horizontalScrollbarHeight then
            self:handleVerticalScrollbarClick(relativeY)
            return true
        end
        
        -- Check if the click is on the horizontal scrollbar area
        if relativeY >= self.height - self.horizontalScrollbarHeight and relativeX < self.width - self.scrollbarWidth then
            self:handleHorizontalScrollbarClick(relativeX)
            return true
        end
        
        self:setFocus()
        local currentTime = love.timer.getTime()
        if currentTime - self.lastClickTime < self.doubleClickTime then
            self.clickCount = self.clickCount + 1
        else
            self.clickCount = 1
            if self:hasSelection() then
                self:clearSelection()
            end
        end
        self.lastClickTime = currentTime

        local relativeX = x - self.x + self.scrollX - self.padding
        local relativeY = y - self.y - self.padding
        local newCursorY = math.floor(relativeY / self.lineHeight) + self.scrollY + 1
        newCursorY = math.max(1, math.min(newCursorY, #self.lines))
        local newCursorX = self:getClickPosition(self.lines[newCursorY], relativeX)

        -- Clear selection if clicking outside the current selection
        if self:hasSelection() then
            if not self:isPositionInSelection(newCursorX, newCursorY) then
                self:clearSelection()
            end
        end

        self.cursorX = newCursorX
        self.cursorY = newCursorY

        self:startSelection()

        if self.clickCount == 2 then
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
    local relativeX = x - self.x
    local relativeY = y - self.y

    if self.isDraggingScrollbar then
        self:updateVerticalScrollbarDrag(relativeY)
        return true
    elseif self.isDraggingHorizontalScrollbar then
        self:updateHorizontalScrollbarDrag(relativeX)
        return true
    elseif love.mouse.isDown(1) then  -- Left mouse button
        local relativeX = x - self.x + self.scrollX - self.padding
        local relativeY = y - self.y - self.padding
        self.cursorY = math.floor(relativeY / self.lineHeight) + self.scrollY + 1
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
        if self.isDraggingScrollbar then
            self.isDraggingScrollbar = false
            return true
        end
        if self.isDraggingHorizontalScrollbar then
            self.isDraggingHorizontalScrollbar = false
            return true
        end
        if self.clickCount == 1 and self.selectionStart then
            if self.selectionStart.x == self.cursorX and self.selectionStart.y == self.cursorY then
                self:clearSelection()
            end
        end
        return true
    end
    return false
end

function TextEditor:handleMouseWheel(dy)
    local scrollSpeed = 3  -- Adjust this value to change scroll speed
    self.scrollY = math.max(0, math.min(self.scrollY - dy * scrollSpeed, self.totalScrollableLines))
    self:updateScroll()
    return true
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
    if not self.selectionStart then
        self.selectionStart = {x = self.cursorX, y = self.cursorY}
        self.selectionEnd = {x = self.cursorX, y = self.cursorY}
    end
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

    if not (start and endSel) then return "" end

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

    if not (start and endSel) then return end
    
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

function TextEditor:handleVerticalScrollbarClick(relativeY)
    self:updateScrollInfo()
    local scrollbarHeight = self.height - self.horizontalScrollbarHeight
    local handleHeight = math.max(20, scrollbarHeight * (self.visibleLines / #self.lines))
    
    local handleY = (self.scrollY / self.totalScrollableLines) * (scrollbarHeight - handleHeight)
    
    -- Check if click is on the handle
    if relativeY >= handleY and relativeY <= handleY + handleHeight then
        self:startVerticalScrollbarDrag(relativeY)
    else
        -- Click is on the track, move the handle to this position
        local newScrollY = ((relativeY - handleHeight / 2) / (scrollbarHeight - handleHeight)) * self.totalScrollableLines
        self.scrollY = math.max(0, math.min(math.floor(newScrollY), self.totalScrollableLines))
        self:updateScroll()
    end
end

function TextEditor:startVerticalScrollbarDrag(relativeY)
    self.isDraggingScrollbar = true
    self:updateScrollInfo()
    local scrollbarHeight = self.height - self.horizontalScrollbarHeight
    local handleHeight = math.max(20, scrollbarHeight * (self.visibleLines / #self.lines))
    local handleY = (self.scrollY / self.totalScrollableLines) * (scrollbarHeight - handleHeight)
    self.scrollbarDragOffset = relativeY - handleY
end

function TextEditor:updateVerticalScrollbarDrag(relativeY)
    self:updateScrollInfo()
    local scrollbarHeight = self.height - self.horizontalScrollbarHeight
    local handleHeight = math.max(20, scrollbarHeight * (self.visibleLines / #self.lines))
    
    local newHandleY = relativeY - self.scrollbarDragOffset
    newHandleY = math.max(0, math.min(newHandleY, scrollbarHeight - handleHeight))
    
    local newScrollY = (newHandleY / (scrollbarHeight - handleHeight)) * self.totalScrollableLines
    self.scrollY = math.max(0, math.min(math.floor(newScrollY), self.totalScrollableLines))
    self:updateScroll()
end

function TextEditor:handleHorizontalScrollbarClick(relativeX)
    self:updateScrollInfo()
    local scrollbarWidth = self.width - self.scrollbarWidth
    local handleWidth = math.max(20, scrollbarWidth * ((self.width - self.scrollbarWidth) / (self.maxLineWidth + 2 * self.padding)))
    
    local handleX = (self.scrollX / (self.maxLineWidth - self.width + self.scrollbarWidth + 2 * self.padding)) * (scrollbarWidth - handleWidth)
    
    -- Check if click is on the handle
    if relativeX >= handleX and relativeX <= handleX + handleWidth then
        self:startHorizontalScrollbarDrag(relativeX)
    else
        -- Click is on the track, move the handle to this position
        local newScrollX = ((relativeX - handleWidth / 2) / (scrollbarWidth - handleWidth)) * (self.maxLineWidth - self.width + self.scrollbarWidth + 2 * self.padding)
        self.scrollX = math.max(0, math.min(math.floor(newScrollX), self.maxLineWidth - self.width + self.scrollbarWidth + 2 * self.padding))
        self:updateScroll()
    end
end

function TextEditor:startHorizontalScrollbarDrag(relativeX)
    self.isDraggingHorizontalScrollbar = true
    self:updateScrollInfo()
    local scrollbarWidth = self.width - self.scrollbarWidth
    local handleWidth = math.max(20, scrollbarWidth * ((self.width - self.scrollbarWidth) / (self.maxLineWidth + 2 * self.padding)))
    local handleX = (self.scrollX / (self.maxLineWidth - self.width + self.scrollbarWidth + 2 * self.padding)) * (scrollbarWidth - handleWidth)
    self.horizontalScrollbarDragOffset = relativeX - handleX
end

function TextEditor:updateHorizontalScrollbarDrag(relativeX)
    self:updateScrollInfo()
    local scrollbarWidth = self.width - self.scrollbarWidth
    local handleWidth = math.max(20, scrollbarWidth * ((self.width - self.scrollbarWidth) / (self.maxLineWidth + 2 * self.padding)))
    
    local newHandleX = relativeX - self.horizontalScrollbarDragOffset
    newHandleX = math.max(0, math.min(newHandleX, scrollbarWidth - handleWidth))
    
    local newScrollX = (newHandleX / (scrollbarWidth - handleWidth)) * (self.maxLineWidth - self.width + self.scrollbarWidth + 2 * self.padding)
    self.scrollX = math.max(0, math.min(math.floor(newScrollX), self.maxLineWidth - self.width + self.scrollbarWidth + 2 * self.padding))
    self:updateScroll()
end

function TextEditor:isPositionInSelection(x, y)
    if not self:hasSelection() then
        return false
    end

    local start, endSel = self:getSelectionRange()
    
    if y < start.y or y > endSel.y then
        return false
    elseif y == start.y and y == endSel.y then
        return x >= start.x and x < endSel.x
    elseif y == start.y then
        return x >= start.x
    elseif y == endSel.y then
        return x < endSel.x
    else
        return true
    end
end

function TextEditor:ensureCursorVisible()
    -- Vertical scrolling
    if self.cursorY <= self.scrollY then
        self.scrollY = self.cursorY - 1
    elseif self.cursorY > self.scrollY + self.visibleLines then
        self.scrollY = self.cursorY - self.visibleLines
    end

    -- Horizontal scrolling
    local cursorXPixels = self.font:getWidth(utf8_sub(self.lines[self.cursorY] or "", 1, self.cursorX - 1))
    local visibleWidth = self.width - self.scrollbarWidth - 2 * self.padding

    if cursorXPixels < self.scrollX then
        self.scrollX = cursorXPixels
    elseif cursorXPixels > self.scrollX + visibleWidth then
        self.scrollX = cursorXPixels - visibleWidth
    end

    self:updateScroll()
end

return TextEditor