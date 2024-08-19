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
local ScrollView = require(cwd .. "ScrollView")
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType
local Object = require(cwd .. "GUIElement")

local TreeView = ScrollView:extend()

-- TreeNode class
local TreeNode = Object:extend()
TreeNode.id_max = 0

function TreeNode:nextID()
    TreeNode.id_max = TreeNode.id_max + 1
    return TreeNode.id_max
end

function TreeNode:init(title, data)
    self.title = title
    self.data = data
    self.id = self:nextID()
    self.groupStatus = nil
end

function TreeNode:setAsGroup(isExpanded)
    if not self.groupStatus then
        self.groupStatus = {
            children = {},
            isExpanded = isExpanded or false
        }
    else
        self.groupStatus.isExpanded = isExpanded
    end
end

function TreeNode:setExpanded(isExpanded)
    if self:isGroup() then
        self.groupStatus.isExpanded = isExpanded
    end
end

function TreeNode:isGroup()
    return self.groupStatus ~= nil
end

function TreeNode:addChild(child)
    if not self:isGroup() then
        self:setAsGroup(false)
    end
    table.insert(self.groupStatus.children, child)
end

function TreeNode:toggleExpanded()
    if self:isGroup() then
        self.groupStatus.isExpanded = not self.groupStatus.isExpanded
    end
end

-- TreeView implementation
TreeView.defaultFoldIcon = nil
TreeView.defaultExpandedIcon = nil
TreeView.defaultLeafIcon = nil

function TreeView:init(x, y, width, height)
    TreeView.super.init(self, x, y, width, height)
    self.root = TreeNode("Root", {})
    self.root:setAsGroup(true)
    self.selectedNode = nil
    self.hoveredNode = nil
    self.tag = 'TreeView'
    self.focusable = true

    -- Use default icons if set
    self.foldIcon = TreeView.defaultFoldIcon
    self.expandedIcon = TreeView.defaultExpandedIcon
    self.leafIcon = TreeView.defaultLeafIcon

    -- Default style settings
    self.style = {
        bgColor = {0.8, 0.8, 0.8, 1},
        font = love.graphics.newFont(12),
        fontColor = {0.2, 0.2, 0.2, 1},
        hoverColor = {0.8, 0.9, 1, 1},
        selectedColor = {0.6, 0.8, 1, 1},
        selectedFontColor = {1, 1, 1, 1},
        lineColor = {0.7, 0.7, 0.7, 1},
        indentSize = 20,
        nodeHeight = 24,
        iconSize = 16,
        marginLeft = 16,
        marginTop = 8,
        marginBottom = 2,
        borderColor = {0.6, 0.6, 0.6, 1},
        borderWidth = 1
    }
    self:updateContentSize()
end

function TreeView:setDefaultGroupIcon(foldIcon, expandedIcon)
    TreeView.defaultFoldIcon = foldIcon
    TreeView.defaultExpandedIcon = expandedIcon
end

function TreeView:setDefaultLeafIcon(leafIcon)
    TreeView.defaultLeafIcon = leafIcon
end

function TreeView:setStyle(style)
    for k, v in pairs(style) do
        self.style[k] = v
    end
    if style.fontSize then
        self.style.font = love.graphics.newFont(style.fontSize)
    end
    self:updateContentSize()
end

function TreeView:draw()
    if not self.visible then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    love.graphics.setScissor(self.x, self.y, self.width, self.height)
    love.graphics.translate(-self.offsetX, -self.offsetY)
    self:drawNodes()
    love.graphics.setScissor()
    
    love.graphics.pop()

    self:drawScrollbars()
end

function TreeView:drawNodes()
    love.graphics.setColor(self.style.bgColor)
    love.graphics.rectangle("fill", 0, 0, self.contentWidth, self.contentHeight)

    -- Draw border
    love.graphics.setColor(self.style.borderColor)
    love.graphics.setLineWidth(self.style.borderWidth)
    love.graphics.rectangle("line", 0, 0, self.contentWidth, self.contentHeight)

    -- Draw nodes
    self:drawNode(self.root, 0, self.style.marginTop)
end

function TreeView:drawNode(node, depth, y)
    if node == self.root then
        if node:isGroup() then
            for _, child in ipairs(node.groupStatus.children) do
                y = self:drawNode(child, depth + 1, y)
            end
        end
        return y
    end

    local x = depth * self.style.indentSize + self.style.marginLeft
    
    if y + self.style.nodeHeight > self.offsetY and y < self.offsetY + self.height then
        -- Draw background
        love.graphics.setColor(self.style.bgColor)
        love.graphics.rectangle("fill", 0, y, self.contentWidth, self.style.nodeHeight)

        -- Highlight on mouseover
        if node == self.hoveredNode then
            love.graphics.setColor(self.style.hoverColor)
            love.graphics.rectangle("fill", 0, y, self.contentWidth, self.style.nodeHeight)
        end

        -- Highlight selected node
        local isSelected = (node == self.selectedNode)
        if isSelected then
            love.graphics.setColor(self.style.selectedColor)
            love.graphics.rectangle("fill", 0, y, self.contentWidth, self.style.nodeHeight)
        end

        -- Draw text
        if isSelected then
            love.graphics.setColor(self.style.selectedFontColor)
        else
            love.graphics.setColor(self.style.fontColor)
        end

        love.graphics.setFont(self.style.font)
        love.graphics.print(node.title, x, y + (self.style.nodeHeight - self.style.font:getHeight()) / 2)

        if self.draw_node_extra then
            self.draw_node_extra(node, 0, y, self.contentWidth, self.style.nodeHeight, isSelected)
        end

        -- Draw line
        love.graphics.setColor(self.style.lineColor)
        love.graphics.line(0, y + self.style.nodeHeight, self.contentWidth, y + self.style.nodeHeight)

        -- Draw expand/collapse indicator or leaf icon
        local iconY = y + (self.style.nodeHeight - self.style.iconSize) / 2
        if node:isGroup() then
            local icon = node.groupStatus.isExpanded and self.expandedIcon or self.foldIcon
            if icon then
                local ore, og, ob, oa = love.graphics.getColor()
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.draw(icon, x - self.style.iconSize - 5, iconY, 0, self.style.iconSize / icon:getWidth(), self.style.iconSize / icon:getHeight())
                love.graphics.setColor(ore, og, ob, oa)
            else
                -- Fallback to text if no icon is set
                local indicator = node.groupStatus.isExpanded and "-" or "+"
                love.graphics.setColor(self.style.fontColor)
                love.graphics.print(indicator, x - self.style.iconSize, iconY + (self.style.iconSize - self.style.font:getHeight()) / 2)
            end
        elseif self.leafIcon then
            local ore, og, ob, oa = love.graphics.getColor()
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(self.leafIcon, x - self.style.iconSize - 5, iconY, 0, self.style.iconSize / self.leafIcon:getWidth(), self.style.iconSize / self.leafIcon:getHeight())
            love.graphics.setColor(ore, og, ob, oa)
        end
    end

    y = y + self.style.nodeHeight

    if node:isGroup() and node.groupStatus.isExpanded then
        for _, child in ipairs(node.groupStatus.children) do
            y = self:drawNode(child, depth + 1, y)
        end
    end

    return y
end

local function handlePress(self, x, y, button)
    if button and button ~= 1 then return false end  -- Only handle left mouse button or touch

    local localX, localY = self:toLocalCoordinates(x, y)
    self.selectedNode = self:getNodeAt(localX + self.offsetX, localY + self.offsetY)
    if self.selectedNode then
        self.selectedNode:toggleExpanded()
        self:updateContentSize()
        return true
    end

    return false
end

local function handleMove(self, x, y, dx, dy)
    if not (self.isDraggingVerticalScrollbar or self.isDraggingHorizontalScrollbar) then
        local localX, localY = self:toLocalCoordinates(x, y)
        -- Adjust localY by the vertical scroll offset
        localY = localY + self.offsetY
        self.hoveredNode = self:getNodeAt(localX, localY)
    else
        self.hoveredNode = nil  -- Clear hover state when dragging scrollbar
    end
    return true
end

function TreeView:handleInput(event)
    if not self.visible then return false end

    if TreeView.super.handleInput(self, event) then
        return true
    end

    if event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED then
        return handlePress(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_MOVED or event.type == EventType.TOUCH_MOVED then
        return handleMove(self, event.data.x, event.data.y, event.data.dx, event.data.dy)
    end

    return false
end

function TreeView:getNodeAt(x, y)
    return self:findNodeAt(self.root, x, y, 0, self.style.marginTop)
end

function TreeView:getContentHeight()
    self.yOffset = 0
    return self:calculateContentHeight(self.root, 0)
end

function TreeView:getContentWidth()
    self.contentWidth = 0
    return self:calculateContentWidth(self.root, 0)
end

function TreeView:setOnHover(callback)
    self.onHover = callback
end

function TreeView:setOnSelect(callback)
    self.onSelect = callback
end

function TreeView:findNodeAt(node, x, y, depth, currentY)
    if node == self.root then
        if node:isGroup() then
            for _, child in ipairs(node.groupStatus.children) do
                local found, newY = self:findNodeAt(child, x, y, depth + 1, currentY)
                if found then return found, newY end
                currentY = newY
            end
        end
        return nil, currentY
    end

    local nodeTop = currentY
    local nodeBottom = currentY + self.style.nodeHeight

    if y >= nodeTop and y < nodeBottom then
        -- The point is within this node's vertical bounds
        local nodeX = depth * self.style.indentSize + self.style.marginLeft
        local nodeWidth = self.contentWidth - nodeX
        
        if x >= nodeX and x < nodeX + nodeWidth then
            return node, nodeBottom
        end
    end

    currentY = nodeBottom

    if node:isGroup() and node.groupStatus.isExpanded then
        for _, child in ipairs(node.groupStatus.children) do
            local found, newY = self:findNodeAt(child, x, y, depth + 1, currentY)
            if found then return found, newY end
            currentY = newY
        end
    end

    return nil, currentY
end

function TreeView:calculateContentHeight(node, depth)
    if node == self.root then
        local height = 0
        if node:isGroup() then
            for _, child in ipairs(node.groupStatus.children) do
                height = height + self:calculateContentHeight(child, depth + 1)
            end
        end
        return height
    end

    local height = self.style.nodeHeight

    if node:isGroup() and node.groupStatus.isExpanded then
        for _, child in ipairs(node.groupStatus.children) do
            height = height + self:calculateContentHeight(child, depth + 1)
        end
    end

    return height
end

function TreeView:updateContentSize()
    self.contentHeight = self:calculateContentHeight(self.root, 0) + self.style.marginTop + self.style.marginBottom
    self.contentWidth = self:calculateContentWidth(self.root, 0)
    self:updateScrollbars()
end

function TreeView:calculateContentWidth(node, depth)
    if node == self.root then
        local maxWidth = 0
        if node:isGroup() then
            for _, child in ipairs(node.groupStatus.children) do
                local width = self:calculateContentWidth(child, depth + 1)
                if width > maxWidth then maxWidth = width end
            end
        end
        return maxWidth
    end

    local nodeWidth = depth * self.style.indentSize + self.style.marginLeft + self.style.font:getWidth(node.title) + self.style.iconSize + 10

    if node:isGroup() and node.groupStatus.isExpanded then
        for _, child in ipairs(node.groupStatus.children) do
            local childWidth = self:calculateContentWidth(child, depth + 1)
            if childWidth > nodeWidth then nodeWidth = childWidth end
        end
    end

    return nodeWidth
end

function TreeView:onFocusGained()
    -- Override this method in subclasses to handle gaining focus
    print("TreeView:onFocusGained")
end

function TreeView:onFocusLost()
    -- Override this method in subclasses to handle losing focus
    print("TreeView:onFocusLost")
    self.isDraggingVerticalScrollbar = false
    self.isDraggingHorizontalScrollbar = false
end



TreeView.TreeNode = TreeNode
return TreeView