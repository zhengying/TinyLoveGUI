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
local context = GUIContext({width = w, height = h})

local layoutMain = FlowLayout({
    bgcolor = {1, 1, 1},
    padding = {left = 0, right = 0, top = 0, bottom = 0},
    alignment = FlowLayout.Alignment.START, 
    direction = FlowLayout.Direction.VERTICAL,
    crossAlignment = FlowLayout.CrossAlignment.STRETCH,
})

context:setLayout(layoutMain)
-- Create menu bar

local menuBarView = GUIElement({
    width = w,
    height = 40,
    layout = FlowLayout({
        bgcolor = {1, 1, 1},
        padding = {left = 5, right = 5, top = 5, bottom = 5},
        alignment = FlowLayout.Alignment.END,
        direction = FlowLayout.Direction.HORIZONTAL,
        crossAlignment = FlowLayout.CrossAlignment.CENTER,
        gap = 5
    }),
    context = context
})

context:addChild(menuBarView, {flexGrow = 0, flexShrink = 0, flexBasis = 40})

-- Create menu buttons
local fileButton = Button({width = 60, height = 30, text = "File"})
fileButton.tooltips_enabled = true
fileButton.tooltips_text = "File"

local editButton = Button({width = 60, height = 30, text = "Edit"})
editButton.tooltips_enabled = true
editButton.tooltips_text = "Edit"

local viewButton = Button({width = 60, height = 30, text = "View"})
viewButton.tooltips_enabled = true
viewButton.tooltips_text = "View"

menuBarView:addChild(fileButton)
menuBarView:addChild(editButton)
menuBarView:addChild(viewButton)

-- Create content layout
local contentView  = GUIElement({
    width = 10,
    height = 10,
    layout = FlowLayout({
        bgcolor = {1, 1, 1},
        padding = {left = 0, right = 0, top = 0, bottom = 0},
        alignment = FlowLayout.Alignment.START,
        direction = FlowLayout.Direction.HORIZONTAL,
        crossAlignment = FlowLayout.CrossAlignment.STRETCH
    }),
    context = context
})


contentView.DEBUG_DRAW = true
context:addChild(contentView, {flexGrow = 1, flexShrink = 1, flexBasis = "1024"})
-- Create file tree
local fileTree = TreeView({width = 200, height = nil})
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
local textEditor = TextEditor({})
textEditor:setText("Select a file to edit")

-- Add components to layouts
contentView:addChild(fileTree, {flexGrow = 0, flexShrink = 0, flexBasis = 200})
contentView:addChild(textEditor, {flexGrow = 1, flexShrink = 1, flexBasis = "auto"})

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
