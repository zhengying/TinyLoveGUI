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

-- this object class from SNKRX (https://github.com/a327ex/SNKRX/blob/master/engine/game/object.lua)
local Object = {}
Object.__index = Object
function Object:init()
end
function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end
function Object:implement(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end
function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end
function Object:__tostring()
  return "Object"
end
function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:init(...)
  return obj
end


-- GUI framework functionality
local overlayLayer = {}
local function drawOverlayLayer()
    for _, item in ipairs(overlayLayer) do
        item:drawDropdown()
    end
end
local function handleOverlayMouseEvent(eventName, ...)
  for i = #overlayLayer, 1, -1 do  -- Process from top to bottom
      local item = overlayLayer[i]
      if item[eventName] then
          local handled = item[eventName](item, ...)
          if handled then
              return true  -- Event was handled by an overlay item
          end
      end
  end
  return false  -- Event was not handled by any overlay item
end

-- View class
local View = Object:extend()

function View:init(x, y, width, height, r, sx, sy)
  self.transform_data = {
    x = x or 0,
    y = y or 0,
    w = width or 100,
    h = height or 100,
    r = r or 0,
    sx = sx or 1,
    sy = sy or 1,
  }
  self.transform = love.math.newTransform(x,y)
  self.globalTransform = love.math.newTransform()
  self.children = {}
  self.parent = nil
  self.focused = false
  self.dirty = true  
  self.pressed = false  -- Add this flag
end

function View:updateTransform()
  if self.dirty then
    self.transform:setTransformation(
      self.transform_data.x, self.transform_data.y,
      self.transform_data.r,
      self.transform_data.sx, self.transform_data.sy
    )
    self:updateGlobalTransform()
    self.dirty = false
  end
end

function View:updateGlobalTransform()
  self.globalTransform:reset()
  self.globalTransform:apply(self.transform)
  if self.parent then
    self.parent:updateTransform()  -- Ensure parent is up to date
    self.globalTransform:apply(self.parent.globalTransform)
  end
  -- Mark children as dirty
  for _, child in ipairs(self.children) do
    child.dirty = true
  end
end

function View:setTransform(x, y, r, sx, sy)
  local changed = false
  if self.transform_data.x ~= x or self.transform_data.y ~= y or
     self.transform_data.r ~= r or self.transform_data.sx ~= sx or
     self.transform_data.sy ~= sy then
    self.transform_data.x = x
    self.transform_data.y = y
    self.transform_data.r = r
    self.transform_data.sx = sx
    self.transform_data.sy = sy
    changed = true
  end
  if changed then
    self.dirty = true
    -- Mark all children as dirty
    for _, child in ipairs(self.children) do
      child.dirty = true
    end
  end
end

function View:addChild(child)
  table.insert(self.children, child)
  child.parent = self

end

function View:removeChild(child)
  for i, v in ipairs(self.children) do
    if v == child then
      table.remove(self.children, i)
      child.parent = nil
      break
    end
  end
end

function View:draw()
  love.graphics.push()
  love.graphics.applyTransform(self.transform)
  if self.border_enable == true then
    love.graphics.rectangle("line", 0, 0, self.transform_data.w, self.transform_data.h)
  end
  for _, child in ipairs(self.children) do
    print('self.transform_data.x y:{'..tostring(self.transform_data.x)..','..tostring(self.transform_data.y)..'}')
    child:draw()
  end
  love.graphics.pop()
end

function View:getGlobalPosition()
  -- Start with this view's transform
  local globalTransform = love.math.newTransform()
  globalTransform:apply(self.transform)
  
  -- Apply parent transforms
  local current = self.parent
  while current do
    globalTransform:apply(current.transform)
    current = current.parent
  end
  
  -- Transform the local origin (0, 0) to get the global position
  local globalX, globalY = globalTransform:transformPoint(0, 0)
  
  return globalX, globalY
end

function View:update(dt)
  for _, child in ipairs(self.children) do
    if child.update then
      child:update(dt)
      child:updateTransform()
    end
  end
end

function View:mousepressed(x, y, button)
    local localX, localY = x - self.transform_data.x, y - self.transform_data.y
    if localX >= 0 and localX < self.transform_data.w and localY >= 0 and localY < self.transform_data.h then
      self.focused = true
      self.pressed = true  -- Set the flag
      for _, child in ipairs(self.children) do
        if child.mousepressed then
          child:mousepressed(localX, localY, button)
        end
      end
    else
      self.focused = false
      self.pressed = false  -- Set the flag
    end
  end
  
  function View:mousereleased(x, y, button)
    if self.pressed == true then
      local localX, localY = x - self.transform_data.x, y - self.transform_data.y
      for _, child in ipairs(self.children) do
        if child.mousereleased then
          child:mousereleased(localX, localY, button)
        end
      end
      self.pressed = false
    end
  end
  
  function View:mousemoved(x, y, dx, dy)
    local localX, localY = x - self.transform_data.x, y - self.transform_data.y
    local localDX, localDY = dx, dy
    for _, child in ipairs(self.children) do
      if child.mousemoved then
        child:mousemoved(localX, localY, localDX, localDY)
      end
    end
  end

  function View:wheelmoved(x, y)
    for _, child in ipairs(self.children) do
      if child.wheelmoved then
        child:wheelmoved(x, y)
      end
    end
  end
  

-- RowLayout
local RowLayout = View:extend()

function RowLayout:init(x, y, width, height, padding)
  RowLayout.super.init(self, x, y, width, height)
  self.padding = padding or 4
  self.border_enable = false
end

function RowLayout:addChild(child)
  RowLayout.super.addChild(self, child)
  self:updateLayout()
end

function RowLayout:updateLayout()
  local x = self.padding
  for _, child in ipairs(self.children) do
    child.transform_data.x = x
    child.transform_data.y = (self.transform_data.h - child.transform_data.h) / 2
    x = x + child.transform_data.w + self.padding
  end
end

-- ColumnLayout
local ColumnLayout = View:extend()

function ColumnLayout:init(x, y, width, height, padding)
  ColumnLayout.super.init(self, x, y, width, height)
  self.padding = padding or 4
  self.border_enable = false
end

function ColumnLayout:addChild(child)
  ColumnLayout.super.addChild(self, child)
  self:updateLayout()
end

function ColumnLayout:updateLayout()
  local y = self.padding
  for _, child in ipairs(self.children) do
    child.transform_data.x = (self.transform_data.w - child.transform_data.w) / 2
    child.transform_data.y = y
    y = y + child.transform_data.h + self.padding
  end
end

-- Control classes
local Button = View:extend()

function Button:init(x, y, width, height, text)
  Button.super.init(self, x, y, width, height)
  self.text = text or "Button"
  self.onClick = function() end
  self.state = "normal"  -- can be "normal", "hover", or "pressed"
end

function Button:draw()
  local colors = {
    normal = {0.7, 0.7, 0.7},
    hover = {0.8, 0.8, 0.8},
    pressed = {0.6, 0.6, 0.6}
  }
  love.graphics.setColor(unpack(colors[self.state]))
  love.graphics.rectangle("fill", self.transform_data.x, self.transform_data.y, self.transform_data.w, self.transform_data.h)
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf(self.text, self.transform_data.x, self.transform_data.y + self.transform_data.h / 2 - 10,self.transform_data.w, "center")
  love.graphics.setColor(1, 1, 1)
end

function Button:mousepressed(x, y, button)
    local localX, localY = x - self.transform_data.x, y - self.transform_data.y
    if button == 1 and localX >= 0 and localX <= self.transform_data.w and localY >= 0 and localY <= self.transform_data.h then
      self.state = "pressed"
    end
  end
  
  function Button:mousereleased(x, y, button)
    local localX, localY = x - self.transform_data.x, y - self.transform_data.y
    if button == 1 then
      if localX >= 0 and localX <= self.transform_data.w and localY >= 0 and localY <= self.transform_data.h then
        self.onClick()
      end
      self.state = "normal"
    end
  end
  
  function Button:mousemoved(x, y, dx, dy)
    local localX, localY = x - self.transform_data.x, y - self.transform_data.y
    if localX >= 0 and localX <= self.transform_data.w and localY >= 0 and localY <= self.transform_data.h then
      if self.state ~= "pressed" then
        self.state = "hover"
      end
    else
      if self.state ~= "pressed" then
        self.state = "normal"
      end
    end
  end
  

local Slider = View:extend()

function Slider:init(x, y, width, height, min, max, value)
  Slider.super.init(self, x, y, width, height)
  self.min = min or 0
  self.max = max or 100
  self.value = value or self.min
  self.onChange = function(value) end
  self.dragging = false
end

function Slider:draw()
  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.rectangle("fill", self.transform_data.x, self.transform_data.y + self.transform_data.h / 2 - 2, self.transform_data.w, 4)
  local knobX = self.transform_data.x + (self.value - self.min) / (self.max - self.min) * self.transform_data.w
  love.graphics.setColor(0.9, 0.9, 0.9)
  love.graphics.circle("fill", knobX, self.transform_data.y + self.transform_data.h / 2, 8)
  love.graphics.setColor(1, 1, 1)
end

function Slider:mousepressed(x, y, button)
    local localX, localY = x - self.transform_data.x, y - self.transform_data.y
    if button == 1 and localX >= 0 and localX <= self.transform_data.w and localY >= 0 and localY <= self.transform_data.h then
      self.dragging = true
      self:updateValue(localX)
    end
  end
  
  function Slider:mousereleased(x, y, button)
    local localX, localY = x - self.transform_data.x, y - self.transform_data.y
    if button == 1 and localX >= 0 and localX <= self.transform_data.w and localY >= 0 and localY <= self.transform_data.h then
      self.dragging = false
    end
  end
  
  function Slider:mousemoved(x, y, dx, dy)
    if self.dragging then
      local localX = x - self.transform_data.x
      self:updateValue(localX)
    end
  end
  
  function Slider:updateValue(localX)
    local newValue = self.min + (localX / self.transform_data.w) * (self.max - self.min)
    self.value = math.max(self.min, math.min(self.max, newValue))
    self.onChange(self.value)
  end
  

local Popup = View:extend()

function Popup:init(x, y, width, height, text)
  Popup.super.init(self, x, y, width, height)
  self.text = text or ""
  self.visible = false
  self.lifetime = 0
  self.maxLifetime = 2  -- seconds
end

function Popup:draw()
  if self.visible then
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", self.transform_data.x, self.transform_data.y, self.transform_data.w, self.transform_data.h)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(self.text, self.transform_data.x, self.transform_data.y + self.transform_data.h / 2 - 10, self.transform_data.w, "center")
  end
end

function Popup:update(dt)
  if self.visible then
    self.lifetime = self.lifetime + dt
    if self.lifetime >= self.maxLifetime then
      self.visible = false
      self.lifetime = 0
    end
  end
end

function Popup:show(text)
  self.text = text
  self.visible = true
  self.lifetime = 0
end

-- TextArea control
local TextArea = View:extend()

function TextArea:init(x, y, width, height, text, multiline)
  TextArea.super.init(self, x, y, width, height)
  self.text = text or ""
  self.multiline = multiline or false
  self.cursorPosition = #self.text + 1
  self.isFocused = false
  self.font = love.graphics.getFont()
  self.scrollOffset = 0
  self.scrollSpeed = 20
end

function TextArea:draw()
  self:updateTransform()  -- Ensure transform is up to date

  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle("line", self.transform_data.x, self.transform_data.y, self.transform_data.w, self.transform_data.h)

  local globalX, globalY = self.globalTransform:transformPoint(0, 0)
  local globalTopRight = {self.globalTransform:transformPoint(self.transform_data.w, 0)}
  local globalBottomLeft = {self.globalTransform:transformPoint(0, self.transform_data.h)}
  
  local globalWidth = globalTopRight[1] - globalX
  local globalHeight = globalBottomLeft[2] - globalY

  love.graphics.intersectScissor(globalX, globalY, globalWidth, globalHeight)
  love.graphics.setColor(1, 1, 1)

  if self.multiline then
    local wrappedText, wrappedLines = self:wrapText(self.text, self.transform_data.w - 10)
    love.graphics.printf(wrappedText, self.transform_data.x + 5, self.transform_data.y + 5 - self.scrollOffset, self.transform_data.w - 10)
  else
    love.graphics.print(self.text, self.transform_data.x + 5, self.transform_data.y + self.transform_data.h / 2 - self.font:getHeight() / 2)
  end

  if self.isFocused then
    local cursorX, cursorY = self:getCursorPosition()
    love.graphics.line(cursorX, cursorY - self.scrollOffset, cursorX, cursorY + self.font:getHeight() - self.scrollOffset)
  end

  love.graphics.setScissor()

  -- Draw scroll bar
  if self.multiline then
    self:drawScrollBar()
  end

  love.graphics.setColor(1, 1, 1)
end

function TextArea:drawScrollBar()
  local _, wrappedLines = self:wrapText(self.text, self.transform_data.w - 10)
  if #wrappedLines * self.font:getHeight() > self.transform_data.h then
    local totalHeight = #wrappedLines * self.font:getHeight()
    local visibleRatio = self.transform_data.h / totalHeight
    local scrollBarHeight = self.transform_data.h * visibleRatio
    local scrollBarY = self.transform_data.y + (self.scrollOffset / totalHeight) * self.transform_data.h

    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", self.transform_data.x + self.transform_data.w - 10, scrollBarY, 10, scrollBarHeight)
  end
end

function TextArea:mousepressed(x, y, button)
  local localX, localY = x - self.transform_data.x, y - self.transform_data.y
  if button == 1 and localX >= 0 and localX <= self.transform_data.w and localY >= 0 and localY <= self.transform_data.h then
    self.isFocused = true
    self:setCursorFromMouse(localX, localY + self.scrollOffset)
  else
    self.isFocused = false
  end
end

function TextArea:keypressed(key)
  if not self.isFocused then return end

  if key == "backspace" then
    if self.cursorPosition > 1 then
      self.text = self.text:sub(1, self.cursorPosition - 2) .. self.text:sub(self.cursorPosition)
      self.cursorPosition = self.cursorPosition - 1
    end
  elseif key == "return" and self.multiline then
    self.text = self.text:sub(1, self.cursorPosition - 1) .. "\n" .. self.text:sub(self.cursorPosition)
    self.cursorPosition = self.cursorPosition + 1
  elseif key == "left" then
    if self.cursorPosition > 1 then
      self.cursorPosition = self.cursorPosition - 1
    end
  elseif key == "right" then
    if self.cursorPosition <= #self.text then
      self.cursorPosition = self.cursorPosition + 1
    end
  elseif key == "up" and self.multiline then
    self.scrollOffset = math.max(0, self.scrollOffset - self.scrollSpeed)
  elseif key == "down" and self.multiline then
    local _, wrappedLines = self:wrapText(self.text, self.transform_data.w - 10)
    local totalHeight = #wrappedLines * self.font:getHeight()
    self.scrollOffset = math.min(totalHeight - self.transform_data.h, self.scrollOffset + self.scrollSpeed)
  end
end

function TextArea:textinput(t)
  if self.isFocused then
    self.text = self.text:sub(1, self.cursorPosition - 1) .. t .. self.text:sub(self.cursorPosition)
    self.cursorPosition = self.cursorPosition + #t
  end
end

function TextArea:wheelmoved(x, y)
  if self.isFocused and self.multiline then
    self.scrollOffset = math.max(0, self.scrollOffset - y * self.scrollSpeed)
    local _, wrappedLines = self:wrapText(self.text, self.transform_data.w - 10)
    local totalHeight = #wrappedLines * self.font:getHeight()
    self.scrollOffset = math.min(totalHeight - self.transform_data.h, self.scrollOffset)
  end
end

function TextArea:wrapText(text, limit)
  local wrappedText = ""
  local width, lines = self.font:getWrap(text, limit)
  for i, line in ipairs(lines) do
    wrappedText = wrappedText .. line
    if i < #lines then
      wrappedText = wrappedText .. "\n"
    end
  end
  return wrappedText, lines
end

function TextArea:getCursorPosition()
  local textBeforeCursor = self.text:sub(1, self.cursorPosition - 1)
  local wrappedText, lines = self:wrapText(textBeforeCursor, self.transform_data.w - 10)
  local cursorX = self.transform_data.x + 5 + self.font:getWidth(lines[#lines])
  local cursorY = self.transform_data.y + 5 + (#lines - 1) * self.font:getHeight()
  return cursorX, cursorY
end

function TextArea:setCursorFromMouse(localX, localY)
  local lines = {}
  if self.multiline then
    _, lines = self:wrapText(self.text, self.transform_data.w - 10)
  else
    lines[1] = self.text
  end

  local lineHeight = self.font:getHeight()
  local lineIndex = math.floor((localY - 5) / lineHeight) + 1
  lineIndex = math.max(1, math.min(lineIndex, #lines))

  local cursorPosInLine = self:getCursorPosInLine(lines[lineIndex], localX - 5)
  local cursorPosition = 0
  for i = 1, lineIndex - 1 do
    cursorPosition = cursorPosition + #lines[i] + 1
  end
  cursorPosition = cursorPosition + cursorPosInLine
  self.cursorPosition = math.max(1, math.min(cursorPosition, #self.text + 1))
end

function TextArea:getCursorPosInLine(line, localX)
  local width = 0
  for i = 1, #line do
    width = width + self.font:getWidth(line:sub(i, i))
    if width >= localX then
      return i
    end
  end
  return #line + 1
end

local ProgressBar = View:extend()

function ProgressBar:init(x, y, width, height, min, max, value)
    ProgressBar.super.init(self, x, y, width, height)
    self.min = min or 0
    self.max = max or 100
    self.value = value or self.min
    self.backgroundColor = {0.2, 0.2, 0.2}
    self.fillColor = {0.4, 0.7, 1}
    self.borderColor = {1, 1, 1}
    self.showPercentage = true
    self.percentageColor = {1, 1, 1}
end

function ProgressBar:setValue(value)
    self.value = math.max(self.min, math.min(self.max, value))
end

function ProgressBar:setColors(backgroundColor, fillColor, borderColor, percentageColor)
    self.backgroundColor = backgroundColor or self.backgroundColor
    self.fillColor = fillColor or self.fillColor
    self.borderColor = borderColor or self.borderColor
    self.percentageColor = percentageColor or self.percentageColor
end

function ProgressBar:draw()
    self:updateTransform()

    love.graphics.push()
    love.graphics.applyTransform(self.transform)

    -- Draw background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", 0, 0, self.transform_data.w, self.transform_data.h)

    -- Draw fill
    local fillWidth = (self.value - self.min) / (self.max - self.min) * self.transform_data.w
    love.graphics.setColor(self.fillColor)
    love.graphics.rectangle("fill", 0, 0, fillWidth, self.transform_data.h)

    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", 0, 0, self.transform_data.w, self.transform_data.h)

    -- Draw percentage text if enabled
    if self.showPercentage then
        love.graphics.setColor(self.percentageColor)
        local percentage = math.floor((self.value - self.min) / (self.max - self.min) * 100)
        local text = tostring(percentage) .. "%"
        local font = love.graphics.getFont()
        local textWidth = font:getWidth(text)
        local textHeight = font:getHeight()
        love.graphics.print(text, 
            self.transform_data.w / 2 - textWidth / 2, 
            self.transform_data.h / 2 - textHeight / 2)
    end

    love.graphics.pop()
end

-- Optional: Add update method if you want to animate the progress bar
function ProgressBar:update(dt)
    -- Add any animation logic here if needed
end

local OptionSelect = View:extend()

function OptionSelect:init(x, y, width, height, options, selectedIndex)
  OptionSelect.super.init(self, x, y, width, height)
  self.options = options or {}
  self.selectedIndex = selectedIndex or 1
  self.isOpen = false
  self.maxVisibleOptions = 5
  self.scrollOffset = 0
  self.itemHeight = 30
  self.onChange = function(selectedOption, selectedIndex) end
  self.font = love.graphics.getFont()
  self.colors = {
      background = {0.9, 0.9, 0.9},
      text = {0.1, 0.1, 0.1},
      selected = {0.7, 0.8, 1},
      hover = {0.8, 0.9, 1},
      border = {0.5, 0.5, 0.5}
  }
  self.dropdownTransform = love.math.newTransform()

    self.dropdownOverlay = {
        draw = function()
            self:drawDropdown()
        end
    }
    self.hoverIndex = nil
    self.dropdownHeight = 0
end

function OptionSelect:openDropdown()
  self.isOpen = true
  self:updateDropdownTransform()
  self.dropdownHeight = math.min(#self.options, self.maxVisibleOptions) * self.itemHeight
  table.insert(overlayLayer, self)
end

function OptionSelect:closeDropdown()
  self.isOpen = false
  for i, item in ipairs(overlayLayer) do
      if item == self then
          table.remove(overlayLayer, i)
          break
      end
  end
end
function OptionSelect:mousepressed(x, y, button)
  if not self.isOpen then
      local localX, localY = x - self.transform_data.x, y - self.transform_data.y
      if button == 1 and localX >= 0 and localX <= self.transform_data.w and localY >= 0 and localY <= self.transform_data.h then
          self:openDropdown()
          return true
      end
  else
      local dropdownX, dropdownY = self.dropdownTransform:transformPoint(0, 0)
      local inDropdownX = x >= dropdownX and x <= dropdownX + self.transform_data.w
      local inDropdownY = y >= dropdownY and y <= dropdownY + self.dropdownHeight
      
      if inDropdownX and inDropdownY then
          local dropdownLocalY = y - dropdownY
          local selectedOption = math.floor(dropdownLocalY / self.itemHeight) + 1 + self.scrollOffset
          if selectedOption > 0 and selectedOption <= #self.options then
              self.selectedIndex = selectedOption
              self.onChange(self.options[self.selectedIndex], self.selectedIndex)
              self:closeDropdown()
          end
      else
          self:closeDropdown()
      end
      return true  -- Always return true when open to capture all clicks
  end
  return false
end

function OptionSelect:mousemoved(x, y, dx, dy)
  if self.isOpen then
      local dropdownX, dropdownY = self.dropdownTransform:transformPoint(0, 0)
      local dropdownLocalY = y - dropdownY
      self.hoverIndex = math.floor(dropdownLocalY / self.itemHeight) + 1 + self.scrollOffset
      if self.hoverIndex <= 0 or self.hoverIndex > #self.options then
          self.hoverIndex = nil
      end
      return true
  end
  return false
end

function OptionSelect:draw()
  self:updateTransform()
  love.graphics.push()
  love.graphics.applyTransform(self.transform)

  -- Draw the main box
  love.graphics.setColor(self.colors.background)
  love.graphics.rectangle("fill", 0, 0, self.transform_data.w, self.transform_data.h)
  love.graphics.setColor(self.colors.border)
  love.graphics.rectangle("line", 0, 0, self.transform_data.w, self.transform_data.h)

  -- Draw the selected option
  love.graphics.setColor(self.colors.text)
  love.graphics.printf(self.options[self.selectedIndex] or "", 5, self.transform_data.h / 2 - self.font:getHeight() / 2, self.transform_data.w - 25, "left")

  -- Draw the dropdown arrow
  local arrowSize = 10
  local arrowX = self.transform_data.w - 15
  local arrowY = self.transform_data.h / 2
  love.graphics.polygon("fill", 
      arrowX - arrowSize/2, arrowY - arrowSize/2,
      arrowX + arrowSize/2, arrowY - arrowSize/2,
      arrowX, arrowY + arrowSize/2
  )

  love.graphics.pop()
end

function OptionSelect:drawDropdown()
  if not self.isOpen then return end

  love.graphics.push()
  love.graphics.applyTransform(self.dropdownTransform)

  local dropdownHeight = math.min(#self.options, self.maxVisibleOptions) * self.itemHeight
  love.graphics.setColor(self.colors.background)
  love.graphics.rectangle("fill", 0, 0, self.transform_data.w, dropdownHeight)
  love.graphics.setColor(self.colors.border)
  love.graphics.rectangle("line", 0, 0, self.transform_data.w, dropdownHeight)

  love.graphics.setScissor(self.transform_data.x, self.transform_data.y + self.transform_data.h, self.transform_data.w, dropdownHeight)
  
  for i = 1, math.min(#self.options, self.maxVisibleOptions) do
      local optionIndex = i + self.scrollOffset
      if optionIndex <= #self.options then
          local y = (i - 1) * self.itemHeight - self.scrollOffset * self.itemHeight
          if optionIndex == self.selectedIndex then
              love.graphics.setColor(self.colors.selected)
              love.graphics.rectangle("fill", 0, y, self.transform_data.w, self.itemHeight)
          elseif optionIndex == self.hoverIndex then
              love.graphics.setColor(self.colors.hover)
              love.graphics.rectangle("fill", 0, y, self.transform_data.w, self.itemHeight)
          end
          love.graphics.setColor(self.colors.text)
          love.graphics.printf(self.options[optionIndex], 5, y + self.itemHeight / 2 - self.font:getHeight() / 2, self.transform_data.w - 10, "left")
      end
  end

  love.graphics.setScissor()
  love.graphics.pop()
end

function OptionSelect:wheelmoved(x, y)
  if self.isOpen and #self.options > self.maxVisibleOptions then
      self.scrollOffset = math.max(0, math.min(self.scrollOffset - y, #self.options - self.maxVisibleOptions))
  end
end

function OptionSelect:updateDropdownTransform()
  local x, y = self.transform:transformPoint(0, self.transform_data.h)
  self.dropdownTransform:setTransformation(x, y)
end

function OptionSelect:update(dt)
    -- Add any animation or update logic here if needed
end

return {
  View = View,
  RowLayout = RowLayout,
  ColumnLayout = ColumnLayout,
  Button = Button,
  Slider = Slider,
  Popup = Popup,
  TextArea = TextArea,
  ProgressBar = ProgressBar,
  OptionSelect = OptionSelect,
  drawOverlayLayer = drawOverlayLayer,
  handleOverlayMouseEvent = handleOverlayMouseEvent  -- Add this line
}