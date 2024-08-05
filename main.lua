if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local GUI = require "tinylovegui"  -- Make sure this points to your tinylovegui.lua file
local icon_folder = love.graphics.newImage('assets/images/folder.png')
local icon_folder_opened = love.graphics.newImage('assets/images/open-folder.png')
local icon_file = love.graphics.newImage('assets/images/document.png')

local rootView
local clickCount = 0
local sliderValue = 50
local popup

function love.load()
    love.window.setMode(800, 600)
    
    rootView = GUI.GUIElement(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    rootView.scrollBarEnable = true
    rootView.tag = 'root'
    
    
    -- Create a column layout for the main content
    local mainLayout = GUI.ColumnLayout(100, 20, 760, 2560, 10)
    mainLayout.tag = "mainLayout"
    rootView:addChild(mainLayout)
    
    -- Create a row layout for buttons
    local buttonRow = GUI.RowLayout(0, 0, 760, 50)
    buttonRow.tag = "buttonRow"
    mainLayout:addChild(buttonRow)
    
    -- Add buttons to the row layout
    local button1 = GUI.Button(0, 0, 150, 40, "Click Me!") 
    button1.tag = "button1"
    button1.onClick = function()
        clickCount = clickCount + 1
        popup:show("Button 'Click Me!' clicked")
        myProgressBar.value = math.min(myProgressBar.value + 5,100)
    end
    buttonRow:addChild(button1)
    
    local button2 = GUI.Button(0, 0, 150, 40, "Reset")
    button2.tag = "button2"
    button2.onClick = function()
        clickCount = 0
        sliderValue = 50
        popup:show("Reset button clicked")
        myProgressBar.value = 0
    end
    buttonRow:addChild(button2)
    
    -- Add a slider
    local slider = GUI.Slider(0, 0, 600, 30, 0, 100, sliderValue)
    slider.tag = "slider"
    slider.onChange = function(value)
        sliderValue = value
    end
    mainLayout:addChild(slider)

    textArea = GUI.TextArea(0, 0, 200, 100, "Hello, world!", true)
    textArea.tag = "textArea"
    mainLayout:addChild(textArea)
    myProgressBar = GUI.ProgressBar(0, 0, 200, 50, 0, 100)
    myProgressBar.tag = "myProgressBar"
    mainLayout:addChild(myProgressBar)

    local optionSelect = GUI.OptionSelect(0, 0, 100, 30, {"Option 1", "Option 2", "Option 3"})
    optionSelect.tag = "optionSelect"
    optionSelect.onChange = function(selectedOption, selectedIndex)
    print("Selected: " .. selectedOption .. " at index " .. selectedIndex)
    end
    mainLayout:addChild(optionSelect)
    
    -- Create a grid-like layout using nested row and column layouts
    local gridLayout = GUI.ColumnLayout(0, 0, 760, 400)
    gridLayout.tag = "gridLayout"
    --mainLayout:addChild(gridLayout)
    
    for i = 1, 3 do
        local row = GUI.RowLayout(0, 0, 760, 88)
        row.tag = "GridRowLayout_" .. tostring(i)
        gridLayout:addChild(row)
        
        for j = 1, 3 do
            local cellNumber = (i-1)*3 + j
            local cell = GUI.Button(0, 0, 180, 80, "Cell " .. cellNumber)
            cell.tag = "gridButton_" .. tostring(cellNumber)
            cell.onClick = function()
                popup:show("Cell " .. cellNumber .. " clicked")
            end
            row:addChild(cell)
        end
    end

    -- Add popup
    popup = GUI.Popup(love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() - 100, 200, 50)
    popup.tag = 'popup'
    rootView:addChild(popup)

    local treeView = GUI.TreeView(10, 10, 200, 300)  -- x, y, width, height
    treeView:setGroupIcon(icon_folder_opened, icon_folder)
    treeView:setLeafIcon(icon_file)
    local root = treeView.root
    
    -- Node with a single icon for all states
    local node1 = treeView:addNode(root, "Node 1")
    
    -- Node with state-specific icons
    local node2 = treeView:addNode(root, "Node 2")
    
    local node1_1 = treeView:addNode(node1, "Node 1.1")
    local node2_1 = treeView:addNode(node2, "Node 2.1")
    local node2_2 = treeView:addNode(node2, "Node 2.2")

    -- Node with state-specific icons
    local node3 = treeView:addNode(root, "Node 3")
    
    local node1_1 = treeView:addNode(node3, "Node 3.1")
    local node2_1 = treeView:addNode(node3, "Node 3.1")
    local node2_2 = treeView:addNode(node3, "Node 3.2")
    
    -- Add a callback for node selection
    treeView.onNodeSelected = function(node)
        print("Selected node: " .. node.label)
    end
    
    -- Add the treeView to your main GUI container
    mainLayout:addChild(treeView)
end

function love.update(dt)
    rootView:update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(0.2, 0.4, 0.4)
    rootView:draw()
    print(tostring(rootView.scrollOffset.x), tostring(rootView.scrollOffset.y))
    
    -- Draw some text to show the current state
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Click Count: " .. clickCount, 20, 580)
    love.graphics.print("Slider Value: " .. string.format("%.2f", sliderValue), 200, 580)
end

function love.mousepressed(x, y, button)
    -- if GUI.handleOverlayMouseEvent('mousepressed', x, y, button) then
    --     return  -- Stop processing if an overlay item handled the event
    -- end
    -- Handle regular GUI mousepressed events
    rootView:mousepressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    -- if GUI.handleOverlayMouseEvent('mousemoved', x, y, dx, dy) then
    --     return  -- Stop processing if an overlay item handled the event
    -- end
    -- Handle regular GUI mousemoved events
    rootView:mousemoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button)
    -- if GUI.handleOverlayMouseEvent('mousereleased', x, y, button) then
    --     return  -- Stop processing if an overlay item handled the event
    -- end
    -- Handle regular GUI mousereleased events
    rootView:mousereleased(x, y, button)
end

function love.keypressed(key)
    textArea:keypressed(key)
end
  
function love.textinput(text)
    textArea:textinput(text)
end

function love.wheelmoved( x, y )
    rootView:wheelmoved(x, y)
end
