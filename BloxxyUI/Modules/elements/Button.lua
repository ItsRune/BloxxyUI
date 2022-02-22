--// Services \\--
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")

--// Modules \\--
local Maid = require(script.Parent.Parent.Maid)
local getColor = require(script.Parent.Parent.Colors).Func
local clickEffect = require(script.Parent.Parent.effects.clickEffect)

--// Variables \\--
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Instances = script.Parent.Parent.Parent.Instances

local Element = {}
Element.__index = Element
function Element.new(Properties, Callback, BaseFrame)
    local self = setmetatable({}, Element)

    self._properties = Properties or {}
    self._callback = Callback or Properties["Callback"] or function() end
    self._prop = nil --/ clone here
    self._maid = Maid.new()
    self._mouse = Mouse
    self._state = 1
    self._bindable = Instance.new("BindableEvent")

    self:Initialize()
    return self
end

function Element:Initialize()
    if self._properties.Color ~= nil then
        self._properties.Color = getColor(self._properties.Color)
    end
    self._prop = Instances.Button:Clone()
    self:UpdateProperties()

    self._maid:GiveTask(self._prop.Button.MouseButton1Click:Connect(function()
        clickEffect(self)
        self._callback(Player, {self._prop, self})
    end))

    self._maid["Bindable"] = self._bindable.Event:Connect(function(Command, ...)
        local Data = {...}
        if Command == "PropertyChange" then
            local Prop, Value = Data[1], Data[2]
            local success,good = pcall(function()
                return self._prop[Prop]
            end)

            if success == true then
                self._prop[Prop] = Value;
                self._properties[Prop] = Value;
            else
                if self._properties[Prop] ~= nil then
                    assert(typeof(self._properties[Prop]) == typeof(Value), debug.traceback("Property couldn't be changed due to an invalid value type, expected '" .. typeof(self._properties[Prop]) .. "' got '" .. typeof(Value) .. "'!", 2))
                    self._properties[Prop] = Value;
                    self:UpdateProperties()
                end
            end
        elseif Command == "ChangeState" then
            local State = Data[1]
            self._state = State;
        end
    end)

    self._prop.Visible = true
end

function Element:UpdateProperties()
    for i,v in next, self._properties do
        if i == "Color" then
            local color = (typeof(v) == "table") and v or getColor(v)
            
            self._prop.Background.BackgroundColor3 = color.Bkgd
            self._prop.Label.TextColor3 = color.TextColor
            
            if color.Outlined == true then
                self._prop.Background.Outline.Enabled = true
            end

            self._properties.Color = color;
        elseif i == "Text" then
            self._prop.Label.Text = v
        elseif i == "TextSize" then
            self._prop.Label.TextSize = v
        elseif i == "Parent" then
            self._prop.Parent = v
        else
            local success,_ = pcall(function()
                return self._prop[i]
            end)

            if success == true and typeof(self._prop[i]) == typeof(v) then
                self._prop[i] = v
            end
        end
    end
end

function Element:ChangeProperty(Property, Value)
    self._bindable:Fire("PropertyChange", Property, Value)
end

function Element:Destroy()
    if typeof(self._properties.Components) == "table" and #self._properties.Components > 0 then
        for i,v in next, self._properties.Components do
            v:Destroy()
        end
    end
    task.wait()
    
    self._maid:Destroy()
    self._prop:Destroy()
end

return {
    Element = Element;
    Deprecated = {false, nil};
    inBeta = false;
}