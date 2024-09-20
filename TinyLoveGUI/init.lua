--[[
    Copyright (c) 2024 ZhengYing

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--]]


TINYLOVEGUI_DEBUG = true

local cwd   = (...):gsub('%.init$', '') .. "."

local GUIElement = require(cwd .. "GUIElement")
local InputEventUtils = require(cwd .. "InputEventUtils")
local EventType = InputEventUtils.EventType
local InputEvent = InputEventUtils.InputEvent
local Button = require(cwd .. "Button")
local TextField = require(cwd .. "TextField")
local OptionSelect = require(cwd .. "OptionSelect")
local Slider = require(cwd .. "Slider")
local ProgressBar = require(cwd .. "ProgressBar")
local PopupMessage = require(cwd .. "PopupMessage")
local ScrollView = require(cwd .. "ScrollView")
local TreeView = require(cwd .. "TreeView")
local FlowLayout = require(cwd .. "FlowLayout")
local PopupMenu = require(cwd .. "PopupMenu")
local ModalWindow  = require(cwd .. "ModalWindow")
local GUIContext = require(cwd .. "GUIContext")
local PopupWindow = require(cwd .. "PopupWindow")
local TextEditor = require(cwd .. "TextEditor")
local Layout = require(cwd .. "Layout")
local Label = require(cwd .. "Label")
local Utils = require(cwd .. "Utils")


return {
    Button = Button,
    TextField = TextField,
    OptionSelect = OptionSelect,
    Slider = Slider,
    GUIElement = GUIElement,
    ProgressBar = ProgressBar,
    PopupMessage = PopupMessage,
    ScrollView = ScrollView,
    TreeView = TreeView,
    FlowLayout = FlowLayout,
    PopupMenu = PopupMenu,
    ModalWindow = ModalWindow,
    GUIContext = GUIContext,
    PopupWindow = PopupWindow,
    InputEventUtils = InputEventUtils,
    TextEditor = TextEditor,
    Layout = Layout,
    Label = Label,
    Utils = Utils,
}