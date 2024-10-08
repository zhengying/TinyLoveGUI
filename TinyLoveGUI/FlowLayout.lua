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

local Layout = require(cwd .. "Layout")
local FlowLayout = Layout:extend()
local GUIContext = require(cwd .. "GUIContext")

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
---@param sizeMode? FlowLayout.SizeMode
---@param crossAlignment? FlowLayout.CrossAlignment
---@param gap? number   
function FlowLayout:init(options)
    options = options or {}
    FlowLayout.super.init(self, options)
    if type(options.padding) == 'number' then
        options.padding = {left=options.padding, right=options.padding, top=options.padding, bottom=options.padding} 
    end
    self.padding = options.padding or {left=5, right=5, top=5, bottom=5}
    self.alignment = options.alignment or FlowLayout.Alignment.START
    self.crossAlignment = options.crossAlignment or FlowLayout.CrossAlignment.START
    self.direction = options.direction or FlowLayout.Direction.HORIZONTAL
    self.tag = "FlowLayout"
    -- self.focusable = false
    -- self.highligtable = false
    self.childrenProps = {}
    self.measuredWidth = 0
    self.measuredHeight = 0
    self.gap = options.gap or 0
    self.owner = options.owner

    -- self.width = width or 0
    -- self.height = height or 0
--     self.sizeMode = sizeMode or {
--         width = width and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT,
       -- height = height and FlowLayout.SizeMode.FIXED or FlowLayout.SizeMode.WRAP_CONTENT
    --}   
end

function FlowLayout:onAddToContext(context)
    self:updateLayout()
end

---comment
---@param child any
---@param childrenProps any
function FlowLayout:addChild(child, childrenProps)
    assert(child.parent ~= nil, "child.parent is nil")
    assert(child.context ~= nil, "child.context is nil")
    assert(child.cid ~= nil, "child.cid is nil")

    table.insert(self.children, child)

    childrenProps = childrenProps or {flexGrow=0, flexShrink=1, flexBasis="auto"}

    if child.zIndex ~= GUIContext.ZIndexGroup.POPUP then
        self.childrenProps[child] = {
            flexGrow = childrenProps.flexGrow or 0,
            flexShrink = childrenProps.flexShrink or 1,
            flexBasis = childrenProps.flexBasis or "auto"
        }
        child.x = self.padding.left  -- Set initial x position
        child.y = self.padding.top   -- Set initial y position
    end

    self.needSortChildren = true   

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

function FlowLayout:updateLayout()
    
    if self.direction == FlowLayout.Direction.HORIZONTAL then
        print('test')
    end

    local isVertical = self.direction == FlowLayout.Direction.VERTICAL
    local mainDim = isVertical and "height" or "width"
    local crossDim = isVertical and "width" or "height"
    local mainAxis = isVertical and "y" or "x"
    local crossAxis = isVertical and "x" or "y"

    -- Calculate available space considering padding and gaps
    local availableSpace = self.owner[mainDim] - self.padding[isVertical and "top" or "left"] - self.padding[isVertical and "bottom" or "right"] - (self.gap * math.max(#self.children - 1, 0))
    local totalFlexGrow = 0
    local totalFlexShrink = 0
    local totalFixedSize = 0
    local flexChildren = {}

    -- First pass: separate fixed and flex children, calculate totals
    for _, child in ipairs(self.children) do
        repeat -- its just simulate continue
            if child.zIndex == GUIContext.ZIndexGroup.POPUP then
                break
            end

            local props = self.childrenProps[child]
            if props.flexGrow and props.flexGrow > 0 then
                totalFlexGrow = totalFlexGrow + props.flexGrow
                totalFlexShrink = totalFlexShrink + (props.flexShrink or 1)
                table.insert(flexChildren, child)
            else
                totalFixedSize = totalFixedSize + child[mainDim]
            end
        until true
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
        
        repeat
            if child.zIndex == GUIContext.ZIndexGroup.POPUP then
                break
            end
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
            local crossEnd = self.owner[crossDim] - self.padding[isVertical and "right" or "bottom"]
            local crossAvailable = crossEnd - crossStart

            if self.crossAlignment == FlowLayout.CrossAlignment.STRETCH then
                child[crossDim] = crossAvailable
            elseif self.crossAlignment == FlowLayout.CrossAlignment.CENTER then
                child[crossAxis] = crossStart + (crossAvailable - child[crossDim]) / 2
            elseif self.crossAlignment == FlowLayout.CrossAlignment.END then
                child[crossAxis] = crossEnd - child[crossDim]
            else -- START alignment
                child[crossAxis] = crossStart
            end

            maxCrossSize = math.max(maxCrossSize, child[crossDim])

            local childWidth, childHeight = child:getSize()

            -- print("  child tag: " .. child.tag)
            -- print("  After  - x: " .. child.x .. ", y: " .. child.y)
            -- print("  Size   - width: " .. childWidth .. ", height: " .. childHeight)
            -- print("  Gap: " .. self.gap)
            -- print("------------------")

            if child.layout then
                child:updateLayout()
            end
        until true
    end

    for _, child in ipairs(self.children) do
        if child.layoutComplete then
            child:layoutComplete()
        end
    end

end

return FlowLayout