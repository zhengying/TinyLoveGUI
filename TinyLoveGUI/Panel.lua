local cwd = select(1, ...):match(".+%.") or ""
local GUIElement = require(cwd .. "GUIElement")
local GUIContext = require(cwd .. "GUIContext")
local EventType = GUIContext.EventType
local Panel = GUIElement:extend()

function Panel:init(x, y, width, height, options)
    Panel.super.init(self, x, y, width, height)
    self.tag = "Panel"
    
    options = options or {}
    self.backgroundColor = options.backgroundColor or {0.8, 0.8, 0.8, 1}
    self.borderColor = options.borderColor or {0.5, 0.5, 0.5, 1}
    self.borderWidth = options.borderWidth or 1
    
    self.backgroundImage = options.backgroundImage
    self.backgroundPattern = options.backgroundPattern
    self.nineSliceImage = options.nineSliceImage
    self.nineSliceInsets = options.nineSliceInsets or {left = 8, right = 8, top = 8, bottom = 8}
    
    self.isModal = options.isModal or true
    self.modalDimColor = options.modalDimColor or {0, 0, 0, 0.8}
    self.modalBlurRadius = options.modalBlurRadius or 0  -- 0 means no blur, positive value for blur
    if self.isModal then
        self.zIndex = GUIContext.ZIndexGroup.MODAL_WINDOW
    end
end


local function handlePress(self, x, y, button)
    if self:isPointInside(x, y) == false then
        self:dismiss()
    end
    return false
end

local function handleMove(self, x, y, dx, dy)
    return false
end

local function handleRelease(self, x, y, button)
    return false
end


function Panel:handleInput(event)
    if not self.visible then return false end
    if Panel.super.handleInput(self, event) then
        return true
    end
    
    if event.type == EventType.MOUSE_PRESSED or event.type == EventType.TOUCH_PRESSED then
        return handlePress(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_RELEASED or event.type == EventType.TOUCH_RELEASED then
        return handleRelease(self, event.data.x, event.data.y, event.data.button)
    elseif event.type == EventType.MOUSE_MOVED or event.type == EventType.TOUCH_MOVED then
        return handleMove(self, event.data.x, event.data.y, event.data.dx, event.data.dy)
    end
    return false
end

function Panel:draw()
    if not self.visible then return false end

    if self.isModal then
        self:drawModalBackground()
    end

    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    
    if self.backgroundImage then
        self:drawBackgroundImage()
    elseif self.backgroundPattern then
        self:drawBackgroundPattern()
    elseif self.nineSliceImage then
        self:drawNineSliceBackground()
    else
        self:drawSolidBackground()
    end
    
    -- -- Draw border
    -- love.graphics.setColor(unpack(self.borderColor))
    -- love.graphics.setLineWidth(self.borderWidth)
    -- love.graphics.rectangle("line", 0, 0, self.width, self.height)
    
    -- Draw children
    for _, child in ipairs(self.children) do
        child:draw()
    end
    
    love.graphics.pop()
end

function Panel:drawModalBackground()
    local w, h = love.graphics.getDimensions()
    
    if self.modalBlurRadius > 0 then
        -- Implement blur effect here (requires shader)
        -- This is a placeholder for blur implementation
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    
    love.graphics.setColor(unpack(self.modalDimColor))
    love.graphics.rectangle("fill", 0, 0, w, h)
end

function Panel:drawSolidBackground()
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
end

function Panel:drawBackgroundImage()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.backgroundImage, 0, 0, 0, self.width / self.backgroundImage:getWidth(), self.height / self.backgroundImage:getHeight())
end

function Panel:drawBackgroundPattern()
    love.graphics.setColor(1, 1, 1, 1)
    local patternWidth, patternHeight = self.backgroundPattern:getDimensions()
    for y = 0, self.height, patternHeight do
        for x = 0, self.width, patternWidth do
            love.graphics.draw(self.backgroundPattern, x, y)
        end
    end
end

function Panel:drawNineSliceBackground()
    love.graphics.setColor(1, 1, 1, 1)
    local imgWidth, imgHeight = self.nineSliceImage:getDimensions()
    local left, right, top, bottom = self.nineSliceInsets.left, self.nineSliceInsets.right, self.nineSliceInsets.top, self.nineSliceInsets.bottom
    
    -- Corner quads
    local topLeft = love.graphics.newQuad(0, 0, left, top, imgWidth, imgHeight)
    local topRight = love.graphics.newQuad(imgWidth - right, 0, right, top, imgWidth, imgHeight)
    local bottomLeft = love.graphics.newQuad(0, imgHeight - bottom, left, bottom, imgWidth, imgHeight)
    local bottomRight = love.graphics.newQuad(imgWidth - right, imgHeight - bottom, right, bottom, imgWidth, imgHeight)
    
    -- Edge quads
    local topMiddle = love.graphics.newQuad(left, 0, imgWidth - left - right, top, imgWidth, imgHeight)
    local bottomMiddle = love.graphics.newQuad(left, imgHeight - bottom, imgWidth - left - right, bottom, imgWidth, imgHeight)
    local leftMiddle = love.graphics.newQuad(0, top, left, imgHeight - top - bottom, imgWidth, imgHeight)
    local rightMiddle = love.graphics.newQuad(imgWidth - right, top, right, imgHeight - top - bottom, imgWidth, imgHeight)
    
    -- Center quad
    local center = love.graphics.newQuad(left, top, imgWidth - left - right, imgHeight - top - bottom, imgWidth, imgHeight)
    
    -- Draw corners
    love.graphics.draw(self.nineSliceImage, topLeft, 0, 0)
    love.graphics.draw(self.nineSliceImage, topRight, self.width - right, 0)
    love.graphics.draw(self.nineSliceImage, bottomLeft, 0, self.height - bottom)
    love.graphics.draw(self.nineSliceImage, bottomRight, self.width - right, self.height - bottom)
    
    -- Draw edges
    local scaleX = (self.width - left - right) / (imgWidth - left - right)
    local scaleY = (self.height - top - bottom) / (imgHeight - top - bottom)
    
    love.graphics.draw(self.nineSliceImage, topMiddle, left, 0, 0, scaleX, 1)
    love.graphics.draw(self.nineSliceImage, bottomMiddle, left, self.height - bottom, 0, scaleX, 1)
    love.graphics.draw(self.nineSliceImage, leftMiddle, 0, top, 0, 1, scaleY)
    love.graphics.draw(self.nineSliceImage, rightMiddle, self.width - right, top, 0, 1, scaleY)
    
    -- Draw center
    love.graphics.draw(self.nineSliceImage, center, left, top, 0, scaleX, scaleY)
end

function Panel:setBackgroundImage(image)
    self.backgroundImage = image
    self.backgroundPattern = nil
    self.nineSliceImage = nil
end

function Panel:setBackgroundPattern(pattern)
    self.backgroundPattern = pattern
    self.backgroundImage = nil
    self.nineSliceImage = nil
end

function Panel:setNineSliceBackground(image, insets)
    self.nineSliceImage = image
    self.nineSliceInsets = insets or self.nineSliceInsets
    self.backgroundImage = nil
    self.backgroundPattern = nil
end

-- function Panel:setModal(isModal,dimColor, blurRadius)
--     self.isModal = isModal
--     if dimColor then
--         self.modalDimColor = dimColor
--     end
--     if blurRadius then
--         self.modalBlurRadius = blurRadius
--     end
--     if self.isModal then
--         self.zIndex = GUIContext.ZIndexGroup.MODAL_WINDOW
--         if self.context then
--             self.context:pushModal(self)
--         end
--     else
--         self.zIndex = GUIContext.ZIndexGroup.NORMAL
--         if self.context then
--             self.context:popModal()
--         end
--     end
--     if self.parent then
--         self.parent:sortChildren()
--     end
-- end

function Panel:doModal(dimColor, blurRadius)
    if not self.isModal then
        assert(false, "Panel is not modal")
        return
    end

    if dimColor then
        self.modalDimColor = dimColor
    end
    if blurRadius then
        self.modalBlurRadius = blurRadius
    end

    self.zIndex = GUIContext.ZIndexGroup.MODAL_WINDOW
    if self.context then
        self.context:pushModal(self)
    end

    if self.parent then
        self.parent:sortChildren()
    end
    self.visible = true
end

function Panel:dismiss()
    self.zIndex = GUIContext.ZIndexGroup.NORMAL
    if self.context then
        self.context:popModal()
    end
    self.visible = false
end

return Panel