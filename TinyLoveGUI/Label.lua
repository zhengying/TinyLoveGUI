--[[
    Copyright (c) 2023 Your Name

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
local GUIElement = require(cwd .. "GUIElement")

-- Label: A GUI element for displaying text
local Label = GUIElement:extend()

Label.Alignment = {
    LEFT = 1,
    CENTER = 2,
    RIGHT = 3
}

function Label:init(options)
    Label.super.init(self, options)
    options = options or {}

    self.text = options.text or ""
    self.textColor = options.textColor or {1, 1, 0.5, 1}
    self.alignment = options.alignment or Label.Alignment.LEFT
    self.font = options.font or love.graphics.getFont()
    self.borderColor = options.borderColor or {0, 0, 0, 0}  -- Default to transparent border
    self.borderWidth = options.borderWidth or 0
    self.bgcolor = options.bgcolor or {0, 0, 0, 0}
end

function Label:draw()
    if not self.visible then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)

    -- Draw background
    love.graphics.setColor(self.bgcolor[1], self.bgcolor[2], self.bgcolor[3], self.bgcolor[4])
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)

    -- Draw text
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.font)
    local textX, textY

    if self.alignment == Label.Alignment.LEFT then
        textX = 5
    elseif self.alignment == Label.Alignment.CENTER then
        local textWidth = self.font:getWidth(self.text)
        textX = (self.width - textWidth) / 2
    elseif self.alignment == Label.Alignment.RIGHT then
        local textWidth = self.font:getWidth(self.text)
        textX = self.width - textWidth - 5
    end

    textY = (self.height - self.font:getHeight()) / 2

    love.graphics.print(self.text, textX, textY)

    love.graphics.pop()
end

return Label