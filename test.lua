if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local FlowLayout = require("TinyLoveGUI.FlowLayout")
local GUIContext = require("TinyLoveGUI.GUIContext")
local GUIElement = require("TinyLoveGUI.GUIElement")

-- Mock GUIElement for testing
local function MockElement(width, height)
    local element = GUIElement(0, 0, width, height)
    element.getSize = function(self) return self.width, self.height end
    return element
end

-- Test cases
local function runTests()
    local tests = {
        -- Test 1: Basic horizontal layout
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, {left=5, right=5, top=5, bottom=5}, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
            context:addChild(layout)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            
            assert(layout:getWidth() == 300, "Layout width should be 300")
            assert(layout:getHeight() == 100, "Layout height should be 100")
            assert(layout.children[1].x == 5, "First child should start at x=5 (left padding)")
            assert(layout.children[2].x == 55, "Second child should start at x=60 (left padding + first child width)")
            assert(layout.children[3].x == 105, "Third child should start at x=110 (left padding + first two children widths)")
        end,

        -- Test 2: Vertical layout with expanding children
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 100, 300, {1,1,1}, {left=10, right=10, top=10, bottom=10}, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
            context:addChild(layout)
            
            layout:addChild(MockElement(50, 50), 1)
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50), 2)
            
            assert(layout:getHeight() == 300, "Layout height should be 300")
            assert(layout.children[1].height > 50, "First child should expand")
            assert(layout.children[2].height == 50, "Second child should not expand")
            assert(layout.children[3].height > layout.children[1].height, "Third child should expand more than first")
            assert(layout.children[1].y == 10, "First child should start at y=10 (top padding)")
        end,

        -- Test 3: FILL_PARENT width mode
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FILL_PARENT, FlowLayout.SizeMode.FIXED)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            
            assert(layout:getWidth() == 800, "Layout width should fill parent (800)")
            assert(layout:getHeight() == 100, "Layout height should remain fixed")
            assert(layout.children[1].x == 10, "First child should start at x=10 (left padding)")
        end,

        -- Test 4: WRAP_CONTENT height mode
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 100, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FIXED, FlowLayout.SizeMode.WRAP_CONTENT)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 70))
            
            assert(layout:getWidth() == 100, "Layout width should remain fixed")
            assert(layout:getHeight() == 140, "Layout height should wrap content (10 + 50 + 10 + 70 + 10)")
            assert(layout.children[1].y == 10, "First child should start at y=10 (top padding)")
        end,

        -- Test 5: Resizing parent
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FILL_PARENT, FlowLayout.SizeMode.WRAP_CONTENT)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 70))
            
            context:resize(1000, 800)
            
            assert(layout:getWidth() == 1000, "Layout width should fill new parent width (1000)")
            assert(layout:getHeight() == 90, "Layout height should wrap content (10 + 70 + 10)")
            assert(layout.children[1].x == 10, "First child should start at x=10 (left padding)")
        end,

        -- Test 6: Adding and removing children with WRAP_CONTENT
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 100, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FIXED, FlowLayout.SizeMode.WRAP_CONTENT)
            
            local child1 = MockElement(50, 50)
            local child2 = MockElement(50, 70)
            
            layout:addChild(child1)
            local height1 = layout:getHeight()
            assert(height1 == 70, string.format("Layout height should wrap one child (5 + 10 + 50 + 10 + 5), but got %d", height1))
            
            layout:addChild(child2)
            local height2 = layout:getHeight()
            assert(height2 == 140, string.format("Layout height should wrap both children (10 + 50 + 70 + 10), but got %d", height2))
            
            assert(child1.y == 10, string.format("First child should start at y=15 (top padding), but got %d", child1.y))
            assert(child2.y == 60, string.format("Second child should start at y=65 (top padding + first child height), but got %d", child2.y))
            
            layout:removeChild(child2)
            local height3 = layout:getHeight()
            assert(height3 == 70, string.format("Layout height should wrap only remaining child (10 + 50 + 10), but got %d", height3))
        end,
    -- Test 7: Horizontal layout with different alignments
    function()
        local context = GUIContext(0, 0, 800, 600)
        local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, 10, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
        context:addChild(layout)
        
        local child1 = MockElement(50, 30)
        local child2 = MockElement(50, 50)
        local child3 = MockElement(50, 40)
        layout:addChild(child1)
        layout:addChild(child2)
        layout:addChild(child3)
        
        -- Test START alignment
        layout:setAlignment(FlowLayout.Alignment.START)
        assert(child1.y == 10, "Child1 should be at the top with START alignment")
        assert(child2.y == 10, "Child2 should be at the top with START alignment")
        assert(child3.y == 10, "Child3 should be at the top with START alignment")
        
        -- Test CENTER alignment
        layout:setAlignment(FlowLayout.Alignment.CENTER)
        assert(child1.y == 35, "Child1 should be centered with CENTER alignment")
        assert(child2.y == 25, "Child2 should be centered with CENTER alignment")
        assert(child3.y == 30, "Child3 should be centered with CENTER alignment")
        
        -- Test END alignment
        layout:setAlignment(FlowLayout.Alignment.END)
        assert(child1.y == 60, "Child1 should be at the bottom with END alignment")
        assert(child2.y == 40, "Child2 should be at the bottom with END alignment")
        assert(child3.y == 50, "Child3 should be at the bottom with END alignment")
    end,

    -- Test 8: Vertical layout with different alignments
    function()
        local context = GUIContext(0, 0, 800, 600)
        local layout = FlowLayout(0, 0, 100, 300, {1,1,1}, 10, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
        context:addChild(layout)
        
        local child1 = MockElement(30, 50)
        local child2 = MockElement(50, 50)
        local child3 = MockElement(40, 50)
        layout:addChild(child1)
        layout:addChild(child2)
        layout:addChild(child3)
        
        -- Test START alignment
        layout:setAlignment(FlowLayout.Alignment.START)
        assert(child1.x == 10, "Child1 should be at the left with START alignment")
        assert(child2.x == 10, "Child2 should be at the left with START alignment")
        assert(child3.x == 10, "Child3 should be at the left with START alignment")
        
        -- Test CENTER alignment
        layout:setAlignment(FlowLayout.Alignment.CENTER)
        assert(child1.x == 35, "Child1 should be centered with CENTER alignment")
        assert(child2.x == 25, "Child2 should be centered with CENTER alignment")
        assert(child3.x == 30, "Child3 should be centered with CENTER alignment")
        
        -- Test END alignment
        layout:setAlignment(FlowLayout.Alignment.END)
        assert(child1.x == 60, "Child1 should be at the right with END alignment")
        assert(child2.x == 40, "Child2 should be at the right with END alignment")
        assert(child3.x == 50, "Child3 should be at the right with END alignment")
    end,

    -- Test 9: SPACE_BETWEEN alignment
    function()
        -- Test 9: SPACE_BETWEEN alignment
        local context = GUIContext(0, 0, 800, 600)
        local layout9 = FlowLayout(10, 10, 300, 100, {0.5, 0.5, 0.5}, nil, FlowLayout.Alignment.SPACE_BETWEEN)
        context:addChild(layout9)
        layout9:addChild(GUIElement(0, 0, 50, 50, {1, 0, 0}))
        layout9:addChild(GUIElement(0, 0, 50, 50, {0, 1, 0}))
        layout9:addChild(GUIElement(0, 0, 50, 50, {0, 0, 1}))
        --layout9:updateChildrenPositions()
        local child1 = layout9.children[1]
        local child2 = layout9.children[2]
        local child3 = layout9.children[3]
        assert(child1.x == 5, "Child1 should be at the start with SPACE_BETWEEN alignment")
        assert(child2.x == 125, "Child2 should be in the middle with SPACE_BETWEEN alignment")
        assert(child3.x == 245, "Child3 should be at the end with SPACE_BETWEEN alignment")
    end,

    -- Test 10: SPACE_AROUND alignment
    function()
        local context = GUIContext(0, 0, 800, 600)
        local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, 10, FlowLayout.Alignment.SPACE_AROUND, FlowLayout.Direction.HORIZONTAL)
        context:addChild(layout)
        
        local child1 = MockElement(50, 50)
        local child2 = MockElement(50, 50)
        local child3 = MockElement(50, 50)
        layout:addChild(child1)
        layout:addChild(child2)
        layout:addChild(child3)
        
        assert(child1.x == 42.5, "Child1 should have equal space around with SPACE_AROUND alignment")
        assert(child2.x == 125, "Child2 should have equal space around with SPACE_AROUND alignment")
        assert(child3.x == 207.5, "Child3 should have equal space around with SPACE_AROUND alignment")
    end,
    -- Test 11: Gap property in horizontal layout
function()
    local context = GUIContext(0, 0, 800, 600)
    local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, 10, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
    layout.gap = 20  -- Set gap to 20 pixels
    context:addChild(layout)
    
    local child1 = MockElement(50, 50)
    local child2 = MockElement(50, 50)
    local child3 = MockElement(50, 50)
    layout:addChild(child1)
    layout:addChild(child2)
    layout:addChild(child3)
    
    assert(child1.x == 10, "Child1 should start at x=10 (left padding)")
    assert(child2.x == 80, "Child2 should be at x=80 (10 + 50 + 20)")
    assert(child3.x == 150, "Child3 should be at x=150 (10 + 50 + 20 + 50 + 20)")
    assert(layout:getWidth() == 300, "Layout width should remain 300 (initial width)")
    assert(layout.measuredWidth == 210, "Layout measured width should be 210 (10 + 50 + 20 + 50 + 20 + 50 + 10)")
end,

-- Test 12: Gap property in vertical layout
function()
    local context = GUIContext(0, 0, 800, 600)
    local layout = FlowLayout(0, 0, 100, 300, {1,1,1}, 10, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
    layout.gap = 15  -- Set gap to 15 pixels
    context:addChild(layout)
    
    local child1 = MockElement(50, 40)
    local child2 = MockElement(50, 40)
    local child3 = MockElement(50, 40)
    layout:addChild(child1)
    layout:addChild(child2)
    layout:addChild(child3)
    
    assert(child1.y == 10, "Child1 should start at y=10 (top padding)")
    assert(child2.y == 65, "Child2 should be at y=65 (10 + 40 + 15)")
    assert(child3.y == 120, "Child3 should be at y=120 (10 + 40 + 15 + 40 + 15)")
    assert(layout:getHeight() == 300, "Layout width should remain 300 (initial width)")
    assert(layout.measuredHeight == 170, "Layout measured width should be 210 (10 + 50 + 20 + 50 + 20 + 50 + 10)")
end,
        
    }

    for i, test in ipairs(tests) do
        local success, error = pcall(test)
        if success then
            print("Test " .. i .. " passed")
        else
            print("Test " .. i .. " failed: " .. error)
        end
    end
end

-- Run the tests
return runTests