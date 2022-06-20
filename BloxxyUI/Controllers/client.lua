--// Services \\--
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

--// Modules \\--
local Promise = require(script.Parent.Parent.Modules.Promise)
local table = require(script.Parent.Parent.Modules.Table)

--// Variables \\--
local Controller = {}
Controller.__index = Controller

--// Functions \\--
local function formatError(txt, state)
    state = state or 3
    local start = "[BloxxyUI]"
    local header = "Unknown:"

    if state == 0 then
        header = "Log:"
    elseif state == 1 then
        header = "Debug Log:"
    --/ Warning headers \--
    elseif state == 2 then
        header = "Warning:"
    elseif state == 2.1 then
        header = "Deprecation Warning:"
    elseif state == 2.2 then
        header = "Beta Warning:"
    elseif state == 3 then
        header = "Error:"
    else
        header = "Unknown:"
    end
    
    return string.format("%s %s %s", start, header, tostring(txt))
end

local function getElements()
    return Promise.new(function(resolve, reject)
        local out = {}
        for i,v in next, script.Parent.Parent:WaitForChild("Modules"):GetDescendants() do
            if v:IsA("ModuleScript") and v.Parent.Name == "elements" then
                local mod = require(v);
                
                if mod["Element"] ~= nil and mod["Deprecated"] ~= nil and mod["inBeta"] ~= nil then
                    out[v.Name] = mod;
                end
            end
        end
        
        if table.len(out) > 0 then
            resolve(out)
        else
            reject(out)
        end
    end)
end

--// Class Functions \\--
function Controller.new(Gui)
    local self = setmetatable({}, Controller)
    
    self.__index = self;
    self._initialized = false;
    self._gui = Gui;
    
    getElements():andThen(function(data)
        self._elements = data
        self._initialized = true;
    end):catch(function()
        error(debug.traceback(formatError("Failed To Initialize!", 3), 2))
    end)

    return self
end

function Controller:AddElement(Name, Properties, Callback)
    if self._elements == nil then
        local attempts = 0
        repeat
            attempts += 1
            task.wait(1)
        until self._elements ~= nil or attempts > 5

        if attempts > 5 then
            error(debug.traceback(formatError("Failed to load all elements!", 3), 2))
        end
    end
    Properties = Properties or {}

    if self._gui ~= nil and Properties["Parent"] == nil then
        Properties["Parent"] = self._gui
    end

    local element = self._elements[Name] or nil
    assert(element ~= nil, debug.traceback(formatError("Invalid element name.", 3), 2))
    
    if element.Deprecated[1] == true then
        warn(formatError("The following element '" .. Name .. "' is deprecated, please use '" .. element.Deprecated[2] .. "'!", 2.1))
    elseif element.inBeta == true then
        warn(formatError("The following element '" .. Name .. "' is currently a WIP element!", 2.2))
    end

    if typeof(Properties["Callback"]) == "function" then
        Callback = Properties.Callback
    end

    local ELEMENT = element.Element.new(Properties, Callback)
    local runComponents
    ELEMENT.Components = {}
    
    function runComponents(Prop, parent)
        if typeof(Prop.Components) == "table" then
            local checked = {}
            local prevComponent
            for i,component in next, Prop.Components do
                local done = false
                local this = Prop.Components[i]

                if prevComponent ~= nil then
                    this.Properties.Parent = prevComponent._prop
                else
                    this.Properties.Parent = parent or ELEMENT._prop
                end

                if checked[i] == nil and component["Properties"] ~= nil and typeof(component["Properties"]["Components"]) == "table" and #component["Properties"]["Components"] > 0 then
                    checked[i] = true
                    
                    this.Properties = this.Properties or {}
                    this.Properties.Parent = parent or ELEMENT._prop
                    this.Callback = this.Callback or nil
                    
                    if this.Properties["Name"] ~= nil then
                        ELEMENT.Components[this.Properties.Name] = self._elements[component.Name].Element.new(this.Properties, this.Callback, ELEMENT)
                        this = ELEMENT.Components[this.Properties.Name]
                    else
                        this = self._elements[component.Name].Element.new(this.Properties, this.Callback, ELEMENT)
                    end
                    
                    prevComponent = this
                    task.spawn(function()
                        runComponents(component.Properties, this._prop)
                    end)

                    done = true
                end

                if done == false and self._elements[component.Name] ~= nil then
                    this.Properties = this.Properties or {}
                    this.Properties.Parent = parent or ELEMENT._prop
                    this.Callback = this.Callback or function() end
    
                    if this.Properties["Name"] ~= nil then
                        ELEMENT.Components[this.Properties.Name] = self._elements[component.Name].Element.new(this.Properties, this.Callback, ELEMENT)
                        this = ELEMENT.Components[this.Properties.Name]
                    else
                        this = self._elements[component.Name].Element.new(this.Properties, this.Callback, ELEMENT)
                    end
                end

                prevComponent = this
            end
        end
    end

    runComponents(Properties)
    return ELEMENT._prop, ELEMENT
end

function Controller:GetComponents(ELEMENT)
    return ELEMENT._properties.Components
end

function Controller:RemoveElement(ElementTable)
    assert(typeof(ElementTable) == "table", "Expected a metatable, got '" .. typeof(ElementTable) .. "'!")
    assert(ElementTable._prop ~= nil, "Invalid element was passed!")

    return ElementTable:Destroy()
end

--// Main \\--
return Controller