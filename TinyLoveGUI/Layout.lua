local cwd = select(1, ...):match(".+%.") or ""
local Object = require(cwd .. "Object")
local Layout = Object:extend()

function Layout:init(options)
    options = options or {}
    self.owner = options.owner
    self.padding = options.padding or {left=5, right=5, top=5, bottom=5}
    self.children = {}
    self.sortedChildren = {}
    self.needSortChildren = true
end

function Layout:setOwner(owner)
    self.owner = owner
end

function Layout:getOwner()
    return self.owner
end

function Layout:getSize()
    assert(self.owner, "Owner not set")
    return self.owner.width, self.owner.height
end

function Layout:addChild(child)
    -- table.insert(self.children, child)
    -- self:updateLayout()
end

function Layout:removeChild(child)
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            self.needSortChildren = true
            break
        end
    end
    self:updateLayout()
end

function Layout:getWidth()
    return 0
end

function Layout:getNeedSortChildren()
    return self.needSortChildren
end

function Layout:setNeedSortChildren(needSortChildren)
    self.needSortChildren = needSortChildren
end

function Layout:sortChildren()
    if not self.needSortChildren then
        return self.sortedChildren or {}
    end
    self.needSortChildren = false   
    self.sortedChildren = table.sortedTable(self.children, function(a, b)
        return a.zIndex < b.zIndex
    end)
    return self.sortedChildren
end

function Layout:getHeight()
    return 0
end

function Layout:getChildren()
    return self.children
end

function Layout:update(dt)
    -- To be implemented by subclasses if needed
end

function Layout:updateLayout()
    -- To be implemented by subclasses
end

return Layout