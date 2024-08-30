if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local FlowLayout = require("TinyLoveGUI.FlowLayout")
local GUIContext = require("TinyLoveGUI.GUIContext")
local GUIElement = require("TinyLoveGUI.GUIElement")

-- local TinyLoveGUI = require('TinyLoveGUI')

-- local GUIElement = TinyLoveGUI.GUIElement
-- local TreeView = TinyLoveGUI.TreeView
-- local TreeNode = TreeView.TreeNode
-- local TextField = TinyLoveGUI.TextField
-- local Button = TinyLoveGUI.Button
-- local GUIContext = TinyLoveGUI.GUIContext
-- local FlowLayout = TinyLoveGUI.FlowLayout
-- local InputEventUtils = TinyLoveGUI.InputEventUtils

-- local w, h = love.window.getMode()
-- local context = GUIContext(0, 0, w, h)

-- love.window.setMode(1280, 720, {highdpi=true})

-- -- Create main layout
-- local mainLayout = FlowLayout(0, 0, w, h)
-- mainLayout.direction = FlowLayout.Direction.VERTICAL
-- context:addChild(mainLayout)


-- -- (x, y, width, height, bgcolor, padding, margin, alignment, direction, sizeMode)
-- -- Create menu bar
-- local menuBar = FlowLayout(0, 0, w, 40, nil, 0, 0, FlowLayout.Alignment.END, FlowLayout.Direction.HORIZONTAL, FlowLayout.SizeMode.FILL_PARENT)
-- menuBar.alignment = FlowLayout.Alignment.END
-- menuBar.gap = 5

-- mainLayout:addChild(menuBar)

-- menuBar.direction = FlowLayout.Direction.HORIZONTAL
-- local fileButton = Button(0, 0, 60, 30, {text="File"})
-- local editButton = Button(0, 0, 60, 30, {text="Edit"})
-- local viewButton = Button(0, 0, 60, 30, {text="View"})
-- menuBar:addChild(fileButton)
-- menuBar:addChild(editButton)
-- menuBar:addChild(viewButton)

-- -- Create content layout
-- local contentLayout = FlowLayout(0, 0, w, h - 30)
-- contentLayout.direction = FlowLayout.Direction.HORIZONTAL

-- -- Create file tree
-- local fileTree = TreeView(0, 0, 200, h - 30)
-- local root = TreeNode("Project")
-- root:addChild(TreeNode("src"))
-- root:addChild(TreeNode("assets"))
-- root:addChild(TreeNode("README.md"))
-- fileTree:setRoot(root)

-- -- Create text editor
-- local textEditor = TextField(0, 0, w - 200, h - 30)
-- textEditor.multiline = true
-- textEditor:setText("Select a file to edit")

-- mainLayout:addChild(contentLayout)
-- -- Add components to layouts
-- contentLayout:addChild(fileTree)
-- contentLayout:addChild(textEditor)



-- -- Handle file selection
-- fileTree.onSelect = function(node)
--     textEditor:setText("Content of " .. node.title)
-- end

-- function love.update(dt)
--     context:update(dt)
-- end

-- function love.draw()
--     context:draw()
-- end

-- function love.mousepressed(x, y, button, istouch, presses)
--     context:mousepressed(x, y, button, istouch, presses)
-- end

-- function love.mousereleased(x, y, button, istouch, presses)
--     context:mousereleased(x, y, button, istouch, presses)
-- end

-- function love.mousemoved(x, y, dx, dy, istouch)
--     context:mousemoved(x, y, dx, dy, istouch)
-- end

-- function love.textinput(text)
--     context:textInput(text)
-- end

-- function love.keypressed(key, scancode, isrepeat)
--     context:keypressed(key, scancode, isrepeat)
-- end



-- local FlowLayout = require("TinyLoveGUI.FlowLayout")
-- local GUIElement = require("TinyLoveGUI.GUIElement")
-- local GUIContext = require("TinyLoveGUI.GUIContext")

-- -- Helper function to create a mock element
-- local function createMockElement(width, height)
--     local element = GUIElement(0, 0, width, height)
--     element.getSize = function(self) return self.width, self.height end
--     return element
-- end

-- local function assertApproxEqual(actual, expected, tolerance)
--     tolerance = tolerance or 0.001
--     assert(math.abs(actual - expected) < tolerance, string.format("Expected %f, but got %f", expected, actual))
-- end

-- -- Create a layout with context
-- local function createLayoutWithContext(x, y, width, height, ...)
--     local context = GUIContext(0, 0, 800, 600)  -- Assume a default window size
--     local layout = FlowLayout(x, y, width, height, ...)
--     context:addChild(layout)
--     return layout, context
-- end

-- local tests = {
--     testHorizontalLayout = function()
--         local layout, context = createLayoutWithContext(0, 0, 300, 100)
--         layout:addChild(createMockElement(50, 50))
--         layout:addChild(createMockElement(100, 50))
--         layout:addChild(createMockElement(75, 50))
--         layout:updateFrame()

--         assert(layout:getWidth() == 300, "Layout width should be 300")
--         assert(layout:getHeight() == 100, "Layout height should be 100")
--         assertApproxEqual(layout.children[1].x, 5)  -- Default left padding
--         assertApproxEqual(layout.children[2].x, 55)  -- 5 (left padding) + 50 (first child width)
--         assertApproxEqual(layout.children[3].x, 155)  -- 5 (left padding) + 50 (first child width) + 100 (second child width)
--     end,

--     testVerticalLayout = function()
--         local layout, context = createLayoutWithContext(0, 0, 100, 300, nil, nil, nil, nil, FlowLayout.Direction.VERTICAL)
--         layout:addChild(createMockElement(50, 50))
--         layout:addChild(createMockElement(50, 100))
--         layout:addChild(createMockElement(50, 75))
--         layout:updateFrame()

--         assert(layout:getWidth() == 100, "Layout width should be 100")
--         assert(layout:getHeight() == 300, "Layout height should be 300")
--         assertApproxEqual(layout.children[1].y, 5)  -- Default top padding
--         assertApproxEqual(layout.children[2].y, 55)  -- 5 (top padding) + 50 (first child height)
--         assertApproxEqual(layout.children[3].y, 155)  -- 5 (top padding) + 50 (first child height) + 100 (second child height)
--     end,

--     testWrapContent = function()
--         local layout, context = createLayoutWithContext(0, 0, nil, nil, nil, nil, nil, nil, nil, {width = FlowLayout.SizeMode.WRAP_CONTENT, height = FlowLayout.SizeMode.WRAP_CONTENT})
--         layout:addChild(createMockElement(50, 50))
--         layout:addChild(createMockElement(100, 60))
--         layout:updateFrame()

--         print("Layout width:", layout:getWidth())
--         print("Layout height:", layout:getHeight())
--         print("Child 1 size:", layout.children[1]:getSize())
--         print("Child 2 size:", layout.children[2]:getSize())

--         assertApproxEqual(layout:getWidth(), 160)  -- 5 (left padding) + 50 + 100 + 5 (right padding)
--         assertApproxEqual(layout:getHeight(), 70)  -- 5 (top padding) + max(50, 60) + 5 (bottom padding)
--     end,

--     -- Add a new test for gap property
--     testGap = function()
--     local layout, context = createLayoutWithContext(0, 0, 300, 100)
--     layout.gap = 10  -- Set gap to 10
--     layout:addChild(createMockElement(50, 50))
--     layout:addChild(createMockElement(50, 50))
--     layout:addChild(createMockElement(50, 50))
--     layout:updateFrame()

--     assertApproxEqual(layout.children[2].x, 65)  -- 5 (left padding) + 50 (first child width) + 10 (gap)
--     assertApproxEqual(layout.children[3].x, 125)  -- 5 (left padding) + 50 (first child width) + 10 (gap) + 50 (second child width) + 10 (gap)
--     end,

--     testExpandingChildren = function()
--         local layout, context = createLayoutWithContext(0, 0, 300, 100)
--         layout:addChild(createMockElement(50, 50))
--         layout:addChild(createMockElement(0, 50), 1)  -- Expanding child
--         layout:addChild(createMockElement(50, 50))
--         layout:updateFrame()

--         assertApproxEqual(layout.children[2].width, 190)  -- 300 (layout width) - 5 (left padding) - 5 (right padding) - 50 (first child) - 50 (third child)
--     end,

--     testAlignment = function()
--         local alignments = {
--             FlowLayout.Alignment.START,
--             FlowLayout.Alignment.CENTER,
--             FlowLayout.Alignment.END,
--             FlowLayout.Alignment.SPACE_BETWEEN,
--             FlowLayout.Alignment.SPACE_AROUND
--         }

--         for _, direction in ipairs({FlowLayout.Direction.HORIZONTAL, FlowLayout.Direction.VERTICAL}) do
--             for _, alignment in ipairs(alignments) do
--                 local layout, context = createLayoutWithContext(0, 0, 300, 100, nil, nil, nil, alignment, direction)
--                 layout:addChild(createMockElement(50, 30))
--                 layout:addChild(createMockElement(50, 40))
--                 layout:addChild(createMockElement(50, 20))
--                 layout:updateFrame()

--                 local isVertical = direction == FlowLayout.Direction.VERTICAL
--                 local mainAxis = isVertical and "y" or "x"
--                 local crossAxis = isVertical and "x" or "y"
--                 local mainDim = isVertical and "height" or "width"
--                 local crossDim = isVertical and "width" or "height"

--                 if alignment == FlowLayout.Alignment.START then
--                     assertApproxEqual(layout.children[1][crossAxis], 5)  -- Default padding
--                     assertApproxEqual(layout.children[2][crossAxis], 5)
--                     assertApproxEqual(layout.children[3][crossAxis], 5)
--                 elseif alignment == FlowLayout.Alignment.CENTER then
--                     local centerPos = (layout[crossDim] - layout.children[1][crossDim]) / 2
--                     assertApproxEqual(layout.children[1][crossAxis], centerPos)
--                     assertApproxEqual(layout.children[2][crossAxis], (layout[crossDim] - layout.children[2][crossDim]) / 2)
--                     assertApproxEqual(layout.children[3][crossAxis], (layout[crossDim] - layout.children[3][crossDim]) / 2)
--                 elseif alignment == FlowLayout.Alignment.END then
--                     assertApproxEqual(layout.children[1][crossAxis], layout[crossDim] - layout.children[1][crossDim] - 5)  -- 5 is the default padding
--                     assertApproxEqual(layout.children[2][crossAxis], layout[crossDim] - layout.children[2][crossDim] - 5)
--                     assertApproxEqual(layout.children[3][crossAxis], layout[crossDim] - layout.children[3][crossDim] - 5)
--                 elseif alignment == FlowLayout.Alignment.SPACE_BETWEEN then
--                     assertApproxEqual(layout.children[1][crossAxis], 5)  -- Default padding
--                     assertApproxEqual(layout.children[3][crossAxis], layout[crossDim] - layout.children[3][crossDim] - 5)  -- 5 is the default padding
--                     local middlePos = (layout[crossDim] - layout.children[2][crossDim]) / 2
--                     assertApproxEqual(layout.children[2][crossAxis], middlePos)
--                 elseif alignment == FlowLayout.Alignment.SPACE_AROUND then
--                     local totalSpace = layout[crossDim] - (layout.children[1][crossDim] + layout.children[2][crossDim] + layout.children[3][crossDim]) - 10  -- 10 for left and right padding
--                     local spaceAround = totalSpace / 6  -- 3 children, 2 spaces between = 6 spaces
--                     assertApproxEqual(layout.children[1][crossAxis], 5 + spaceAround)  -- 5 for left padding
--                     assertApproxEqual(layout.children[2][crossAxis], 5 + 2 * spaceAround + layout.children[1][crossDim])
--                     assertApproxEqual(layout.children[3][crossAxis], 5 + 4 * spaceAround + layout.children[1][crossDim] + layout.children[2][crossDim])
--                 elseif alignment == FlowLayout.Alignment.SPACE_AROUND then
--                     local totalChildrenSize = 0
--                     for _, child in ipairs(layout.children) do
--                         totalChildrenSize = totalChildrenSize + child[mainDim]
--                     end
--                     local totalSpace = layout[mainDim] - totalChildrenSize
--                     local spaceAround = totalSpace / (#layout.children * 2)
--                     for i, child in ipairs(layout.children) do
--                         local expectedPos = spaceAround + (i - 1) * (child[mainDim] + 2 * spaceAround)
--                         assertApproxEqual(child[mainAxis], expectedPos)
--                     end
--                 end

--                 print(string.format("Alignment test passed for %s direction and %s alignment", direction, alignment))
--             end
--         end
--     end,

--     testMarginAndPadding = function()
--         local layout, context = createLayoutWithContext(0, 0, 300, 100, nil, 10, 20)
--         layout:addChild(createMockElement(50, 50))
--         layout:addChild(createMockElement(50, 50))
--         layout:updateFrame()

--         assertApproxEqual(layout.children[1].x, 30)  -- 20 (margin) + 10 (padding)
--         assertApproxEqual(layout.children[1].y, 30)  -- 20 (margin) + 10 (padding)
--         assertApproxEqual(layout.children[2].x, 80)  -- 30 (first child x) + 50 (first child width)
--     end,
-- }



-- -- Run tests in order
-- local testOrder = {
--     "testHorizontalLayout",
--     "testVerticalLayout",
--     "testWrapContent",
--     "testGap",
--     "testExpandingChildren",
--     "testAlignment",
--     "testMarginAndPadding"
-- }

-- for _, testName in ipairs(testOrder) do
--     print("Running test: " .. testName)
--     tests[testName]()
--     print("Test passed: " .. testName)
-- end

-- print("All tests passed!")



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
            local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, {left=5, right=5, top=5, bottom=5}, {left=0, right=0, top=0, bottom=0}, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
            context:addChild(layout)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            layout:updateFrame()
            
            assert(layout:getWidth() == 300, "Layout width should be 300")
            assert(layout:getHeight() == 100, "Layout height should be 100")
            assert(layout.children[1].x == 5, "First child should start at x=5 (left padding)")
            assert(layout.children[2].x == 55, "Second child should start at x=60 (left padding + first child width)")
            assert(layout.children[3].x == 105, "Third child should start at x=110 (left padding + first two children widths)")
        end,

        -- Test 2: Vertical layout with expanding children
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 100, 300, {1,1,1}, {left=10, right=10, top=10, bottom=10}, {left=0, right=0, top=0, bottom=0}, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
            context:addChild(layout)
            
            layout:addChild(MockElement(50, 50), 1)
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50), 2)
            --layout:updateFrame()
            
            assert(layout:getHeight() == 300, "Layout height should be 300")
            assert(layout.children[1].height > 50, "First child should expand")
            assert(layout.children[2].height == 50, "Second child should not expand")
            assert(layout.children[3].height > layout.children[1].height, "Third child should expand more than first")
            assert(layout.children[1].y == 10, "First child should start at y=10 (top padding)")
        end,

        -- Test 3: FILL_PARENT width mode
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, {left=5, right=5, top=0, bottom=0}, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FILL_PARENT, FlowLayout.SizeMode.FIXED)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            --layout:updateFrame()
            
            assert(layout:getWidth() == 790, "Layout width should fill parent (800 - 5 - 5)")
            assert(layout:getHeight() == 100, "Layout height should remain fixed")
            assert(layout.children[1].x == 15, "First child should start at x=15 (left margin + left padding)")
        end,

        -- Test 4: WRAP_CONTENT height mode
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 100, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, {left=0, right=0, top=5, bottom=5}, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FIXED, FlowLayout.SizeMode.WRAP_CONTENT)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 70))
            --layout:updateFrame()
            
            assert(layout:getWidth() == 100, "Layout width should remain fixed")
            assert(layout:getHeight() == 150, "Layout height should wrap content (5 + 10 + 50 + 10 + 70 + 10 + 5)")
            assert(layout.children[1].y == 15, "First child should start at y=15 (top margin + top padding)")
        end,

        -- Test 5: Resizing parent
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, {left=5, right=5, top=5, bottom=5}, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FILL_PARENT, FlowLayout.SizeMode.WRAP_CONTENT)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 70))
            --layout:updateFrame()
            
            context:resize(1000, 800)
            
            assert(layout:getWidth() == 990, "Layout width should fill new parent width (1000 - 5 - 5)")
            assert(layout:getHeight() == 100, "Layout height should wrap content (5 + 10 + 70 + 10 + 5)")
            assert(layout.children[1].x == 15, "First child should start at x=15 (left margin + left padding)")
        end,

        -- Test 6: Adding and removing children with WRAP_CONTENT
        function()
            local context = GUIContext(0, 0, 800, 600)
            local layout = FlowLayout(0, 0, 100, 100, {1,1,1}, {left=10, right=10, top=10, bottom=10}, {left=0, right=0, top=5, bottom=5}, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
            context:addChild(layout)
            layout:setSizeMode(FlowLayout.SizeMode.FIXED, FlowLayout.SizeMode.WRAP_CONTENT)
            
            local child1 = MockElement(50, 50)
            local child2 = MockElement(50, 70)
            
            layout:addChild(child1)
            --layout:updateFrame()
            local height1 = layout:getHeight()
            print("Height with one child:", height1)
            assert(height1 == 80, string.format("Layout height should wrap one child (5 + 10 + 50 + 10 + 5), but got %d", height1))
            
            layout:addChild(child2)
            --layout:updateFrame()
            local height2 = layout:getHeight()
            print("Height with two children:", height2)
            assert(height2 == 150, string.format("Layout height should wrap both children (5 + 10 + 50 + 70 + 10 + 5), but got %d", height2))
            
            assert(child1.y == 15, string.format("First child should start at y=15 (top margin + top padding), but got %d", child1.y))
            assert(child2.y == 65, string.format("Second child should start at y=65 (top margin + top padding + first child height), but got %d", child2.y))
            
            layout:removeChild(child2)
            --layout:updateFrame()
            local height3 = layout:getHeight()
            print("Height after removing second child:", height3)
            assert(height3 == 80, string.format("Layout height should wrap only remaining child (5 + 10 + 50 + 10 + 5), but got %d", height3))
        end,
    -- Test 7: Horizontal layout with different alignments
    function()
        local context = GUIContext(0, 0, 800, 600)
        local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, 10, 0, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
        context:addChild(layout)
        
        local child1 = MockElement(50, 30)
        local child2 = MockElement(50, 50)
        local child3 = MockElement(50, 40)
        layout:addChild(child1)
        layout:addChild(child2)
        layout:addChild(child3)
        
        -- Test START alignment
        layout:setAlignment(FlowLayout.Alignment.START)
        layout:updateFrame()
        assert(child1.y == 10, "Child1 should be at the top with START alignment")
        assert(child2.y == 10, "Child2 should be at the top with START alignment")
        assert(child3.y == 10, "Child3 should be at the top with START alignment")
        
        -- Test CENTER alignment
        layout:setAlignment(FlowLayout.Alignment.CENTER)
        layout:updateFrame()
        assert(child1.y == 35, "Child1 should be centered with CENTER alignment")
        assert(child2.y == 25, "Child2 should be centered with CENTER alignment")
        assert(child3.y == 30, "Child3 should be centered with CENTER alignment")
        
        -- Test END alignment
        layout:setAlignment(FlowLayout.Alignment.END)
        layout:updateFrame()
        assert(child1.y == 60, "Child1 should be at the bottom with END alignment")
        assert(child2.y == 40, "Child2 should be at the bottom with END alignment")
        assert(child3.y == 50, "Child3 should be at the bottom with END alignment")
    end,

    -- Test 8: Vertical layout with different alignments
    function()
        local context = GUIContext(0, 0, 800, 600)
        local layout = FlowLayout(0, 0, 100, 300, {1,1,1}, 10, 0, FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
        context:addChild(layout)
        
        local child1 = MockElement(30, 50)
        local child2 = MockElement(50, 50)
        local child3 = MockElement(40, 50)
        layout:addChild(child1)
        layout:addChild(child2)
        layout:addChild(child3)
        
        -- Test START alignment
        layout:setAlignment(FlowLayout.Alignment.START)
        layout:updateFrame()
        assert(child1.x == 10, "Child1 should be at the left with START alignment")
        assert(child2.x == 10, "Child2 should be at the left with START alignment")
        assert(child3.x == 10, "Child3 should be at the left with START alignment")
        
        -- Test CENTER alignment
        layout:setAlignment(FlowLayout.Alignment.CENTER)
        layout:updateFrame()
        assert(child1.x == 35, "Child1 should be centered with CENTER alignment")
        assert(child2.x == 25, "Child2 should be centered with CENTER alignment")
        assert(child3.x == 30, "Child3 should be centered with CENTER alignment")
        
        -- Test END alignment
        layout:setAlignment(FlowLayout.Alignment.END)
        layout:updateFrame()
        assert(child1.x == 60, "Child1 should be at the right with END alignment")
        assert(child2.x == 40, "Child2 should be at the right with END alignment")
        assert(child3.x == 50, "Child3 should be at the right with END alignment")
    end,

    -- Test 9: SPACE_BETWEEN alignment
    function()
        -- Test 9: SPACE_BETWEEN alignment
        local context = GUIContext(0, 0, 800, 600)
        local layout9 = FlowLayout(10, 10, 300, 100, {0.5, 0.5, 0.5}, nil, nil, FlowLayout.Alignment.SPACE_BETWEEN)
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
        print("Test 9 passed")
    end,

    -- Test 10: SPACE_AROUND alignment
    function()
        local context = GUIContext(0, 0, 800, 600)
        local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, 10, 0, FlowLayout.Alignment.SPACE_AROUND, FlowLayout.Direction.HORIZONTAL)
        context:addChild(layout)
        
        local child1 = MockElement(50, 50)
        local child2 = MockElement(50, 50)
        local child3 = MockElement(50, 50)
        layout:addChild(child1)
        layout:addChild(child2)
        layout:addChild(child3)
        
        layout:updateFrame()
        assert(child1.x == 35, "Child1 should have equal space around with SPACE_AROUND alignment")
        assert(child2.x == 125, "Child2 should have equal space around with SPACE_AROUND alignment")
        assert(child3.x == 215, "Child3 should have equal space around with SPACE_AROUND alignment")
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
runTests()