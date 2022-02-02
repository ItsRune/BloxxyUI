--// Modules \\--
local Maid = require(script.Parent.Parent.Maid)
local getColor = require(script.Parent.Parent.Colors).Func

--// Variables \\--
local Instances = script.Parent.Parent.Parent.Instances

local Element = {}
Element.__index = Element
function Element.new(Properties, Callback, BaseFrame)
    local self = setmetatable({}, Element)

    self._maid = Maid.new()
    self._properties = Properties
    self._callback = Callback
    self._state = 1
    self._prop = nil
    self._base = BaseFrame

    self:Initialize()
    return self
end

function Element:Initialize()
    if self._properties.Color ~= nil then
        self._properties.Color = getColor(self._properties.Color)
    end
    self._prop = Instances.BaseFrame:Clone()

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

    Element._prop:Destroy()
    Element._maid:Destroy()
end

return {
    Element = Element;
    Deprecated = {false, nil};
    inBeta = false;
}