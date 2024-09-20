local cwd = select(1, ...):match(".+%.") or ""
local Object = require(cwd .. "Object")
local GUIElement = require(cwd .. "GUIElement")
local GUIContext = require(cwd .. "GUIContext")

local PopupWindow = GUIElement:extend()

PopupWindow.currentTooltip = nil
PopupWindow.currentTarget = nil

function PopupWindow:init(options)
    local maxWidth = options.width or 200
    self.font = options.font or love.graphics.newFont(12)
    self.padding = options.padding or {left=10, right=10, top=10, bottom=10}
    self.minWidth = options.minWidth or 100
    self.minHeight = options.minHeight or 40

    -- Create a text object with center alignment
    self.textObject = love.graphics.newText(self.font)
    self.textObject:setf(options.text, maxWidth - self.padding.left - self.padding.right, "left")
    -- Get the actual dimensions of the wrapped text
    local textWidth, textHeight = self.textObject:getDimensions()
    
    -- Adjust the popup size based on the text dimensions
    local width = math.max(options.width or 0, textWidth + self.padding.left + self.padding.right)
    local height = math.max(options.height or 0, textHeight + self.padding.top + self.padding.bottom)   

    PopupWindow.super.init(self, {x=options.x, y=options.y, width=width, height=height})
    self._text = options.text or ""
    self.targetX = options.targetX
    self.targetY = options.targetY
    self.targetWidth = options.targetWidth or 0
    self.targetHeight = options.targetHeight or 0
    self.arrowSize = 10
    self.backgroundColor = {0.9, 0.9, 0.9, 0.9}
    self.borderColor = {0.5, 0.5, 0.5, 1}
    self.textColor = {0, 0, 0, 1}


    self.zIndex = GUIContext.ZIndexGroup.POPUP
    self.tag = "PopupWindow"
    self.arrowDirection = options.arrowDirection or "auto"
    self.cornerRadius = 5
    self.arrowWidth = 20
    self.arrowHeight = 10
    self.maxArrowLength = 10
    self.cornerGap = 20
    self.visible = false
    
 
end

function PopupWindow:draw()
    if not self.visible then
        return
    end
    love.graphics.push()

    love.graphics.translate(self.x, self.y)
    
    -- Draw arrow first
    self:drawArrow()
    
    -- Draw background
    love.graphics.setColor(unpack(self.backgroundColor))
    love.graphics.rectangle("fill", 0, 0, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Draw text
    love.graphics.setColor(unpack(self.textColor))
    love.graphics.setFont(self.font)
    
    -- Draw the text centered
    -- love.graphics.printf(self.textObject, self.padding.left, (self.height - self.textObject:getHeight() ) / 2, 
    --                      self.width - self.padding.left - self.padding.right, "left")
   
    love.graphics.draw(self.textObject, self.padding.left, self.padding.top)

    love.graphics.pop()
end

function PopupWindow:drawArrow()
    local direction = self.arrowDirection
    if direction == "auto" then
        direction = self:calculateAutoDirection()
    end
    
    local arrowX, arrowY, targetX, targetY

    -- Calculate the arrow position relative to the target
    local relativeX, relativeY
    if direction == "left" then
        relativeX = self.targetX + self.targetWidth - self.x
        relativeY = self.targetY + self.targetHeight / 2 - self.y
    elseif direction == "right" then
        relativeX = self.targetX - self.x
        relativeY = self.targetY + self.targetHeight / 2 - self.y
    elseif direction == "top" then
        relativeX = self.targetX + self.targetWidth / 2 - self.x
        relativeY = self.targetY + self.targetHeight - self.y
    else -- bottom
        relativeX = self.targetX + self.targetWidth / 2 - self.x
        relativeY = self.targetY - self.y
    end

    -- Clamp the arrow position to the popup's edges, respecting the corner gap
    arrowX = math.max(self.cornerGap, math.min(relativeX, self.width - self.cornerGap))
    arrowY = math.max(self.cornerGap, math.min(relativeY, self.height - self.cornerGap))

    -- Adjust arrow position based on direction
    if direction == "top" then
        arrowY = 0
    elseif direction == "bottom" then
        arrowY = self.height
    elseif direction == "left" then
        arrowX = 0
    elseif direction == "right" then
        arrowX = self.width
    end

    -- Calculate the direction vector
    local dx = relativeX - arrowX
    local dy = relativeY - arrowY
    local length = math.sqrt(dx * dx + dy * dy)

    -- Limit the arrow length
    if length > self.maxArrowLength then
        dx = dx * self.maxArrowLength / length
        dy = dy * self.maxArrowLength / length
    end

    -- For left and right directions, adjust the arrow to point horizontally
    if direction == "left" then
        targetX = arrowX - self.arrowHeight
        targetY = arrowY
        arrowX = arrowX + 1  -- Slight offset to ensure the arrow is visible
    elseif direction == "right" then
        targetX = arrowX + self.arrowHeight
        targetY = arrowY
        arrowX = arrowX - 1  -- Slight offset to ensure the arrow is visible
    else
        targetX = arrowX + dx
        targetY = arrowY + dy
    end
    
    -- Draw the arrow
    love.graphics.setColor(unpack(self.backgroundColor))
    if direction == "left" or direction == "right" then
        love.graphics.polygon("fill", 
            arrowX, arrowY - self.arrowWidth / 2,
            arrowX, arrowY + self.arrowWidth / 2,
            targetX, targetY
        )
    else
        love.graphics.polygon("fill", 
            arrowX - self.arrowWidth / 2, arrowY,
            arrowX + self.arrowWidth / 2, arrowY,
            targetX, targetY
        )
    end
    
    -- Draw the arrow border
    love.graphics.setColor(unpack(self.borderColor))
    if direction == "left" or direction == "right" then
        love.graphics.line(
            arrowX, arrowY - self.arrowWidth / 2,
            targetX, targetY,
            arrowX, arrowY + self.arrowWidth / 2
        )
    else
        love.graphics.line(
            arrowX - self.arrowWidth / 2, arrowY,
            targetX, targetY,
            arrowX + self.arrowWidth / 2, arrowY
        )
    end
end


function PopupWindow:drawBorder()
    love.graphics.setColor(unpack(self.borderColor))
    local r = self.cornerRadius
    
    -- Top line (skip middle part if arrow is on top)
    if self.arrowDirection ~= "top" then
        love.graphics.line(r, 0, self.width - r, 0)
    else
        love.graphics.line(r, 0, self.width / 2 - 10, 0)
        love.graphics.line(self.width / 2 + 10, 0, self.width - r, 0)
    end
    
    -- Right line
    love.graphics.line(self.width, r, self.width, self.height - r)
    
    -- Bottom line (skip middle part if arrow is on bottom)
    if self.arrowDirection ~= "bottom" then
        love.graphics.line(self.width - r, self.height, r, self.height)
    else
        love.graphics.line(self.width - r, self.height, self.width / 2 + 10, self.height)
        love.graphics.line(self.width / 2 - 10, self.height, r, self.height)
    end
    
    -- Left line
    love.graphics.line(0, self.height - r, 0, r)
    
    -- Draw corners
    -- love.graphics.arc("line", r, r, r, math.pi, 3*math.pi/2)
    -- love.graphics.arc("line", self.width - r, r, r, 3*math.pi/2, 2*math.pi)
    -- love.graphics.arc("line", self.width - r, self.height - r, r, 0, math.pi/2)
    -- love.graphics.arc("line", r, self.height - r, r, math.pi/2, math.pi)
end

function PopupWindow:calculateAutoDirection()
    local centerX = self.x + self.width / 2
    local centerY = self.y + self.height / 2
    
    local dx = self.targetX + self.targetWidth / 2 - centerX
    local dy = self.targetY + self.targetHeight / 2 - centerY
    
    if math.abs(dx) > math.abs(dy) then
        return dx > 0 and "right" or "left"
    else
        return dy > 0 and "bottom" or "top"
    end
end

function PopupWindow:setText(text)
    self._text = text
    self.textObject:setf(text, self.width - 2 * self.padding.left, "left")
end

function PopupWindow:setTarget(x, y, width, height)
    self.targetX = x
    self.targetY = y
    self.targetWidth = width or 0
    self.targetHeight = height or 0
    self:recalculatePosition()
end

function PopupWindow:recalculatePosition()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local newX, newY, newDirection = PopupWindow.calculateBestPosition(
        self.targetX, self.targetY, self.targetWidth, self.targetHeight,
        self.width, self.height, screenWidth, screenHeight
    )
    
    self.x = newX
    self.y = newY
    self.arrowDirection = newDirection
end

function PopupWindow:setArrowDirection(direction)
    self.arrowDirection = direction
end

function PopupWindow:setTargetElement(target)
    self.targetElement = target
end

function PopupWindow.showTooltip(targetElement, text, width, height, arrowDirection)
    if targetElement == PopupWindow.currentTarget then
        return
    end
    local targetX, targetY = targetElement:getGlobalPosition()
    PopupWindow.currentTarget = targetElement
    PopupWindow.show(targetElement.context, targetX, targetY, targetElement.width, targetElement.height, width, height, text, arrowDirection)
end


-- Static method to create and add a popup to a parent element
function PopupWindow.show(context, targetX, targetY, targetWidth, targetHeight, width, height, text, arrowDirection)
    -- Dismiss the current tooltip if it exists
    if PopupWindow.currentTooltip then
        PopupWindow.currentTooltip:dismiss()
    end

    local popup = PopupWindow({x=0, y=0, width=width, height=height, text=text, targetX=targetX, targetY=targetY, targetWidth=targetWidth, targetHeight=targetHeight, arrowDirection=arrowDirection})
    context.root:addChild(popup)

    popup:setTarget(targetX, targetY, targetWidth, targetHeight)  -- This will set the target and recalculate the position
    popup.visible = true
    
    -- Set the current tooltip to the newly created popup
    PopupWindow.currentTooltip = popup
    
    return popup
end



function PopupWindow.calculateBestPosition(targetX, targetY, targetWidth, targetHeight, popupWidth, popupHeight, screenWidth, screenHeight)
    local padding = 10
    local arrowSize = 10
    local x, y, direction
    
    -- Calculate the center of the target
    local targetCenterX = targetX + targetWidth / 2
    local targetCenterY = targetY + targetHeight / 2
    
    -- Check if there's enough space below the target
    if targetY + targetHeight + popupHeight + arrowSize + padding <= screenHeight then
        y = targetY + targetHeight + arrowSize
        direction = "top"
    -- Check if there's enough space above the target
    elseif targetY - popupHeight - arrowSize - padding >= 0 then
        y = targetY - popupHeight - arrowSize
        direction = "bottom"
    -- If not enough vertical space, try horizontal placement
    else
        -- Check if there's enough space to the right of the target
        if targetX + targetWidth + popupWidth + arrowSize + padding <= screenWidth then
            x = targetX + targetWidth + arrowSize
            direction = "left"
        -- Check if there's enough space to the left of the target
        elseif targetX - popupWidth - arrowSize - padding >= 0 then
            x = targetX - popupWidth - arrowSize
            direction = "right"
        -- If no ideal position, default to below and adjust if necessary
        else
            y = math.min(targetY + targetHeight + arrowSize, screenHeight - popupHeight - padding)
            direction = "top"
        end
    end
    
    -- Calculate x position for vertical placements
    if direction == "top" or direction == "bottom" then
        x = math.max(padding, math.min(targetCenterX - popupWidth / 2, screenWidth - popupWidth - padding))
    end
    
    -- Calculate y position for horizontal placements
    if direction == "left" or direction == "right" then
        y = math.max(padding, math.min(targetCenterY - popupHeight / 2, screenHeight - popupHeight - padding))
    end
    
    return x, y, direction
end

function PopupWindow:dismiss()
    self.visible = false
    self:removeFromParent()
    
    -- Clear the current tooltip if it's this popup
    if PopupWindow.currentTooltip == self then
        PopupWindow.currentTooltip = nil
    end
    PopupWindow.currentTarget = nil
end

function PopupWindow.dismissCurrentTooltip()
    if PopupWindow.currentTooltip then
        PopupWindow.currentTooltip:dismiss()
    end
end



return PopupWindow