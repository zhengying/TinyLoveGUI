if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local TinyLoveGUI = require('TinyLoveGUI')

local GUIElement = TinyLoveGUI.GUIElement
local ScrollView = TinyLoveGUI.ScrollView
local Slider = TinyLoveGUI.Slider
local Button = TinyLoveGUI.Button
local OptionSelect = TinyLoveGUI.OptionSelect
local FlowLayout = TinyLoveGUI.FlowLayout
local TreeView = TinyLoveGUI.TreeView
local TreeNode = TreeView.TreeNode
local PopupMessage = TinyLoveGUI.PopupMessage
local ProgressBar = TinyLoveGUI.ProgressBar
local TextField = TinyLoveGUI.TextField
local PopupMenu = TinyLoveGUI.PopupMenu
local MenuItem = PopupMenu.MenuItem
local ModalWindow = TinyLoveGUI.ModalWindow
local GUIContext = TinyLoveGUI.GUIContext

local myProgressBar

local w, h =  love.window.getMode()
local context = GUIContext(0, 0, w, h)

local function createGUI()
    local simpleButton = Button(0, 0, 200, 50, {
        text = "Click me!",
        normalColor = {0.2, 0.6, 0.8, 1},
        hoverColor = {0.3, 0.7, 0.9, 1},
        pressedColor = {0.1, 0.5, 0.7, 1},
        tooltips_enabled = true,
        tooltips_text = "This is a tooltip!",
        onClick = function()
            PopupMessage.show(context, "Hello, World!", 3)  -- Shows for 5 seconds
            myProgressBar.value = math.min(myProgressBar.value + 5,100)
        end
    })
    local simpleButton2 = Button(0, 0, 200, 50, {
        text = "Cancel",
        normalColor = {0.2, 0.6, 0.8, 1},
        hoverColor = {0.3, 0.7, 0.9, 1},
        pressedColor = {0.1, 0.5, 0.7, 1},
        tooltips_enabled = true,
        tooltips_text = "This is second button!",
        onClick = function()
            print("Button clicked!")
            myProgressBar.value = 0
        end
    })
                                --x, y, width, height, bgcolor, padding, margin, alignment, direction
    local rowLayout = FlowLayout(0, 300, nil, nil, {r=0.1,g=0.1,b=0.1}, 5, nil,FlowLayout.Alignment.START, FlowLayout.Direction.VERTICAL)
    context:addChild(rowLayout)
    rowLayout:addChild(simpleButton)
    rowLayout:addChild(simpleButton2)

    local textField = TextField(0,0,80,30,{
        maxLength = 16,
        inputType = "number"
    })


    local textField1 = TextField(0,0,80,30,{
        maxLength = 10,
        customValidate = function(text)
            -- Example: Only allow even numbers
            local number = tonumber(text)
            return number ~= nil and number % 2 == 0
        end
    })


    textField.text = "1"
    rowLayout:addChild(textField)
    rowLayout:addChild(textField1)

    local groupIcon_fold = love.graphics.newImage("assets/images/folder.png")
    local groupIcon_open = love.graphics.newImage("assets/images/openfolder.png")
    local leafIcon = love.graphics.newImage("assets/images/document.png")


   
    TreeView:setDefaultGroupIcon(groupIcon_fold, groupIcon_open)
    TreeView:setDefaultLeafIcon(leafIcon)

    local treeView = TreeView(150, 50, 300, 150)
    
    -- Adding nodes to the tree
    local node1 = TreeNode("Node 1")
    local node2 = TreeNode("Node 2")
    local node3 = TreeNode("Node 3")
    local node4 = TreeNode("Node 3")
    local node5 = TreeNode("Node 3")


    local node6 = TreeNode("Node 3")
    local node7 = TreeNode("Node 3")
    local node8 = TreeNode("Node 3")
    local node9 = TreeNode("Node 3")
    local node10 = TreeNode("Node 3")
    local node11 = TreeNode("Node 3")
    local node12 = TreeNode("Node 3")
    local node13 = TreeNode("Node 3")
    local node14 = TreeNode("Node 3")
    local node15 = TreeNode("Node 3")
    local node16 = TreeNode("Node 3")
    local node17 = TreeNode("Node 3")
    
    treeView.root:addChild(node1)
    treeView.root:addChild(node2)
    treeView.root:addChild(node3)
    treeView.root:addChild(node4)
    treeView.root:addChild(node5)
    treeView.root:addChild(node6)


    node2:addChild(node7)
    node2:addChild(node8)
    node2:addChild(node9)
    node2:addChild(node10)

    node3:addChild(node11)
    node3:addChild(node12)
    node3:addChild(node13)
    node3:addChild(node14)
    node3:addChild(node15)
    node3:addChild(node16)
    node3:addChild(node17)

    context:addChild(treeView)

    --Add a slider
    local slider = Slider(0, 0, 600, 30, 0, 100, sliderValue)
    slider.tag = "slider"
    slider.onChange = function(value)
        sliderValue = value
    end
    
    context:addChild(slider)


    myProgressBar = ProgressBar(0, 0, 400, 50, 0, 100)
    myProgressBar.tag = "myProgressBar"
    context:addChild(myProgressBar)



    local optionSelect = OptionSelect(20, 150, 100, 30, {"Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6","Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6"})
    optionSelect.tag = "optionSelect"
    optionSelect.tooltips_enabled = true
    optionSelect.tooltips_text = "this is an OptionSelect"
    optionSelect.onChange = function(selectedOption, selectedIndex)
    print("Selected: " .. selectedOption .. " at index " .. selectedIndex)
    end
    context:addChild(optionSelect)
    -- local menu = PopupMenu({
    --     {text = "Copy", action = function() print("Copy") end},
    --     {text = "Paste", action = function() print("Paste") end},
    --     {text = "More Options", submenu = {
    --         {text = "Option 1", action = function() print("Option 1") end},
    --         {text = "Option 2", action = function() print("Option 2") end},
    --     }},
    -- })

    -- local menu = TreeView(150, 50, 300, 150)
    -- menu.displayMode = TreeView.DisplayMode.POPUP_MENU
    -- context:addChild(menu)

    -- -- Add a right-click handler to mainView
    -- mainView.onRightClick = function(self, x, y)
    --     menu:show(x, y)
    -- end 
    -- In your main update/draw loop:

    local panel = ModalWindow(330, 300, 600, 200, {
        backgroundColor = {0.2, 0.2, 0.2, 1},
        borderColor = {0.5, 0.5, 0.5, 1},
        borderWidth = 1,
        })
        panel:setNineSliceBackground(love.graphics.newImage("assets/images/panel1.png"), {left = 4, right = 4, top = 5, bottom = 5})

        context:addChild(panel)

   -- Create a popup menu using TreeView
   local contextMenu = PopupMenu(0, 0, 200, 300)
   contextMenu:hide()  -- Initially hidden

   -- Create menu items
   local fileMenu = MenuItem("File")
   local editMenu = MenuItem("Edit")
   local helpMenu = MenuItem("Help")

   -- Add sub-items to File menu
   fileMenu:addChild(MenuItem("New", function() print("New file") end))
   fileMenu:addChild(MenuItem("Open", function() 
    print("Open file") 
    panel:doModal()
   end))
   fileMenu:addChild(MenuItem("Save", function() print("Save file") end))

   local copyMenu = MenuItem("Copy", function() print("Copy") end)
   copyMenu:addChild(MenuItem("Copy Plain Text", function() print("Copy Plain Text") end))
   copyMenu:addChild(MenuItem("Copy HTML", function() print("Copy HTML") end))

    -- Add sub-items to Edit menu
   editMenu:addChild(copyMenu)
   editMenu:addChild(MenuItem("Cut", function() print("Cut") end))
   editMenu:addChild(MenuItem("Paste", function() print("Paste") end))

   -- Add sub-items to Help menu
   helpMenu:addChild(MenuItem("About", function() print("About") end))
   -- Add main menu items to the context menu
   contextMenu.root:addChild(fileMenu)
   contextMenu.root:addChild(editMenu)
   contextMenu.root:addChild(helpMenu)

   -- Add the context menu to mainView
   context:addChild(contextMenu)


   --right-click handler to mainView
   context:setOnRightClick(function(self, x, y)
       contextMenu.x = x
       contextMenu.y = y
       contextMenu:show(x, y)

    --    local element = context:elementAtPosition(x, y)
    --    local element_x, element_y = element:getGlobalPosition()

    --    local popup = TinyLoveGUI.PopupWindow.show(context, element_x, element_y, element.width, element.height, 100, 100, "This is a popup!")
       --popup:setTarget(element.x, element.y, element.width, element.height)
   end)




   return context

end

-- LÖVE callbacks
local gui

function love.load()
    love.window.setMode(1024, 768,{highdpi=true})
    gui = createGUI()
end

function love.update(dt)
    gui:update(dt)
    gui:updateMousePosition(love.mouse.getPosition())
end

function love.draw()
    gui:draw()
end

function love.mousemoved(x, y, dx, dy)
    gui:mousemoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
    gui:wheelmoved(x, y)
end

function love.mousepressed(x, y, button)
    gui:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    gui:mousereleased(x, y, button)
end

function love.keypressed(key)
    gui:keypressed(key)
end

function love.keyreleased(key)
    gui:keyreleased(key)
end

function love.textinput(text)
    gui:textinput(text)
end 
