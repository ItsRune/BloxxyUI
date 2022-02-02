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
            for i,v in next, Prop.Components do
                local done = false
                if checked[i] == nil and v["Properties"] ~= nil and typeof(v["Properties"]["Components"]) == "table" and #v["Properties"]["Components"] > 0 then
                    checked[i] = true
                    
                    Prop.Components[i].Properties = Prop.Components[i].Properties or {}
                    Prop.Components[i].Properties.Parent = parent or ELEMENT._prop
                    Prop.Components[i].Callback = Prop.Components[i].Callback or nil
                    
                    if Prop.Components[i].Properties["Name"] ~= nil then
                        ELEMENT.Components[Prop.Components[i].Properties.Name] = self._elements[v.Name].Element.new(Prop.Components[i].Properties, Prop.Components[i].Callback, ELEMENT)
                    else
                        Prop.Components[i] = self._elements[v.Name].Element.new(Prop.Components[i].Properties, Prop.Components[i].Callback, ELEMENT)
                    end
                    
                    task.spawn(function()
                        runComponents(v.Properties, Prop.Components[i]._prop)
                    end)

                    done = true
                end

                if done == false and self._elements[v.Name] ~= nil then
                    Prop.Components[i].Properties = Prop.Components[i].Properties or {}
                    Prop.Components[i].Properties.Parent = parent or ELEMENT._prop
                    Prop.Components[i].Callback = Prop.Components[i].Callback or function() end
    
                    if Prop.Components[i].Properties["Name"] ~= nil then
                        ELEMENT.Components[Prop.Components[i].Properties.Name] = self._elements[v.Name].Element.new(Prop.Components[i].Properties, Prop.Components[i].Callback, ELEMENT)
                    else
                        Prop.Components[i] = self._elements[v.Name].Element.new(Prop.Components[i].Properties, Prop.Components[i].Callback, ELEMENT)
                    end
                end
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