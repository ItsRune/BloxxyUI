local Maid = require(script.Parent.Parent.Maid)
local getColor = require(script.Parent.Parent.Colors).Func
local Instances = script.Parent.Parent.Parent.Instances

local Element = {}
Element.__index = Element
function Element.new(Properties, Callback, BaseFrame)
    local self = setmetatable({}, Element)

    self._properties = Properties or {}
    self._callback = Callback or function() end
    self._prop = nil --/ clone here
    self._maid = Maid.new()
    self._state = 1
    self._bindable = Instance.new("BindableEvent")

    self:Initialize()
    return self
end

function Element:Initialize(Type, Callback)
    if self._properties.Color ~= nil then
        self._properties.Color = getColor(self._properties.Color)
    end
    self._prop = Instances[Type]:Clone()
    self:UpdateProperties()

    self._maid["Bindable"] = self._bindable.Event:Connect(function(Command, ...)
        local Data = {...}
        if Command == "PropertyChange" then
            local Prop, Value = Data[1], Data[2]
            
            assert(self._prop[Prop] ~= nil, debug.traceback("Couldn't change a nil property type!", 2))
            assert(typeof(self._prop[Prop]) == typeof(Value), debug.traceback("Invalid property change, expected a '" .. typeof(self._prop[Prop]) .. "' got '" .. typeof(Value) .. "'!"))

            self._prop[Prop] = Value;
            self._properties[Prop] = Value;
            warn(self)
        elseif Command == "ChangeState" then
            local State = Data[1]
            
            self._state = State;
        end
    end)

    Callback(self)
    self._prop.Visible = true
end

function Element:ChangeProperty(Property, Value)
    self._bindable:Fire("PropertyChange", Property, Value)
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