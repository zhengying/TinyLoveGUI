if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end



local TinyLoveGUI = require('TinyLoveGUI')

local GUIElement = TinyLoveGUI.GUIElement
local TreeView = TinyLoveGUI.TreeView
local TreeNode = TreeView.TreeNode
local TextField = TinyLoveGUI.TextField
local Button = TinyLoveGUI.Button
local GUIContext = TinyLoveGUI.GUIContext
local FlowLayout = TinyLoveGUI.FlowLayout
local InputEventUtils = TinyLoveGUI.InputEventUtils

local w, h = love.window.getMode()
local context = GUIContext(0, 0, w, h)

love.window.setMode(1280, 720, {highdpi=true})

-- Create main layout
local mainLayout = FlowLayout(0, 0, w, h)
mainLayout.direction = FlowLayout.Direction.VERTICAL
context:addChild(mainLayout)

-- Create menu bar
local menuBar = FlowLayout(0, 0, w, 30)

mainLayout:addChild(menuBar)

menuBar.direction = FlowLayout.Direction.HORIZONTAL
local fileButton = Button(0, 0, 60, 30, "File")
local editButton = Button(0, 0, 60, 30, "Edit")
local viewButton = Button(0, 0, 60, 30, "View")
menuBar:addChild(fileButton)
menuBar:addChild(editButton)
menuBar:addChild(viewButton)

-- Create content layout
local contentLayout = FlowLayout(0, 0, w, h - 30)
contentLayout.direction = FlowLayout.Direction.HORIZONTAL

-- Create file tree
local fileTree = TreeView(0, 0, 200, h - 30)
local root = TreeNode("Project")
root:addChild(TreeNode("src"))
root:addChild(TreeNode("assets"))
root:addChild(TreeNode("README.md"))
fileTree:setRoot(root)

-- Create text editor
local textEditor = TextField(0, 0, w - 200, h - 30)
textEditor.multiline = true
textEditor:setText("Select a file to edit")

mainLayout:addChild(contentLayout)
-- Add components to layouts
contentLayout:addChild(fileTree)
contentLayout:addChild(textEditor)



-- Handle file selection
fileTree.onSelect = function(node)
    textEditor:setText("Content of " .. node.title)
end

function love.update(dt)
    context:update(dt)
end

function love.draw()
    context:draw()
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

function love.textinput(text)
    context:textInput(text)
end

function love.keypressed(key, scancode, isrepeat)
    context:keypressed(key, scancode, isrepeat)
end