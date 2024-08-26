local cwd = select(1, ...):match(".+%.") or ""
local Object = require(cwd .. "Object")
local PopupWindow = require(cwd .. "PopupWindow")
local GUIElement = require(cwd .. "GUIElement")
local GUIContext = require(cwd .. "GUIContext")

TooltipsMixin = Object:extend()


local function _onAddToContext(self)
    self.context:registerLocalEvent(GUIContext.LocalEvents.HIGHLIGHT_CHANGED,self,self.onHighlightChanged,nil)
end

function TooltipsMixin:TooltipsMixin_init(options)
    assert(self:is(GUIElement), "TooltipsMixin requires GUIElement as base")
    self.tooltips_enabled = self.options.tooltips_enabled or false
    self.tooltips_text = self.options.tooltips_text or ""

    self.tooltips_showed = false
    if self.onAddToContext then
        local onAddToContext = function ()
            self:onAddToContext()
            _onAddToContext(self)
        end

        self.onAddToContext = onAddToContext
    else
        self.onAddToContext = _onAddToContext
    end
end



function TooltipsMixin:onHighlightChanged(element)
    if not self.tooltips_enabled then
        return
    end

    if element == self then
        self:showTooltip()
    else 
        if self.tooltips_showed then
            self:dismissTooltip()
        end
    end
end

function TooltipsMixin:showTooltip()
    if self.customShowTooltipAt then
        -- TODO:
        local localpos = self:tooltipPosition()
        PopupWindow.customShowTooltipAt()
    else
        PopupWindow.showTooltip(self,self.tooltips_text, self.width, self.height, 'left')
    end
    self.tooltips_showed = true
end

function TooltipsMixin:dismissTooltip()
    PopupWindow.dismissCurrentTooltip()
    self.tooltips_showed = false
end

function TooltipsMixin:tooltips_enabled()
    return self.tooltips_enabled or false
end

function TooltipsMixin:setTooltipsEnabled(enabled)
    self.tooltips_enabled = enabled
end

function TooltipsMixin:tooltips_text()
    return self.tooltips_text or ""
end

function TooltipsMixin:setTooltipsText(text)
    self.tooltips_text = text
end

return TooltipsMixin