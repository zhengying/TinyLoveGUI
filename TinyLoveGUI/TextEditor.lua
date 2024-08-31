
local cwd = select(1, ...):match(".+%.") or ""
local GUIElement = require(cwd .. "GUIElement")
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType
local InputEvent = InputEventUtils.InputEvent
local utf8 = require("utf8")

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
    local visibleLines = math.floor((self.height - 2 * self.padding) / self.lineHeight)
    
    -- Vertical scrolling
    if self.cursorY < self.scrollY + 1 then
        self.scrollY = self.cursorY - 1
    elseif self.cursorY > self.scrollY + visibleLines then
        self.scrollY = self.cursorY - visibleLines
    end
    
    -- Horizontal scrolling
    local lineWidth = self.font:getWidth(self.lines[self.cursorY]:sub(1, self.cursorX - 1))
    if lineWidth < self.scrollX then
        self.scrollX = lineWidth
    elseif lineWidth > self.scrollX + self.width - 2 * self.padding then
        self.scrollX = lineWidth - (self.width - 2 * self.padding)
    end
end

function TextEditor:moveCursor(dx, dy)
    self.cursorX = self.cursorX + dx
    self.cursorY = self.cursorY + dy
    
    if self.cursorY < 1 then self.cursorY = 1 end
    if self.cursorY > #self.lines then self.cursorY = #self.lines end
    
    local lineLength = utf8.len(self.lines[self.cursorY])
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
    end
    
    self:updateScroll()
end

function TextEditor:insertCharacter(char)
    local line = self.lines[self.cursorY]
    local before = utf8.sub(line, 1, self.cursorX - 1)
    local after = utf8.sub(line, self.cursorX)
    self.lines[self.cursorY] = before .. char .. after
    self:moveCursor(1, 0)
end

function TextEditor:deleteCharacter()
    local line = self.lines[self.cursorY]
    if self.cursorX > 1 then
        local before = utf8.sub(line, 1, self.cursorX - 2)
        local after = utf8.sub(line, self.cursorX)
        self.lines[self.cursorY] = before .. after
        self:moveCursor(-1, 0)
    elseif self.cursorY > 1 then
        local previousLine = self.lines[self.cursorY - 1]
        self.cursorX = utf8.len(previousLine) + 1
        self.lines[self.cursorY - 1] = previousLine .. line
        table.remove(self.lines, self.cursorY)
        self:moveCursor(0, -1)
    end
end

function TextEditor:insertNewline()
    if #self.lines < self.maxLines then
        local line = self.lines[self.cursorY]
        local before = utf8.sub(line, 1, self.cursorX - 1)
        local after = utf8.sub(line, self.cursorX)
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
        local cursorX = self.font:getWidth(utf8.sub(self.lines[self.cursorY], 1, self.cursorX - 1)) + self.padding - self.scrollX
        local cursorY = (self.cursorY - self.scrollY - 1) * self.lineHeight + self.padding
        love.graphics.setColor(unpack(self.cursorColor))
        love.graphics.line(cursorX, cursorY, cursorX, cursorY + self.lineHeight)
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

function TextEditor:onInput(event)
    if event.type == EventType.KEY_PRESSED then
        if event.data.key == "left" then
            self:moveCursor(-1, 0)
        elseif event.data.key == "right" then
            self:moveCursor(1, 0)
        elseif event.data.key == "up" then
            self:moveCursor(0, -1)
        elseif event.data.key == "down" then
            self:moveCursor(0, 1)
        elseif event.data.key == "backspace" then
            self:deleteCharacter()
        elseif event.data.key == "return" then
            self:insertNewline()
        end
        return true
    elseif event.type == EventType.TEXT_INPUT then
        self:insertCharacter(event.data.text)
        return true
    end
    return false
end

return TextEditor