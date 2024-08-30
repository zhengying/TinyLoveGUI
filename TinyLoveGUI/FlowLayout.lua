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
    END = "end",
    SPACE_BETWEEN = "space-between",
    SPACE_AROUND = "space-around"
}

---@enum FlowLayout.Direction
FlowLayout.Direction = {
    VERTICAL = "vertical",
    HORIZONTAL = "horizontal"
}

FlowLayout.SizeMode = {
    FIXED = "FIXED",
    FILL_PARENT = "FILL_PARENT",
    WRAP_CONTENT = "WRAP_CONTENT"
}

---@param x number
---@param y number
---@param width? number
---@param height? number
---@param bgcolor table
---@param padding? table|number
---@param margin? table|number
---@param alignment? FlowLayout.Alignment
---@param direction? FlowLayout.Direction
function FlowLayout:init(x, y, width, height, bgcolor, padding, margin, alignment, direction, sizeMode)
    FlowLayout.super.init(self, x, y, width, height, bgcolor)
    if type(padding) == 'number' then
        padding = {left=padding, right=padding, top=padding, bottom=padding} 
    end
    self.padding = padding or {left=5, right=5, top=5, bottom=5}
    self.alignment = alignment or FlowLayout.Alignment.CENTER
    self.direction = direction or FlowLayout.Direction.HORIZONTAL
    self.tag = "FlowLayout"
    self.focusable = false
    self.highligtable = false
    self.expandingChildren = {}
    self.measuredWidth = 0
    self.measuredHeight = 0
    self.gap = gap or 0

    if margin == nil then
        self.margin = {left=0, right=0, top=0, bottom=0}
    else
        if type(margin) == "table" then
            self.margin = margin
        else
            self.margin = {left=margin, right=margin, top=margin, bottom=margin}
        end
    end

    self.width = width or 0
    self.height = height or 0
    self.sizeMode = sizeMode or {
        width = width and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT,
        height = height and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT
    }
end

function FlowLayout:onAddToContext(context)
    self:updateSize()
end

function FlowLayout:setSizeMode(widthMode, heightMode)
    self.sizeMode.width = widthMode or self.sizeMode.width
    self.sizeMode.height = heightMode or self.sizeMode.height
    self:updateSize()
end

function FlowLayout:updateSize()
    local parentWidth, parentHeight = self.parent:getSize()
    
    if self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT then
        self.width = parentWidth - self.margin.left - self.margin.right
    elseif self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
        self.width = self.measuredWidth
    end
    
    if self.sizeMode.height == FlowLayout.SizeMode.FILL_PARENT then
        self.height = parentHeight - self.margin.top - self.margin.bottom
    elseif self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
        self.height = self.measuredHeight
    end
    
    self:updateChildrenPositions()
end

function FlowLayout:onParentResize(parentWidth, parentHeight)
    if self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT or self.sizeMode.height == FlowLayout.SizeMode.FILL_PARENT then
        self:updateSize()
    end
end

function FlowLayout:resize(width, height)
    if self.sizeMode.width == FlowLayout.SizeMode.FIXED then
        self.width = width
    end
    if self.sizeMode.height == FlowLayout.SizeMode.FIXED then
        self.height = height
    end
    self:updateSize()
end

function FlowLayout:getWidth()
    if self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
        return self.measuredWidth
    else
        return self.width
    end
end

function FlowLayout:getHeight()
    if self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
        return self.measuredHeight
    else
        return self.height
    end
end

---@param child GUIElement
---@param expandPriority? number
function FlowLayout:addChild(child, expandPriority)
    FlowLayout.super.addChild(self, child)
    if expandPriority and expandPriority > 0 then
        self.expandingChildren[child] = expandPriority
    end
    self:updateFrame()
end

function FlowLayout:getSize()
    return self.width, self.height
end

function FlowLayout:getMeasuredSize()
    return self.measuredWidth, self.measuredHeight
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
    local isVertical = self.direction == FlowLayout.Direction.VERTICAL
    local mainDim, crossDim = isVertical and "height" or "width", isVertical and "width" or "height"
    local mainAxis, crossAxis = isVertical and "y" or "x", isVertical and "x" or "y"

    local totalSpace = self[mainDim] - self.padding[isVertical and "top" or "left"] - self.padding[isVertical and "bottom" or "right"]
    local childCount = #self.children
    local totalChildSize = 0

    -- Calculate total child size and expand children if necessary
    for _, child in ipairs(self.children) do
        if self.expandingChildren[child] then
            -- Implement expansion logic here if needed
        end
        totalChildSize = totalChildSize + child[mainDim]
    end

    local spacing = 0
    if childCount > 1 then
        if self.alignment == FlowLayout.Alignment.SPACE_BETWEEN then
            spacing = (totalSpace - totalChildSize) / (childCount - 1)
        elseif self.alignment == FlowLayout.Alignment.SPACE_AROUND then
            spacing = (totalSpace - totalChildSize) / (childCount + 1)
        end
    end

    local currentPos = (isVertical and self.padding.top or self.padding.left) + (isVertical and self.margin.top or self.margin.left)

    for i, child in ipairs(self.children) do
        if self.alignment == FlowLayout.Alignment.SPACE_AROUND then
            currentPos = currentPos + spacing
        end

        child[mainAxis] = currentPos

        -- Apply cross-axis alignment
        if self.alignment == FlowLayout.Alignment.START then
            child[crossAxis] = (isVertical and self.padding.left or self.padding.top) + (isVertical and self.margin.left or self.margin.top)
        elseif self.alignment == FlowLayout.Alignment.CENTER then
            child[crossAxis] = (self[crossDim] - child[crossDim]) / 2
        elseif self.alignment == FlowLayout.Alignment.END then
            child[crossAxis] = self[crossDim] - child[crossDim] - (isVertical and self.padding.right or self.padding.bottom) - (isVertical and self.margin.right or self.margin.bottom)
        else
            child[crossAxis] = (isVertical and self.padding.left or self.padding.top) + (isVertical and self.margin.left or self.margin.top)
        end
        
        currentPos = currentPos + child[mainDim] + spacing
    end

    -- Update the layout's measured size
    self.measuredWidth = isVertical and self.width or (currentPos - spacing + self.padding.right + self.margin.right)
    self.measuredHeight = isVertical and (currentPos - spacing + self.padding.bottom + self.margin.bottom) or self.height
    
    if self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
        self.width = self.measuredWidth
    end
    
    if self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
        self.height = self.measuredHeight
    end
end

function FlowLayout:removeChild(child)
    FlowLayout.super.removeChild(self, child)
    self.expandingChildren[child] = nil
    self:updateFrame()
end

function FlowLayout:clearChildren()
    FlowLayout.super.clearChildren(self)
    self.expandingChildren = {}
    self:updateFrame()
end

return FlowLayout