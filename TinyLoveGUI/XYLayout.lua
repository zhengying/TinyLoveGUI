local cwd = select(1, ...):match(".+%.") or ""
local Object = require(cwd .. "Object")
local Layout = require(cwd .. "Layout")
local XYLayout = Layout:extend()

function XYLayout:init(options)
    options = options or {}
    self.padding = options.padding or {left=5, right=5, top=5, bottom=5}
    self.children = {}
end

function XYLayout:updateLayout()
    for _, child in ipairs(self.children) do
        child:updateLayout()
    end
end

return XYLayout