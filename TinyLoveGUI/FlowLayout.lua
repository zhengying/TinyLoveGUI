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
local GUIElement = require(cwd .. "GUIElement")
local FlowLayout = GUIElement:extend()

---@enum FlowLayout.Alignment
FlowLayout.Alignment = {
    START = "start",
    CENTER = "center",
    END = "end"
}

---@enum FlowLayout.Direction
FlowLayout.Direction = {
    VERTICAL = "vertical",
    HORIZONTAL = "horizontal"
}

---@param x number
---@param y number
---@param width? number
---@param height? number
---@param bgcolor table
---@param padding? number
---@param margin? table|number
---@param alignment? FlowLayout.Alignment
---@param direction? FlowLayout.Direction
function FlowLayout:init(x, y, width, height, bgcolor, padding, margin, alignment, direction)
    FlowLayout.super.init(self, x, y, width, height, bgcolor)
    self.padding = padding or 5
    self.alignment = alignment or FlowLayout.Alignment.START
    self.direction = direction or FlowLayout.Direction.VERTICAL
    self.tag = "FlowLayout"
    self.autoWidth = false
    self.autoHeight = false

    if margin == nil then
        self.margin = {left=0, right=0, top=0, bottom=0}
    else
        if type(margin) == "table" then
            self.margin = margin
        else
            self.margin = {left=margin, right=margin, top=margin, bottom=margin}
        end
    end

    self.width = width
    self.height = height
    self._width = width or 0
    self._height = height or 0

    if width == nil then
        self.autoWidth = true
    end
    if height == nil then
        self.autoHeight = true
    end
end


function FlowLayout:getWidth()
    return self._width
end

function FlowLayout:getHeight()
    return self._height
end

function FlowLayout:addChild(child)
    FlowLayout.super.addChild(self, child)
    self:updateFrame()
end

function FlowLayout:updateSize()
    self._width = self.margin.left + self.margin.right
    self._height = self.margin.top + self.margin.bottom
    for _, child in ipairs(self.children) do
        local child_w, child_h = child:getRealSize()
        if self.direction == FlowLayout.Direction.HORIZONTAL then
            self._width = self._width + child_w + self.padding
            self._height = math.max(self._height, child_h + self.margin.top + self.margin.bottom)
        else
            self._width = math.max(self._width, child_w + self.margin.left + self.margin.right)
            self._height = self._height + child_h + self.padding
        end
    end
    -- Remove extra padding
    if #self.children > 0 then
        if self.direction == FlowLayout.Direction.HORIZONTAL then
            self._width = self._width - self.padding
        else
            self._height = self._height - self.padding
        end
    end
end

function FlowLayout:getRealSize()
    return self._width, self._height
end

---@param alignment FlowLayout.Alignment
function FlowLayout:setAlignment(alignment)
    self.alignment = alignment
    self:updateFrame()
end

---@param direction FlowLayout.Direction
function FlowLayout:setDirection(direction)
    self.direction = direction
    self:updateFrame()
end

function FlowLayout:updateFrame()
    self:updateChildrenPositions()
    self:updateSize()
end

function FlowLayout:updateChildrenPositions()
    local currentPos = self.direction == FlowLayout.Direction.VERTICAL and self.margin.top or self.margin.left
    local isVertical = self.direction == FlowLayout.Direction.VERTICAL
    local mainDim, crossDim = isVertical and "height" or "width", isVertical and "width" or "height"
    local mainAxis, crossAxis = isVertical and "y" or "x", isVertical and "x" or "y"

    for i, child in ipairs(self.children) do
        child[mainAxis] = currentPos
        
        -- Apply alignment
        if self.alignment == FlowLayout.Alignment.START then
            child[crossAxis] = isVertical and self.margin.left or self.margin.top
        elseif self.alignment == FlowLayout.Alignment.CENTER then
            child[crossAxis] = (self[crossDim] - child[crossDim]) / 2
        elseif self.alignment == FlowLayout.Alignment.END then
            child[crossAxis] = self[crossDim] - child[crossDim] - (isVertical and self.margin.right or self.margin.bottom)
        end
        
        -- Add padding only after the first element
        if i < #self.children then
            currentPos = currentPos + child[mainDim] + self.padding
        else
            currentPos = currentPos + child[mainDim]
        end
    end
end

function FlowLayout:removeChild(child)
    FlowLayout.super.removeChild(self, child)
    self:updateFrame()
end

function FlowLayout:clearChildren()
    FlowLayout.super.clearChildren(self)
    self:updateFrame()
end

function FlowLayout:resize(width, height)
    FlowLayout.super.resize(self, width, height)
    self:updateFrame()
end

return FlowLayout