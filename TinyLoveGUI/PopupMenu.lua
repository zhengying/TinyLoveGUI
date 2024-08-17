local cwd = select(1, ...):match(".+%.") or ""
local TreeView, TreeNode = unpack(require(cwd .. "TreeView"))
local EventType = require(cwd .. "InputEventUtils").EventType
local PopupMenu = TreeView:extend()

function PopupMenu:init(items)
    PopupMenu.super.init(self, 0, 0, 100, 100)  -- Initial size, will be adjusted
    self.tag = 'PopupMenu'
    self.visible = false
    self.autoClose = true
    self.minWidth = 100
    self.maxWidth = 300
    self.minHeight = 30
    self.maxHeight = 400


    -- Override some style properties
    self:setStyle({
        bgColor = {0.95, 0.95, 0.95, 1},
        hoverColor = {0.8, 0.8, 0.8, 1},
        selectedColor = {0.7, 0.7, 0.7, 1},
        borderColor = {0.7, 0.7, 0.7, 1},
        borderWidth = 1,
        nodeHeight = 30,
        marginLeft = 10,
        marginRight = 10,
        marginTop = 5,
        marginBottom = 5,
        fontSize = 14
    })

    self:setItems(items)
end

local function updateContentSize(self)
    local font = love.graphics.getFont()
    local maxTextWidth = 0
    local totalHeight = 0

    for _, node in ipairs(self.root.groupStatus.children) do
        local textWidth = font:getWidth(node.title)
        if textWidth > maxTextWidth then
            maxTextWidth = textWidth
        end
        totalHeight = totalHeight + self.style.nodeHeight
    end

    local contentWidth = maxTextWidth + self.style.marginLeft + self.style.marginRight
    local contentHeight = totalHeight + self.style.marginTop + self.style.marginBottom

    self.width = math.max(self.minWidth, math.min(contentWidth, self.maxWidth))
    self.height = math.max(self.minHeight, math.min(contentHeight, self.maxHeight))
end

function PopupMenu:setItems(items)
    self.root.groupStatus.children = {}
    for _, item in ipairs(items) do
        self:addItem(item)
    end
    updateContentSize(self)
end

function PopupMenu:addItem(item)
    local node = TreeNode(item.text, item)
    node.action = item.action
    self.root:addChild(node)
    if item.submenu then
        for _, subitem in ipairs(item.submenu) do
            local subnode = self:addItem(subitem)
            node:addChild(subnode)
        end
    end
    return node
end

function PopupMenu:show(x, y)
    self.x = x
    self.y = y
    self.visible = true
    updateContentSize(self)
    -- Adjust position if menu goes off screen
    local screenWidth, screenHeight = love.graphics.getDimensions()
    if self.x + self.width > screenWidth then
        self.x = screenWidth - self.width
    end
    if self.y + self.height > screenHeight then
        self.y = screenHeight - self.height
    end
end

function PopupMenu:hide()
    self.visible = false
    self.selectedNode = nil  -- Clear selection when hiding
end

function PopupMenu:draw()
    if not self.visible then return end
    PopupMenu.super.draw(self)
end

-- function PopupMenu:handleInput(event)
--     if not self.visible then return false end
    
--     if event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED then
--         local handled = PopupMenu.super.handleInput(self, event)
--         if handled and self.selectedNode and self.selectedNode.action then
--             self.selectedNode.action()
--             if self.autoClose then
--                 self:hide()
--             else
--                 self.selectedNode = nil  -- Clear selection after action
--             end
--         elseif self.autoClose and not handled then
--             self:hide()
--         end
--         return handled
--     elseif event.type == EventType.MOUSE_MOVED then
--         -- Clear selection on mouse move
--         self.selectedNode = nil
--         return PopupMenu.super.handleInput(self, event)
--     else
--         return PopupMenu.super.handleInput(self, event)
--     end
-- end

return PopupMenu