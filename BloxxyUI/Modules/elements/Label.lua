--// Modules \\--
local Maid = require(script.Parent.Parent.Maid)
local getColor = require(script.Parent.Parent.Colors).Func

--// Variables \\--
local Instances = script.Parent.Parent.Parent.Instances
local Element = {}
Element.__index = Element

local baseProps = {
    BackgroundTransparency = 1;
    TextColor3 = Color3.fromRGB(255, 255, 255);
}
--// Functions \\--
function Element.new(Properties, Callback, BaseFrame)
    local self = setmetatable({}, Element)

    self._maid = Maid.new()
    self._properties = Properties
    self._callback = Callback
    self._state = 1
    self._prop = nil

    self:Initialize()
    return self
end

function Element:Initialize()
    if self._properties.Color ~= nil then
        self._properties.Color = getColor(self._properties.Color)
    end
    self._prop = Instances.Label:Clone()

    self:UpdateProperties()
    self._prop.Visible = true

    task.spawn(self._callback, self)
end

function Element:UpdateProperties()
    for i,v in next, self._properties do
        if i == "Color" then
            local color = (typeof(v) == "table") and v or getColor(v)
            
            self._prop.Background.BackgroundColor3 = color.Bkgd

            if self._prop:FindFirstChildOfClass("TextLabel") ~= nil then
                self._prop:FindFirstChildOfClass("TextLabel").TextColor3 = color.TextColor
            end
            
            if color.Outlined == true then
                self._prop.Background.Outline.Enabled = true
            end

            self._properties.Color = color;
        elseif i == "Text" then
            self._prop.TextObj.Text = v
        elseif i == "TextColor3" then
            self._prop.TextObj.TextColor3 = v
        elseif i == "TextXAlignment" then
            self._prop.TextObj.TextXAlignment = v
        elseif i == "TextYAlignment" then
            self._prop.TextObj.TextYAlignment = v
        elseif i == "BackgroundTransparency" then
            self._prop.Background.BackgroundTransparency = v
        elseif i == "Parent" then
            self._prop.Parent = v
        else
            local frameSucc,_ = pcall(function()
                return self._prop[i]
            end)

            if frameSucc == true and typeof(self._prop[i]) == typeof(v) then
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

    Element._prop:Destroy()
    Element._maid:Destroy()
end

return {
    Element = Element;
    Deprecated = {false, nil};
    inBeta = false;
}