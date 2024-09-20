local TinyLoveGUI = require('TinyLoveGUI')

local GUIElement = TinyLoveGUI.GUIElement
local Button = TinyLoveGUI.Button
local ProgressBar = TinyLoveGUI.ProgressBar
local FlowLayout = TinyLoveGUI.FlowLayout
local GUIContext = TinyLoveGUI.GUIContext
local TextField = TinyLoveGUI.TextField
local PopupMenu = TinyLoveGUI.PopupMenu
local MenuItem = PopupMenu.MenuItem
local ModalWindow = TinyLoveGUI.ModalWindow
local Label = TinyLoveGUI.Label
local ScrollView = TinyLoveGUI.ScrollView
local Utils = TinyLoveGUI.Utils

local function createInventoryUI(parent)
    local context = parent.context

    local inventoryLayout = FlowLayout({
        bgcolor = {0.4, 0.4, 0.4},
        padding = {left = 20, right = 20, top = 20, bottom = 20},
        alignment = FlowLayout.Alignment.START,
        direction = FlowLayout.Direction.VERTICAL,
        crossAlignment = FlowLayout.CrossAlignment.STRETCH,
        gap = 2
    })

    local inventoryWindow = ModalWindow({
        width = 400,
        height = 300,
        layout = inventoryLayout,
        bgcolor = {0.6, 0.6, 0.6},
        borderColor = {1, 1, 1},
        borderWidth = 2,
        tag = "InventoryWindow",
        context = context
    })

    local title = Label({
        width = 200,
        height = 40,
        text = "Player Name",
        textColor = {0, 0, 0},
        alignment = Label.Alignment.CENTER,
        context = context
    })

    inventoryWindow:addChild(title, {flexGrow = 0, flexShrink = 0})

    -- Create a scroll view
    local scrollView = ScrollView({
        width = inventoryWindow.width - 40,
        height = inventoryWindow.height - 100,
        bgcolor = {0.8, 0.8, 0.8},
        context = context
    })

    -- scrollView = Utils.observable(scrollView, "parent", function(key, oldValue, newValue)
    --     print("scrollView parent changed to:", newValue.tag)
    -- end)

    -- scrollView.parent = inventoryWindow

    -- Create a layout for the scroll view content
    local scrollLayout = FlowLayout({
        bgcolor = {0, 0, 0},
        padding = {left = 2, right =2, top = 2, bottom = 2},
        alignment = FlowLayout.Alignment.CENTER,
        direction = FlowLayout.Direction.VERTICAL,
        crossAlignment = FlowLayout.CrossAlignment.STRETCH,
        gap = 2
    })

    scrollView:setLayout(scrollLayout)

    -- Add the scroll view to the inventory layout
    inventoryWindow:addChild(scrollView, {flexGrow = 0, flexShrink = 0})

    -- Inventory Items (Placeholder)
    for i = 1, 10 do
        local item = Label({
            width = 200,
            height = 20,
            text = "test label:" .. tostring(i),
            textColor = {0, 1, 1},
            alignment = Label.Alignment.CENTER,
            bgcolor = {0.5, 0.5, 0.5},
            borderColor = {1, 1, 1},
            borderWidth = 2,
            context = context
        })
        scrollView:addChild(item, {flexGrow = 0, flexShrink = 0})
    end

    -- Close Button
    local closeButton = Button({
        width = 100,
        height = 40,
        text = "Close",
        onClick = function()
            if parent.popModal then
                parent:popModal()
            end
        end,
        context = context
    })

    inventoryWindow:addChild(closeButton, {flexGrow = 0, flexShrink = 0})

    return inventoryWindow
end

local function createGameUI(parent)
    local context = parent.context
    local gui = parent

    -- Main Layout
    local mainLayout = FlowLayout({
        bgcolor = {0.1, 0.1, 0.1},
        padding = {left = 10, right = 10, top = 10, bottom = 10},
        alignment = FlowLayout.Alignment.START,
        direction = FlowLayout.Direction.VERTICAL,
        crossAlignment = FlowLayout.CrossAlignment.STRETCH,
        gap = 10
    })

    gui:setLayout(mainLayout)

    -- HUD Panel
    local hudLayout = FlowLayout({
        bgcolor = {0.2, 0.2, 0.2},
        padding = {left = 5, right = 5, top = 5, bottom = 5},
        alignment = FlowLayout.Alignment.START,
        direction = FlowLayout.Direction.HORIZONTAL,
        crossAlignment = FlowLayout.CrossAlignment.CENTER,
        gap = 10
    })

    local hudPanel = GUIElement({
        width = gui.width,
        height = 60,
        layout = hudLayout,
        bgcolor = {0.2, 0.2, 0.2},
        context = context
    })

    gui:addChild(hudPanel, {flexGrow = 0, flexShrink = 0})

    -- Health Bar
    local healthBar = ProgressBar({
        width = 200,
        height = 30,
        progress = 0.75,
        bgcolor = {1, 0, 0},
        backgroundColor = {0.5, 0, 0},
        borderColor = {1, 1, 1},
        borderWidth = 2,
        tag = "HealthBar",
        context = context
    })

    hudPanel:addChild(healthBar, {flexGrow = 0, flexShrink = 0})

    -- Inventory Button
    local inventoryButton = Button({
        width = 100,
        height = 40,
        text = "Inventory",
        onClick = function()
            local inventory = createInventoryUI(gui)
            -- gui:pushModal(inventory)
            inventory:doModal()
        end,
        context = context
    })

    hudPanel:addChild(inventoryButton, {flexGrow = 0, flexShrink = 0})

    -- Minimap
    local minimap = GUIElement({
        width = 50,
        height = 150,
        bgcolor = {0.3, 0.3, 0.3},
        borderColor = {1, 1, 1},
        borderWidth = 2,
        tag = "Minimap",
        context = context
    })

    gui:addChild(minimap, {flexGrow = 0, flexShrink = 0})

    -- Action Buttons Panel
    local actionButtonsLayout = FlowLayout({
        bgcolor = {0.2, 0.2, 0.2},
        padding = {left = 5, right = 5, top = 5, bottom = 5},
        alignment = FlowLayout.Alignment.CENTER,
        direction = FlowLayout.Direction.HORIZONTAL,
        crossAlignment = FlowLayout.CrossAlignment.CENTER,
        gap = 10
    })

    local actionButtonsPanel = GUIElement({
        width = gui.width,
        height = 60,
        layout = actionButtonsLayout,
        bgcolor = {0.2, 0.2, 0.2},
        context = context
    })

    gui:addChild(actionButtonsPanel, {flexGrow = 0, flexShrink = 0})

    -- Attack Button
    local attackButton = Button({
        width = 100,
        height = 40,
        text = "Attack",
        bgcolor = {0.8, 0.1, 0.1},
        onClick = function()
            print("Attack button clicked!")
            -- Add attack logic here
        end,
        context = context
    })

    actionButtonsPanel:addChild(attackButton, {flexGrow = 0, flexShrink = 0})

    -- Defend Button
    local defendButton = Button({
        width = 100,
        height = 40,
        text = "Defend",
        bgcolor = {0.1, 0.1, 0.8},
        onClick = function()
            print("Defend button clicked!")
            -- Add defend logic here
        end,
        context = context
    })

    actionButtonsPanel:addChild(defendButton, {flexGrow = 0, flexShrink = 0})

    -- Cast Spell Button
    local castSpellButton = Button({
        width = 120,
        height = 40,
        text = "Cast Spell",
        bgcolor = {0.1, 0.8, 0.1},
        onClick = function()
            print("Cast Spell button clicked!")
            -- Add spell casting logic here
        end,
        context = context
    })

    actionButtonsPanel:addChild(castSpellButton, {flexGrow = 0, flexShrink = 0})

    return context
end



return createGameUI