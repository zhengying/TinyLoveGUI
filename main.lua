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
            local layout = FlowLayout(0, 0, 300, 100, {1,1,1}, {left=5, right=5, top=5, bottom=5}, {left=0, right=0, top=0, bottom=0}, FlowLayout.Alignment.START, FlowLayout.Direction.HORIZONTAL)
            context:addChild(layout)
            
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            layout:addChild(MockElement(50, 50))
            layout:updateFrame()
            
            assert(layout:getWidth() == 300, "Layout width should be 300")
            assert(layout:getHeight() == 100, "Layout height should be 100")
            assert(layout.children[1].x == 5, "First child should start at x=5 (left padding)")
            assert(layout.children[2].x == 60, "Second child should start at x=60 (left padding + first child width)")
            assert(layout.children[3].x == 115, "Third child should start at x=110 (left padding + first two children widths)")
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
            layout:addChild(child2)
            --layout:updateFrame()  
            
            assert(layout:getHeight() == 160, "Layout height should wrap both children (5 + 10 + 50 + 10 + 70 + 10 + 5)")
            assert(child1.y == 15, "First child should start at y=15 (top margin + top padding)")
            assert(child2.y == 85, "Second child should start at y=85 (top margin + top padding + first child height + top padding)")
            
            layout:removeChild(child2)
            --layout:updateFrame()
            
            assert(layout:getHeight() == 80, "Layout height should wrap only remaining child (5 + 10 + 50 + 10 + 5)")
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

-- -- Create menu bar
-- local menuBar = FlowLayout(0, 0, w, 30)

-- mainLayout:addChild(menuBar)

-- menuBar.direction = FlowLayout.Direction.HORIZONTAL
-- local fileButton = Button(0, 0, 60, 30, "File")
-- local editButton = Button(0, 0, 60, 30, "Edit")
-- local viewButton = Button(0, 0, 60, 30, "View")
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