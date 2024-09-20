if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

local TinyLoveGUI = require('TinyLoveGUI')

local GUIElement = TinyLoveGUI.GUIElement
local Button = TinyLoveGUI.Button
local TextEditor = TinyLoveGUI.TextEditor
local FlowLayout = TinyLoveGUI.FlowLayout
local GUIContext = TinyLoveGUI.GUIContext

local currentExample = "new"
local gui, context
local mainNew, mainOld

local function loadExampleSource(moduleName)
    local success, result = pcall(require, moduleName)
    if success then
        return result
    else
        return "Error loading module: " .. moduleName .. "\n" .. tostring(result)
    end
end

local function createGUI()
    local w, h = love.window.getMode()
    context = GUIContext({width = w, height = h})


    local mainLayout = FlowLayout({
        bgcolor = {0, 0, 0},
        padding = {left = 10, right = 10, top = 10, bottom = 10},
        alignment = FlowLayout.Alignment.START,
        direction = FlowLayout.Direction.VERTICAL,
        crossAlignment = FlowLayout.CrossAlignment.STRETCH,
        gap = 2,
    })


    context.root:setLayout(mainLayout)

    local barLayout = FlowLayout({
        bgcolor = {1, 1, 1},
        padding = {left = 10, right = 10, top = 10, bottom = 10},
        alignment = FlowLayout.Alignment.START,
        direction = FlowLayout.Direction.HORIZONTAL,
        crossAlignment = FlowLayout.CrossAlignment.STRETCH,
        gap = 10,
    })

    local menuBar = GUIElement({
        width = 100, height = 40,
        bgcolor = {1, 1, 1},
        layout = barLayout,
        context = context
    })

    local playgoundView = GUIElement({
        width = 200, height = 40,
        bgcolor = {1, 1, 1},
        context = context
    })  

    playgoundView.cid = 'playgoundView'
    

    context.root:addChild(menuBar, {flexGrow = 0, flexShrink = 0})
    context.root:addChild(playgoundView, {flexGrow = 1, flexShrink = 1})

    local function loadExample()
        local exampleCreator
        if currentExample == "new" then
            exampleCreator = loadExampleSource("example_new")
            exampleCreator(playgoundView)
        elseif currentExample == "old" then
            exampleCreator = loadExampleSource("example_old")
            exampleCreator(playgoundView)
        elseif currentExample == "game_ui" then
            exampleCreator = loadExampleSource("example_game_ui")
            exampleCreator(playgoundView)
        else
            assert(false, "Invalid example: " .. currentExample)
        end
    end

    loadExample()

    local example1Button = Button({
        width = 200, height = 40,
        text = "Switch 1 Example",
        onClick = function()
            currentExample = "new"
            loadExample()
        end
    })

    local example2Button = Button({
        width = 200, height = 40,
        text = "Switch 2 Example",
        onClick = function()
            currentExample = 'old'
            loadExample()
        end
    })

    local example3Button = Button({
        width = 200, height = 40,
        text = "Switch 3 Example",
        onClick = function()
            currentExample = 'game_ui'
            loadExample()
        end
    })

    menuBar:addChild(example1Button, {flexGrow = 0, flexShrink = 0})
    menuBar:addChild(example2Button, {flexGrow = 0, flexShrink = 0})
    menuBar:addChild(example3Button, {flexGrow = 0, flexShrink = 0})

    -- local textEditor = TextEditor({})
    -- context:addChild(textEditor, {flexGrow = 0, flexShrink = 0})

    -- local function updateTextEditor()
    --     textEditor:setText(currentExample == "new" and mainNew or mainOld)
    -- end

    -- mainNew = loadExampleSource("example_new")
    -- mainOld = loadExampleSource("example_old")

    return context
end

function love.load()
    love.window.setMode(1280, 720, {resizable=true, vsync=0, minwidth=400, minheight=300})
    gui = createGUI()
end

function love.update(dt)
    gui:update(dt)
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

function love.resize(w, h)
    gui:resize(w, h)
end
