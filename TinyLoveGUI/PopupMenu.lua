local cwd = select(1, ...):match(".+%.") or ""
local GUIElement = require(cwd .. "GUIElement")
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType
local Object = require(cwd .. "Object")
local GUIContext = require(cwd .. "GUIContext")
local PopupMenu = GUIElement:extend()

local MenuItem = Object:extend()

function MenuItem:init(title,callback, data)
    self.title = title
    self.data = data
    self.groupStatus = nil
    self.callback = callback
end

function MenuItem:setAsGroup(isExpanded)
    self.groupStatus = {
        children = {},
        isExpanded = isExpanded or false
    }
end

function MenuItem:isGroup()
    return self.groupStatus ~= nil
end

function MenuItem:addChild(child)
    if not self:isGroup() then
        self:setAsGroup(false)
    end
    table.insert(self.groupStatus.children, child)
end

-- PopupMenu implementation
function PopupMenu:init(options)
    PopupMenu.super.init(self, options)
    self.root = MenuItem("Root", {})
    self.root:setAsGroup(true)
    self.selectedNode = nil
    self.hoveredNode = nil
    self.popupStack = {}
    self.tag = "PopupMenu"
    self.visible = false
    -- self.onSelect = nil

    -- Default style settings
    self.style = {
        bgColor = {0.9, 0.9, 0.9, 1},
        font = love.graphics.newFont(12),
        fontColor = {0.1, 0.1, 0.1, 1},
        hoverColor = {0.8, 0.9, 1, 1},
        selectedColor = {0.7, 0.8, 1, 1},
        borderColor = {0.5, 0.5, 0.5, 1},
        borderWidth = 1,
        itemHeight = 24,
        paddingX = 10,
        paddingY = 5,
        --submenuIndicator = "▶"
        submenuIndicator = ">"
    }
    self.zIndex = GUIContext.ZIndexGroup.POPUP
end

function PopupMenu:setStyle(style)
    for k, v in pairs(style) do
        self.style[k] = v
    end
end

function PopupMenu:addItem(title, data)
    local node = MenuItem(title, data)
    self.root:addChild(node)
    return node
end

function PopupMenu:addSubmenu(title)
    local node = MenuItem(title, {})
    node:setAsGroup(false)
    self.root:addChild(node)
    return node
end

function PopupMenu:show(x, y)
    self.x = x
    self.y = y
    self.visible = true
    self.popupStack = {}
end

function PopupMenu:hide()
    self.visible = false
    self.popupStack = {}
end

function PopupMenu:draw()
    if not self.visible then return end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    -- Draw root menu
    self:drawSingleMenu(self.root, 0, 0)

    -- Draw submenus
    for _, submenu in ipairs(self.popupStack) do
        self:drawSingleMenu(submenu.node, submenu.x, submenu.y)
    end
    
    love.graphics.pop()
end

function PopupMenu:drawSingleMenu(node, x, y)
    local menuWidth = self:calculateMenuWidth(node)
    local menuHeight = #node.groupStatus.children * self.style.itemHeight

    -- Draw menu background
    love.graphics.setColor(self.style.bgColor)
    love.graphics.rectangle("fill", x, y, menuWidth, menuHeight)

    -- Draw menu items
    for i, child in ipairs(node.groupStatus.children) do
        local itemY = y + (i - 1) * self.style.itemHeight
        self:drawMenuItem(child, x, itemY, menuWidth)
    end

    -- Draw border
    love.graphics.setColor(self.style.borderColor)
    love.graphics.setLineWidth(self.style.borderWidth)
    love.graphics.rectangle("line", x, y, menuWidth, menuHeight)
end

function PopupMenu:drawMenuItem(node, x, y, width)
    -- Highlight if hovered or selected
    if node == self.hoveredNode then
        love.graphics.setColor(self.style.hoverColor)
        love.graphics.rectangle("fill", x, y, width, self.style.itemHeight)
    elseif node == self.selectedNode then
        love.graphics.setColor(self.style.selectedColor)
        love.graphics.rectangle("fill", x, y, width, self.style.itemHeight)
    end

    -- Draw text
    love.graphics.setColor(self.style.fontColor)
    love.graphics.setFont(self.style.font)
    love.graphics.print(node.title, x + self.style.paddingX, y + (self.style.itemHeight - self.style.font:getHeight()) / 2)

    -- Draw submenu indicator if applicable
    if node:isGroup() then
        love.graphics.print(self.style.submenuIndicator, x + width - self.style.paddingX - self.style.font:getWidth(self.style.submenuIndicator), y + (self.style.itemHeight - self.style.font:getHeight()) / 2)
    end
end

function PopupMenu:calculateMenuWidth(node)
    local maxWidth = 0
    for _, child in ipairs(node.groupStatus.children) do
        local itemWidth = self.style.font:getWidth(child.title) + self.style.paddingX * 2
        if child:isGroup() then
            itemWidth = itemWidth + self.style.font:getWidth(self.style.submenuIndicator) + self.style.paddingX
        end
        maxWidth = math.max(maxWidth, itemWidth)
    end
    return maxWidth
end

local function handlePress(self, x, y)
    local node, menuIndex = self:getNodeAt(x, y)

    if node then
        --self.selectedNode = node
        if not node:isGroup() then
            -- Leaf node selected, close menu and call callback if exists
            self:hide()
            if node.callback then
                node:callback()
            end
        end
        return true
    else
        -- Click outside menu, close it
        self:hide()
    end
    return false
end

local function handleMove(self, x, y)
    
    local newHoveredNode, menuIndex = self:getNodeAt(x, y)
    
    if newHoveredNode ~= self.hoveredNode then
        self.hoveredNode = newHoveredNode
        
        if menuIndex then
            -- Close submenus that are not parents of the current hovered node
            for i = #self.popupStack, menuIndex + 1, -1 do
                table.remove(self.popupStack)
            end
            
            -- Open submenu on hover if it's a group
            if self.hoveredNode and self.hoveredNode:isGroup() then
                local parentMenu = menuIndex == 0 and self.root or self.popupStack[menuIndex].node
                local parentX = menuIndex == 0 and 0 or self.popupStack[menuIndex].x
                local parentY = menuIndex == 0 and 0 or self.popupStack[menuIndex].y
                local itemIndex = self:findNodeIndex(parentMenu, self.hoveredNode)
                local submenuX = parentX + self:calculateMenuWidth(parentMenu)
                local submenuY = parentY + (itemIndex - 1) * self.style.itemHeight
                
                self.context:debug_print_log('Opening submenu at (' .. submenuX .. ',' .. submenuY .. ')')
                table.insert(self.popupStack, {node = self.hoveredNode, x = submenuX, y = submenuY})
            end
        else
            -- Mouse is not over any menu item, close all submenus
            self.popupStack = {}
        end
    end
    
    return newHoveredNode ~= nil
end

function PopupMenu:handleInput(event)
    if not self.visible then return false end

    if event.type == EventType.MOUSE_PRESSED then
        return handlePress(self, event.data.x, event.data.y)
    elseif event.type == EventType.MOUSE_MOVED then
        return handleMove(self, event.data.x, event.data.y)
    end

    return false
end

function PopupMenu:getNodeAt(x, y)
    local localX, localY = x - self.x, y - self.y
    self.context:debug_print_log('getNodeAt: global(' .. x .. ',' .. y .. '), local(' .. localX .. ',' .. localY .. ')')
    
    -- Check submenus first (in reverse order)
    for i = #self.popupStack, 1, -1 do
        local submenu = self.popupStack[i]
        self.context:debug_print_log('Checking submenu ' .. i .. ' at (' .. submenu.x .. ',' .. submenu.y .. ')')
        if self:isPointInMenu(localX, localY, submenu) then
            local relativeY = localY - submenu.y
            local index = math.floor(relativeY / self.style.itemHeight) + 1
            if index > 0 and index <= #submenu.node.groupStatus.children then
                self.context:debug_print_log('Found node in submenu ' .. i .. ' at index ' .. index)
                return submenu.node.groupStatus.children[index], i
            end
        end
    end

    -- Check root menu
    self.context:debug_print_log('Checking root menu')
    if self:isPointInMenu(localX, localY, {node = self.root, x = 0, y = 0}) then
        local index = math.floor(localY / self.style.itemHeight) + 1
        if index > 0 and index <= #self.root.groupStatus.children then
            self.context:debug_print_log('Found node in root menu at index ' .. index)
            return self.root.groupStatus.children[index], 0
        end
    end
    
    self.context:debug_print_log('No node found')
    return nil, nil
end

function PopupMenu:isPointInMenu(x, y, menu)
    local menuWidth = self:calculateMenuWidth(menu.node)
    local menuHeight = #menu.node.groupStatus.children * self.style.itemHeight
    local isInMenu = x >= menu.x and x <= menu.x + menuWidth and
                     y >= menu.y and y <= menu.y + menuHeight
    self.context:debug_print_log('isPointInMenu: (' .. x .. ',' .. y .. ') in menu at (' .. menu.x .. ',' .. menu.y .. 
          ') with size ' .. menuWidth .. 'x' .. menuHeight .. ': ' .. tostring(isInMenu))
    return isInMenu
end

function PopupMenu:findNodeIndex(parentNode, targetNode)
    for i, child in ipairs(parentNode.groupStatus.children) do
        if child == targetNode then
            return i
        end
    end
    return 1
end

PopupMenu.MenuItem = MenuItem

return PopupMenu