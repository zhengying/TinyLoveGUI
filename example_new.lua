if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local TinyLoveGUI = require('TinyLoveGUI')
local Utils = require('TinyLoveGUI.Utils')

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
local TextEditor = TinyLoveGUI.TextEditor

local myProgressBar

local function createGUI(parent)
    local rowLayout = FlowLayout({
        x=0, y=0, width=nil, height=nil, 
        bgcolor={0.1,0.1,0.1}, 
        padding={left=25, right=5, top=15, bottom=5}, 
        alignment=FlowLayout.Alignment.START, 
        direction=FlowLayout.Direction.VERTICAL,
        crossAlignment=FlowLayout.CrossAlignment.START, 
        gap=8
    })
    
    parent:setLayout(rowLayout)

    local simpleButton = Button({
        x=0, y=0, width=200, height=50, 
        text = "Click me!",
        normalColor = {0.2, 0.6, 0.8, 1},
        hoverColor = {0.3, 0.7, 0.9, 1},
        pressedColor = {0.1, 0.5, 0.7, 1},
        tooltips_enabled = true,
        tooltips_text = "This is a tooltip!",
        onClick = function()
            PopupMessage.show(parent, "Hello, World!", 3)  -- Shows for 5 seconds
            myProgressBar.value = math.min(myProgressBar.value + 5,100)
        end
    })
        local simpleButton2 = Button({
        x=0, y=0, width=200, height=50, 
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

    local textField = TextField({
        x=0, y=0, width=80, height=30,
        maxLength = 16,
        inputType = "number"
    })


    local textField1 = TextField({
        x=0, y=0, width=80, height=30,
        maxLength = 10,
        customValidate = function(text)
            -- Example: Only allow even numbers
            local number = tonumber(text)
            return number ~= nil and number % 2 == 0
        end
    })


    textField.text = "1"
    parent:addChild(textField)
    parent:addChild(textField1)

    local groupIcon_fold = love.graphics.newImage("assets/images/folder.png")
    local groupIcon_open = love.graphics.newImage("assets/images/openfolder.png")
    local leafIcon = love.graphics.newImage("assets/images/document.png")


   
    TreeView:setDefaultGroupIcon(groupIcon_fold, groupIcon_open)
    TreeView:setDefaultLeafIcon(leafIcon)

    local treeView = TreeView({x=0, y=0, width=200, height=150})

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

    --Add a slider
    local slider = Slider({
        x=0, y=0, width=600, height=30, 
        min=0, max=100, 
        value=0,
        onChange = function(value)
            sliderValue = value
        end
    })
    
    parent:addChild(slider)


    myProgressBar = ProgressBar({
        x=0, y=0, width=200, height=50, 
        min=0, max=100, 
        value=0,
        onChange = function(value)
            sliderValue = value
        end
    })
    myProgressBar.tag = "myProgressBar"
    parent:addChild(myProgressBar)

    --rowLayout:addChild(treeView,1,1,'auto')

    local optionSelect = OptionSelect({
        x=0, y=0, width=100, height=30, 
        options={"Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6","Option 1", "Option 2", "Option 3", "Option 4", "Option 5", "Option 6"},
        tooltips_enabled = true,
        tooltips_text = "this is an OptionSelect, just test for long text, here we go",
        onChange = function(selectedOption, selectedIndex)
            print("Selected: " .. selectedOption .. " at index " .. selectedIndex)
        end
    })
    parent:addChild(optionSelect)

    parent:addChild(treeView)

    local menu = PopupMenu({
        {text = "Copy", action = function() print("Copy") end},
        {text = "Paste", action = function() print("Paste") end},
        {text = "More Options", submenu = {
            {text = "Option 1", action = function() print("Option 1") end},
            {text = "Option 2", action = function() print("Option 2") end},
        }},
    })
    -- In your main update/draw loop:

    local panel = ModalWindow({
        x=330, y=300, width=600, height=200, 
        context = parent.context, 
        backgroundColor = {0.2, 0.2, 0.2, 1},
        borderColor = {0.5, 0.5, 0.5, 1},
        borderWidth = 1,
        })
        panel:setNineSliceBackground(love.graphics.newImage("assets/images/panel1.png"), {left = 4, right = 4, top = 5, bottom = 5})

        -- context:addChild(panel)

   -- Create a popup menu using TreeView
   local contextMenu = PopupMenu({
        x=0, y=0, width=200, height=300, 
        context = parent.context, 
        backgroundColor = {0.2, 0.2, 0.2, 1},
        borderColor = {0.5, 0.5, 0.5, 1},
        borderWidth = 1,
        })
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
   parent:addChild(contextMenu)


   --right-click handler to mainView
   parent.context:setOnRightClick(function(self, x, y)
       contextMenu.x = x
       contextMenu.y = y
       contextMenu:show(x, y)
   end)


   parent:addChild(simpleButton)
   parent:addChild(simpleButton2)


   local textEditor = TextEditor({x=0, y=0, width=200, height=100, text = "Select a file to edit"})
   


    --Add components to layouts
    parent:addChild(textEditor,{flexGrow = 1, flexShrink = 1, flexBasis = "100"})

    parent:updateLayout()


   return parent

end


return createGUI
