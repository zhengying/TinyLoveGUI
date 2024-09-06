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

---@class FlowLayout
---@param x number
---@param y number
---@param width? number
---@param height? number
---@param bgcolor table
---@param padding? table|number
---@param alignment? FlowLayout.Alignment
---@param direction? FlowLayout.Direction
function FlowLayout:init(x, y, width, height, bgcolor, padding, alignment, direction, sizeMode,crossAxisSizeMode)
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
    self.spaceWeightChildren = {}
    self.measuredWidth = 0
    self.measuredHeight = 0
    self.gap = gap or 0

    -- cross axis size mode

    self.crossAxisSizeMode = crossAxisSizeMode or FlowLayout.SizeMode.WRAP_CONTENT

    self.width = width or 0
    self.height = height or 0
    self.sizeMode = sizeMode or {
        width = width and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT,
        height = height and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT
    } 
end

function FlowLayout:onAddToContext(context)
    self:updateFrame()
end

function FlowLayout:setSizeMode(widthMode, heightMode)
    self.sizeMode.width = widthMode or self.sizeMode.width
    self.sizeMode.height = heightMode or self.sizeMode.height
    self:updateFrame()
end

function FlowLayout:updateFrame()
    if self.parent == nil then return end

    local parentWidth, parentHeight = self.parent:getSize()
    
    if self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT then
        self.width = parentWidth - self.x
    elseif self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
        self.width = self.measuredWidth
    end
    
    if self.sizeMode.height == FlowLayout.SizeMode.FILL_PARENT then
        self.height = parentHeight - self.y
    elseif self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
        self.height = self.measuredHeight
    end

    for _, child in ipairs(self.children) do
        if child.onParentResize then
            child:onParentResize(self.width, self.height)
        end
    end
    
    self:updateChildrenPositions()

    for _, child in ipairs(self.children) do
        if child.layoutComplete then
            child:layoutComplete(self.width, self.height)
        end
    end
end

function FlowLayout:onParentResize(parentWidth, parentHeight)
    if self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT or self.sizeMode.height == FlowLayout.SizeMode.FILL_PARENT then
        self:updateFrame()
        -- for _, child in ipairs(self.children) do
        --     child:onParentResize(self.width, self.height)
        -- end
    end
end

function FlowLayout:resize(width, height)
    if self.sizeMode.width == FlowLayout.SizeMode.FIXED then
        self.width = width
    end
    if self.sizeMode.height == FlowLayout.SizeMode.FIXED then
        self.height = height
    end
    self:updateFrame()

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
---@param spaceWeight? number
function FlowLayout:addChild(child, spaceWeight)
    FlowLayout.super.addChild(self, child)
    if spaceWeight and spaceWeight > 0 then
        self.spaceWeightChildren[child] = spaceWeight
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


function FlowLayout:updateChildrenPositions()
    local isVertical = self.direction == FlowLayout.Direction.VERTICAL
    local mainDim, crossDim = isVertical and "height" or "width", isVertical and "width" or "height"
    local mainAxis, crossAxis = isVertical and "y" or "x", isVertical and "x" or "y"

    local totalSpace = self[mainDim] - self.padding[isVertical and "top" or "left"] - self.padding[isVertical and "bottom" or "right"]
    local childCount = #self.children

    local totalExpandPriority = 0
    for _, priority in pairs(self.spaceWeightChildren) do
        totalExpandPriority = totalExpandPriority + priority
    end

    -- First pass: expand children and calculate total size
    local maxChildWidth = 0
    local maxChildHeight = 0
    local totalChildSize = 0
    local remainingSpace = totalSpace
    local spacePerPriority = totalExpandPriority > 0 and remainingSpace / totalExpandPriority or 0

    for _, child in ipairs(self.children) do
        if self.spaceWeightChildren[child] then
            child[mainDim] = spacePerPriority * self.spaceWeightChildren[child]
        end
        local childWidth, childHeight = child:getSize()
        maxChildWidth = math.max(maxChildWidth, childWidth)
        maxChildHeight = math.max(maxChildHeight, childHeight)
        totalChildSize = totalChildSize + child[mainDim]
    end

    -- Calculate spacing
    local gap = self.gap or 0
    local spacing = gap
    if childCount > 1 then
        if self.alignment == FlowLayout.Alignment.SPACE_BETWEEN then
            spacing = (totalSpace - totalChildSize) / (childCount - 1)
        elseif self.alignment == FlowLayout.Alignment.SPACE_AROUND then
            spacing = (totalSpace - totalChildSize) /  (childCount + 1)
        end
    end

    -- Position children
    local currentPos = (isVertical and self.padding.top or self.padding.left)

    if self.alignment == FlowLayout.Alignment.SPACE_AROUND then
        currentPos = currentPos + spacing
    elseif self.alignment == FlowLayout.Alignment.CENTER then
        currentPos = currentPos + (totalSpace - totalChildSize - (childCount - 1) * spacing) / 2
    elseif self.alignment == FlowLayout.Alignment.END then
        currentPos = currentPos + (totalSpace - totalChildSize - (childCount - 1) * spacing)
    end
    
    for i, child in ipairs(self.children) do
        child[mainAxis] = currentPos

        -- Apply cross-axis sizing and alignment
        if self.crossAxisSizeMode == FlowLayout.SizeMode.FILL_PARENT then
            child[crossDim] = self[crossDim] - (isVertical and (self.padding.left + self.padding.right) or (self.padding.top + self.padding.bottom))
            child[crossAxis] = isVertical and self.padding.left or self.padding.top
        else
            -- Apply existing cross-axis alignment logic
            if self.alignment == FlowLayout.Alignment.START then
                child[crossAxis] = isVertical and self.padding.left or self.padding.top
            elseif self.alignment == FlowLayout.Alignment.CENTER then
                child[crossAxis] = (self[crossDim] - child[crossDim]) / 2
            elseif self.alignment == FlowLayout.Alignment.END then
                child[crossAxis] = self[crossDim] - child[crossDim] - (isVertical and self.padding.right or self.padding.bottom)
            else
                child[crossAxis] = isVertical and self.padding.left or self.padding.top
            end
        end
        
        currentPos = currentPos + child[mainDim] + spacing
    end

    -- Update the layout's measured size
    if isVertical then
        self.measuredWidth = maxChildWidth + self.padding.left + self.padding.right
        self.measuredHeight = currentPos - spacing + self.padding.bottom
    else
        self.measuredWidth = currentPos - spacing + self.padding.right
        self.measuredHeight = maxChildHeight + self.padding.top + self.padding.bottom
    end
    
    if self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
        self.width = self.measuredWidth
    end
    
    if self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
        self.height = self.measuredHeight
    end
end

function FlowLayout:removeChild(child)
    FlowLayout.super.removeChild(self, child)
    self.spaceWeightChildren[child] = nil
    self:updateFrame()
end

function FlowLayout:clearChildren()
    FlowLayout.super.clearChildren(self)
    self.spaceWeightChildren = {}
    self:updateFrame()
end

return FlowLayout