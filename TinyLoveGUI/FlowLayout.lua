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

FlowLayout.Alignment = {
    START = "start",
    CENTER = "center",
    END = "end",
    SPACE_BETWEEN = "space-between",
    SPACE_AROUND = "space-around"
}

FlowLayout.CrossAlignment = {
    START = "start",
    CENTER = "center",
    END = "end",
    STRETCH = "stretch"
}

FlowLayout.Direction = {
    VERTICAL = "vertical",
    HORIZONTAL = "horizontal"
}

FlowLayout.SizeMode = {
    FIXED = "fixed",
    FILL_PARENT = "fill_parent",
    WRAP_CONTENT = "wrap_content"
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
function FlowLayout:init(x, y, width, height, bgcolor, padding, alignment, direction, sizeMode, crossAlignment, gap)
    FlowLayout.super.init(self, x, y, width, height, bgcolor)
    if type(padding) == 'number' then
        padding = {left=padding, right=padding, top=padding, bottom=padding} 
    end
    self.padding = padding or {left=5, right=5, top=5, bottom=5}
    self.alignment = alignment or FlowLayout.Alignment.START
    self.crossAlignment = crossAlignment or FlowLayout.CrossAlignment.START
    self.direction = direction or FlowLayout.Direction.HORIZONTAL
    self.tag = "FlowLayout"
    self.focusable = false
    self.highligtable = false
    self.childrenProps = {}
    self.measuredWidth = 0
    self.measuredHeight = 0
    self.gap = gap or 0

    self.width = width or 0
    self.height = height or 0
    self.sizeMode = sizeMode or {
        width = width and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT,
        height = height and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT
    } 
end

function FlowLayout:onAddToContext(context)
    self:updateLayout()
end

function FlowLayout:setSize(width, height)
    self.width = width
    self.height = height
    self:updateLayout()
end

function FlowLayout:setSizeMode(widthMode, heightMode)
    self.sizeMode.width = widthMode or self.sizeMode.width
    self.sizeMode.height = heightMode or self.sizeMode.height
    self:updateLayout()
end

function FlowLayout:onParentResize(parentWidth, parentHeight)

    if self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT then
        local parentPadding = self.parent.padding or {left=0, right=0}
        self.width = parentWidth - self.x - parentPadding.left - parentPadding.right
    end
    
    if self.sizeMode.height == FlowLayout.SizeMode.FILL_PARENT then
        local parentPadding = self.parent.padding or {top=0, bottom=0}
        self.height = parentHeight - self.y - parentPadding.top - parentPadding.bottom
    end

    for _, child in ipairs(self.children) do
        if child.onParentResize then
            child:onParentResize(self.width, self.height)
        end
    end

        self:updateLayout()
end

function FlowLayout:resize(width, height)
    if self.sizeMode.width == FlowLayout.SizeMode.FIXED then
        self.width = width
    end
    if self.sizeMode.height == FlowLayout.SizeMode.FIXED then
        self.height = height
    end
    self:updateLayout()

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

function FlowLayout:addChild(child, flexGrow, flexShrink, flexBasis)
    FlowLayout.super.addChild(self, child)
    self.childrenProps[child] = {
        flexGrow = flexGrow or 0,
        flexShrink = flexShrink or 1,
        flexBasis = flexBasis or "auto"
    }
    child.parent = self
    child.x = self.padding.left  -- Set initial x position
    child.y = self.padding.top   -- Set initial y position
    self:updateLayout()
end

function FlowLayout:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            self.childrenProps[child] = nil
            break
        end
    end
    self:updateLayout()
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
    self:updateLayout()
end

---@param direction FlowLayout.Direction
function FlowLayout:setDirection(direction)
    self.direction = direction
    self:updateLayout()
end

-- function FlowLayout:updateLayout()

--     if #self.children == 0 then return end


--     local totalSize = totalChildrenSize + spacing * (#self.children - 1)
--     local startPos = currentPos

--     if self.alignment == FlowLayout.Alignment.CENTER then
--         startPos = currentPos + (availableSpace - totalSize) / 2
--     elseif self.alignment == FlowLayout.Alignment.END then
--         startPos = currentPos + availableSpace - totalSize
--     elseif self.alignment == FlowLayout.Alignment.SPACE_BETWEEN then
--         spacing = #self.children > 1 and (availableSpace - totalChildrenSize) / (#self.children - 1) or 0
--     elseif self.alignment == FlowLayout.Alignment.SPACE_AROUND then
--         spacing = #self.children > 0 and (availableSpace - totalChildrenSize) / #self.children or 0
--         startPos = currentPos + spacing / 2
--     end

--     currentPos = startPos

--     local isVertical = self.direction == FlowLayout.Direction.VERTICAL
--     local mainDim = isVertical and "height" or "width"
--     local crossDim = isVertical and "width" or "height"
--     local mainAxis = isVertical and "y" or "x"
--     local crossAxis = isVertical and "x" or "y"

--     local availableSpace = self[mainDim] - self.padding[isVertical and "top" or "left"] - self.padding[isVertical and "bottom" or "right"]
--     local totalFlexGrow = 0
--     local totalFlexShrink = 0
--     local totalFixedSize = 0
--     local totalChildrenSize = 0

--     -- First pass: calculate flex totals and fixed sizes
--     for _, child in ipairs(self.children) do
--         local props = self.childrenProps[child]
--         totalFlexGrow = totalFlexGrow + props.flexGrow
--         totalFlexShrink = totalFlexShrink + props.flexShrink
--         if props.flexBasis ~= "auto" then
--             totalFixedSize = totalFixedSize + props.flexBasis
--         else
--             totalFixedSize = totalFixedSize + child[mainDim]
--         end
--         totalChildrenSize = totalChildrenSize + child[mainDim]
--     end

--     local freeSpace = availableSpace - totalFixedSize
--     local scale = freeSpace > 0 and totalFlexGrow or totalFlexShrink

--     -- Second pass: distribute space and position children
--     local currentPos = isVertical and self.padding.top or self.padding.left
--     local spacing = self.gap

--     if self.alignment == FlowLayout.Alignment.SPACE_BETWEEN then
--         spacing = #self.children > 1 and freeSpace / (#self.children - 1) or 0
--     elseif self.alignment == FlowLayout.Alignment.SPACE_AROUND then
--         spacing = #self.children > 0 and freeSpace / #self.children or 0
--         currentPos = currentPos + spacing / 2
--     elseif self.alignment == FlowLayout.Alignment.END then
--         if isVertical then
--             currentPos = currentPos + freeSpace
--         else
--             -- For horizontal layout, adjust the starting position
--             currentPos = self.width - self.padding.right - totalChildrenSize - (spacing * (#self.children - 1))
--         end
--     end

--     for _, child in ipairs(self.children) do
--         local props = self.childrenProps[child]
--         local childSize

--         if props.flexBasis ~= "auto" then
--             childSize = props.flexBasis
--         else
--             childSize = child[mainDim]
--         end

--         if freeSpace > 0 and props.flexGrow > 0 then
--             childSize = childSize + (freeSpace * (props.flexGrow / scale))
--         elseif freeSpace < 0 and props.flexShrink > 0 then
--             childSize = childSize + (freeSpace * (props.flexShrink / scale))
--         end

--         child[mainDim] = childSize
--         child[mainAxis] = currentPos
--         currentPos = currentPos + childSize + spacing

--         -- Handle cross-axis alignment
--         if self.alignment == FlowLayout.Alignment.STRETCH then
--             child[crossDim] = self[crossDim] - self.padding[isVertical and "left" or "top"] - self.padding[isVertical and "right" or "bottom"]
--         elseif self.alignment == FlowLayout.Alignment.CENTER then
--             child[crossAxis] = (self[crossDim] - child[crossDim]) / 2
--         elseif self.alignment == FlowLayout.Alignment.END then
--             child[crossAxis] = self[crossDim] - child[crossDim] - (isVertical and self.padding.right or self.padding.bottom)
--         else -- START alignment
--             child[crossAxis] = isVertical and self.padding.left or self.padding.top
--         end

--         -- Ensure the child doesn't exceed the layout's bounds
--         if child[mainAxis] + child[mainDim] > self[mainDim] - self.padding[isVertical and "bottom" or "right"] then
--             child[mainDim] = self[mainDim] - child[mainAxis] - self.padding[isVertical and "bottom" or "right"]
--         end
--     end

--     -- Update measured size
--     self.measuredWidth = isVertical and self.width or currentPos - spacing + (isVertical and self.padding.right or self.padding.left)
--     self.measuredHeight = isVertical and currentPos - spacing + (isVertical and self.padding.bottom or self.padding.top) or self.height

--     if self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
--         self.width = self.measuredWidth
--     end
--     if self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
--         self.height = self.measuredHeight
--     end
-- end


-- function FlowLayout:updateLayout()
--     -- Apply size modes
--     if self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
--         self.width = self.measuredWidth
--     elseif self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT and self.parent then
--         local padding = self.parent.padding or {left=0, right=0, top=0, bottom=0}
--         local parentAvailableWidth = self.parent.width - padding.left - padding.right
--         self.width = parentAvailableWidth - self.x
--     end

--     if self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
--         self.height = self.measuredHeight
--         local padding = self.parent.padding or {left=0, right=0, top=0, bottom=0}
--         local parentAvailableHeight = self.parent.height - padding.top - padding.bottom
--         self.height = parentAvailableHeight - self.y
--     end

--     local isVertical = self.direction == FlowLayout.Direction.VERTICAL
--     local mainDim = isVertical and "height" or "width"
--     local crossDim = isVertical and "width" or "height"
--     local mainAxis = isVertical and "y" or "x"
--     local crossAxis = isVertical and "x" or "y"

--     -- Calculate available space considering padding
--     local availableSpace = self[mainDim] - self.padding[isVertical and "top" or "left"] - self.padding[isVertical and "bottom" or "right"]
--     local totalFlexGrow = 0
--     local totalFlexShrink = 0
--     local totalFixedSize = 0
--     local totalChildrenSize = 0

--     -- First pass: calculate flex totals and fixed sizes
--     for _, child in ipairs(self.children) do
--         local props = self.childrenProps[child]
--         totalFlexGrow = totalFlexGrow + (props.flexGrow or 0)
--         totalFlexShrink = totalFlexShrink + (props.flexShrink or 1)
--         if props.flexBasis and props.flexBasis ~= "auto" then
--             totalFixedSize = totalFixedSize + props.flexBasis
--         else
--             totalFixedSize = totalFixedSize + child[mainDim]
--         end
--         totalChildrenSize = totalChildrenSize + child[mainDim]
--     end

--     local freeSpace = availableSpace - totalFixedSize
--     local scale = freeSpace > 0 and totalFlexGrow or totalFlexShrink

--     -- Second pass: distribute space and position children
--     local startPos = self.padding[isVertical and "top" or "left"]
--     local endPos = self[mainDim] - self.padding[isVertical and "bottom" or "right"]
--     local spacing = self.gap

--     local totalSize = totalChildrenSize + spacing * (#self.children - 1)

--     if self.alignment == FlowLayout.Alignment.CENTER then
--         startPos = startPos + (availableSpace - totalSize) / 2
--     elseif self.alignment == FlowLayout.Alignment.END then
--         startPos = endPos - totalSize
--     elseif self.alignment == FlowLayout.Alignment.SPACE_BETWEEN then
--         spacing = #self.children > 1 and (availableSpace - totalChildrenSize) / (#self.children - 1) or 0
--     elseif self.alignment == FlowLayout.Alignment.SPACE_AROUND then
--         spacing = #self.children > 0 and (availableSpace - totalChildrenSize) / #self.children or 0
--         startPos = startPos + spacing / 2
--     end

--     local currentPos = startPos

--     for _, child in ipairs(self.children) do
--         local props = self.childrenProps[child]
--         local childSize

--         if props.flexBasis and props.flexBasis ~= "auto" then
--             childSize = props.flexBasis
--         else
--             childSize = child[mainDim]
--         end

--         if freeSpace > 0 and (props.flexGrow or 0) > 0 then
--             childSize = childSize + (freeSpace * ((props.flexGrow or 0) / scale))
--         elseif freeSpace < 0 and (props.flexShrink or 1) > 0 then
--             childSize = childSize + (freeSpace * ((props.flexShrink or 1) / scale))
--         end

--         -- Ensure the child doesn't exceed the layout's bounds
--         if currentPos + childSize > endPos then
--             childSize = endPos - currentPos
--         end

--         child[mainDim] = childSize
--         child[mainAxis] = currentPos
--         currentPos = currentPos + childSize + spacing

--         -- If this child would overflow into the right padding, stop adding more children
--         if currentPos > endPos then
--             currentPos = endPos
--             break
--         end

--         -- Handle cross-axis alignment, accounting for padding
--         local crossStart = self.padding[isVertical and "left" or "top"]
--         local crossEnd = self[crossDim] - self.padding[isVertical and "right" or "bottom"]

--         local crossAvailable = crossEnd - crossStart

--         if self.crossAlignment == FlowLayout.CrossAlignment.STRETCH then
--             child[crossDim] = crossAvailable
--         elseif self.crossAlignment == FlowLayout.CrossAlignment.CENTER then
--             child[crossAxis] = crossStart + (crossAvailable - child[crossDim]) / 2
--         elseif self.crossAlignment == FlowLayout.CrossAlignment.END then
--             child[crossAxis] = crossEnd - child[crossDim]
--         else -- START alignment
--             child[crossAxis] = crossStart
--         end

--         print(child[crossDim], child[crossAxis])
--     end

--     -- Update measured size
--     if isVertical then
--         self.measuredWidth = self.width
--         self.measuredHeight = math.max(currentPos - spacing, self.padding.top + self.padding.bottom)
--     else
--         self.measuredWidth = math.max(currentPos - spacing, self.padding.left + self.padding.right)
--         self.measuredHeight = self.height
--     end

--     if self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
--         self.width = self.measuredWidth
--     elseif self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT and self.parent then
--         local padding = self.parent.padding or {left=0, right=0, top=0, bottom=0}
--         local parentAvailableWidth = self.parent.width - padding.left - padding.right
--         self.width = parentAvailableWidth - self.x
--     end

--     if self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
--         self.height = self.measuredHeight
--         local padding = self.parent.padding or {left=0, right=0, top=0, bottom=0}
--         local parentAvailableHeight = self.parent.height - padding.top - padding.bottom
--         self.height = parentAvailableHeight - self.y
--     end

-- end


function FlowLayout:updateSizeMode()
    -- Update layout size based on size modes
    if self.sizeMode.width == FlowLayout.SizeMode.WRAP_CONTENT then
        self.width = self.measuredWidth
    elseif self.sizeMode.width == FlowLayout.SizeMode.FILL_PARENT and self.parent then
        local parentPadding = self.parent.padding or {left=0, right=0}
        self.width = self.parent.width - parentPadding.left - parentPadding.right - self.x
    end

    if self.sizeMode.height == FlowLayout.SizeMode.WRAP_CONTENT then
        self.height = self.measuredHeight
    elseif self.sizeMode.height == FlowLayout.SizeMode.FILL_PARENT and self.parent then
        local parentPadding = self.parent.padding or {top=0, bottom=0}
        self.height = self.parent.height - parentPadding.top - parentPadding.bottom - self.y
    end
end


function FlowLayout:updateLayout()

    local isVertical = self.direction == FlowLayout.Direction.VERTICAL
    local mainDim = isVertical and "height" or "width"
    local crossDim = isVertical and "width" or "height"
    local mainAxis = isVertical and "y" or "x"
    local crossAxis = isVertical and "x" or "y"

    -- Calculate available space considering padding and gaps
    local availableSpace = self[mainDim] - self.padding[isVertical and "top" or "left"] - self.padding[isVertical and "bottom" or "right"] - (self.gap * math.max(#self.children - 1, 0))
    local totalFlexGrow = 0
    local totalFlexShrink = 0
    local totalFixedSize = 0
    local flexChildren = {}

    -- First pass: separate fixed and flex children, calculate totals
    for _, child in ipairs(self.children) do
        local props = self.childrenProps[child]
        if props.flexGrow and props.flexGrow > 0 then
            totalFlexGrow = totalFlexGrow + props.flexGrow
            totalFlexShrink = totalFlexShrink + (props.flexShrink or 1)
            table.insert(flexChildren, child)
        else
            totalFixedSize = totalFixedSize + child[mainDim]
        end
    end

    local freeSpace = math.max(availableSpace - totalFixedSize, 0)
    local scale = freeSpace > 0 and totalFlexGrow or totalFlexShrink

    -- Calculate spacing based on alignment
    local spacing = self.gap
    local startPos = self.padding[isVertical and "top" or "left"]
    if self.alignment == FlowLayout.Alignment.CENTER then
        startPos = startPos + freeSpace / 2
    elseif self.alignment == FlowLayout.Alignment.END then
        startPos = startPos + freeSpace
    elseif self.alignment == FlowLayout.Alignment.SPACE_BETWEEN and #self.children > 1 then
        spacing = freeSpace / (#self.children - 1)
    elseif self.alignment == FlowLayout.Alignment.SPACE_AROUND and #self.children > 0 then
        spacing = freeSpace / #self.children
        startPos = startPos + spacing / 2
    end

    local currentPos = startPos
    local maxCrossSize = 0

    -- Second pass: distribute space and position children
    for _, child in ipairs(self.children) do
        local props = self.childrenProps[child]
        local childSize = child[mainDim]

        if props.flexGrow and props.flexGrow > 0 then
            local flexSpace = freeSpace * (props.flexGrow / scale)
            childSize = math.max(flexSpace, 1) -- Ensure minimum size of 1
        end

        child[mainDim] = childSize
        child[mainAxis] = currentPos
        currentPos = currentPos + childSize + spacing

        -- Handle cross-axis alignment
        local crossStart = self.padding[isVertical and "left" or "top"]
        local crossEnd = self[crossDim] - self.padding[isVertical and "right" or "bottom"]
        local crossAvailable = crossEnd - crossStart

        if self.crossAlignment == FlowLayout.CrossAlignment.STRETCH then
            print("Stretching child's " .. crossDim .. " from " .. child[crossDim], "to", crossAvailable)
            if child.tag == 'Button' then
                print('hello')
            end
            child[crossDim] = crossAvailable
        elseif self.crossAlignment == FlowLayout.CrossAlignment.CENTER then
            child[crossAxis] = crossStart + (crossAvailable - child[crossDim]) / 2
        elseif self.crossAlignment == FlowLayout.CrossAlignment.END then
            child[crossAxis] = crossEnd - child[crossDim]
        else -- START alignment
            child[crossAxis] = crossStart
        end

        maxCrossSize = math.max(maxCrossSize, child[crossDim])

        if child.updateLayout then
            child:updateLayout()
        end
    end

    -- Update measured sizes
    if isVertical then
        self.measuredHeight = currentPos - spacing + self.padding[isVertical and "bottom" or "right"]
        self.measuredWidth = maxCrossSize + self.padding.left + self.padding.right
    else
        self.measuredWidth = currentPos - spacing + self.padding[isVertical and "bottom" or "right"]
        self.measuredHeight = maxCrossSize + self.padding.top + self.padding.bottom
    end

    self:updateSizeMode()
end

-- function FlowLayout:draw()
--     self.super.draw(self)
--     if self.DEBUG_DRAW then
--         love.graphics.setColor(1, 0, 0, 0.5)
--         love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
--         for _, child in ipairs(self.children) do
--             love.graphics.setColor(0, 1, 1, 0.5)
--             love.graphics.rectangle("line", self.x + child.x, self.y + child.y, child.width, child.height)
--         end
--     end
-- end

-- function FlowLayout:draw()
--     -- Call the original draw method if it exists
--     if self.super.draw then
--         self.super.draw(self)
--     end

--     -- Debug drawing
--     love.graphics.setColor(1, 0, 0, 0.5)  -- Semi-transparent red
--     love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

--     -- Draw padding areas
--     love.graphics.setColor(0, 1, 0, 0.5)  -- Semi-transparent green
--     love.graphics.rectangle("fill", self.x, self.y, self.padding.left, self.height)  -- Left padding
--     love.graphics.rectangle("fill", self.x + self.width - self.padding.right, self.y, self.padding.right, self.height)  -- Right padding
--     love.graphics.rectangle("fill", self.x, self.y, self.width, self.padding.top)  -- Top padding
--     love.graphics.rectangle("fill", self.x, self.y + self.height - self.padding.bottom, self.width, self.padding.bottom)  -- Bottom padding

--     -- Draw children
--     for _, child in ipairs(self.children) do
--         love.graphics.setColor(0, 0, 1, 0.5)  -- Semi-transparent blue
--         love.graphics.rectangle("line", self.x + child.x, self.y + child.y, child.width, child.height)
--     end
-- end

return FlowLayout