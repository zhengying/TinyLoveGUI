local cwd = select(1, ...):match(".+%.") or ""
local Object = require(cwd .. "Object")
local PopupWindow = require(cwd .. "PopupWindow")
local GUIElement = require(cwd .. "GUIElement")
local GUIContext = require(cwd .. "GUIContext")

TooltipsMixin = Object:extend()

function TooltipsMixin:TooltipsMixin_init(options)
    assert(self:is(GUIElement), "TooltipsMixin requires GUIElement as base")
    self.tooltips_enabled = self.options.tooltips_enabled or false
    self.tooltips_text = self.options.tooltips_text or ""
end

function TooltipsMixin:showTooltip()
    PopupWindow.showTooltip(self,self.tooltips_text, self.width, self.height, 'left')
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

function TooltipsMixin:onPointerEnter()
    if self.tooltips_enabled then
        self:showTooltip()
    end
end

function TooltipsMixin:onPointerLeave()
    PopupWindow.dismissCurrentTooltip()
end




return TooltipsMixin