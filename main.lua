if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- local FlowLayout = require("TinyLoveGUI.FlowLayout")
-- local GUIContext = require("TinyLoveGUI.GUIContext")
-- local GUIElement = require("TinyLoveGUI.GUIElement")
-- -- local runTests = require("test")

-- -- runTests()

local TinyLoveGUI = require('TinyLoveGUI')

local GUIElement = TinyLoveGUI.GUIElement
local TreeView = TinyLoveGUI.TreeView
local TreeNode = TreeView.TreeNode
local TextEditor = TinyLoveGUI.TextEditor
local Button = TinyLoveGUI.Button
local GUIContext = TinyLoveGUI.GUIContext
local FlowLayout = TinyLoveGUI.FlowLayout
local InputEventUtils = TinyLoveGUI.InputEventUtils



love.window.setMode(1280, 720, {highdpi = true, resizable = true})
local w, h = love.window.getMode()
local context = GUIContext(0, 0, w, h)

-- Create main layout
local mainLayout = FlowLayout(0, 0, w, h, {1,1,1}, {left=100, right=100, top=100, bottom=100}, 
                                FlowLayout.Alignment.START, 
                                FlowLayout.Direction.VERTICAL, 
                                {width=FlowLayout.SizeMode.FILL_PARENT, 
                                height=FlowLayout.SizeMode.FILL_PARENT})

mainLayout.crossAlignment = FlowLayout.CrossAlignment.STRETCH
mainLayout.DEBUG_DRAW = true
context:addChild(mainLayout)

-- (x, y, width, height, bgcolor, padding, margin, alignment, direction, sizeMode)

local menuBar = FlowLayout(0, 0, w, 40, {1,1,1}, {left=5, right=5, top=5, bottom=5}, 
                                                                FlowLayout.Alignment.END, 
                                                                FlowLayout.Direction.HORIZONTAL, 
                                                                {width=FlowLayout.SizeMode.STRETCH, 
                                                                height=FlowLayout.SizeMode.FIXED})
                                                                

menuBar.crossAlignment = FlowLayout.Alignment.CENTER
menuBar.gap = 5
menuBar.DEBUG_DRAW = true

mainLayout:addChild(menuBar,0,0,40)


--menuBar.direction = FlowLayout.Direction.HORIZONTAL
local fileButton = Button(0, 0, 60, 30, {text="File"})
fileButton.tooltips_enabled = true
fileButton.tooltips_text = "File"
local editButton = Button(0, 0, 60, 30, {text="Edit"})
editButton.tooltips_enabled = true
editButton.tooltips_text = "Edit"
local viewButton = Button(0, 0, 60, 30, {text="View"})
viewButton.tooltips_enabled = true
viewButton.tooltips_text = "View"
local helpButton = Button(0, 0, 60, 30, {text="Help"})
helpButton.tooltips_enabled = true
helpButton.tooltips_text = "Help"
menuBar:addChild(fileButton)
menuBar:addChild(editButton)
menuBar:addChild(viewButton)


-- local menuBar1 = FlowLayout(0, 0, w, 400, {1,1,1}, {left=5, right=5, top=5, bottom=5}, 
--                                                                 FlowLayout.Alignment.START, 
--                                                                 FlowLayout.Direction.VERTICAL, 
--                                                                 {width=FlowLayout.SizeMode.STRETCH, 
--                                                                 height=FlowLayout.SizeMode.FIXED})



-- menuBar1.crossAlignment = FlowLayout.CrossAlignment.STRETCH
-- menuBar1.gap = 15
-- menuBar1.DEBUG_DRAW = true

-- mainLayout:addChild(menuBar1,1,1,40)
-- local fileButton = Button(0, 0, 160, 190, {text="File"})
-- fileButton.tooltips_enabled = true
-- fileButton.tooltips_text = "File"
-- local editButton = Button(0, 0, 160, 30, {text="Edit"})
-- editButton.tooltips_enabled = true
-- editButton.tooltips_text = "Edit"
-- local viewButton = Button(0, 0, 160, 30, {text="View"})
-- viewButton.tooltips_enabled = true
-- viewButton.tooltips_text = "View"
-- local helpButton = Button(0, 0, 160, 30, {text="Help"})
-- helpButton.tooltips_enabled = true
-- helpButton.tooltips_text = "Help"

-- local maxButtonWidth = 200  -- or whatever maximum width you deem appropriate
-- menuBar1:addChild(fileButton)
-- menuBar1:addChild(editButton)
-- menuBar1:addChild(viewButton)


--Create content layout

local contentLayout = FlowLayout(0, 0, w, h, {1,1,1}, 
                                {left=0, right=0, top=0, bottom=0}, 
                                FlowLayout.Alignment.START,
                                FlowLayout.Direction.HORIZONTAL, 
                                {width=FlowLayout.SizeMode.FIXED, 
                                height=FlowLayout.SizeMode.FIXED})
contentLayout.crossAlignment = FlowLayout.CrossAlignment.STRETCH
mainLayout:addChild(contentLayout,0,0,200)
contentLayout.DEBUG_DRAW =  true
                                

-- Create file tree
local fileTree = TreeView(0, 0, 200, 200)
fileTree.DEBUG_DRAW =  true
                                
fileTree.style.nodeHeight = 20
local root = TreeNode("Project")
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
fileTree:setRoot(root)

-- Create text editor
local textEditor = TextEditor(0, 0, w-200, 100)
textEditor:setText("Select a file to edit")


--Add components to layouts
contentLayout:addChild(fileTree,0,0,100)
-- contentLayout:addChild(textEditor,1,1,'auto')

--Handle file selection
fileTree.onSelect = function(node)
    textEditor:setText("Content of " .. node.title)
end

function love.update(dt)
    context:update(dt)
end

function love.draw()
    context:draw()
end


function love.resize(w, h)
    local w , h = love.window.getMode()
    print(tostring(w), tostring(h))

    context:resize(w, h)    
end

function love.mousepressed(x, y, button, istouch, presses)
    context:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    context:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    context:mousemoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(x, y)
    context:wheelmoved(x, y)
end

function love.textinput(text)
    context:textinput(text)
end

function love.keypressed(key, scancode, isrepeat)
    context:keypressed(key, scancode, isrepeat)
end
