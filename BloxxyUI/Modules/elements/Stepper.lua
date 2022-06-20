local Maid = require(script.Parent.Parent.Maid)
local getColor = require(script.Parent.Parent.Colors).Func
local Element = {}
Element.__index = Element

function Element.new(Properties, Callback, BaseFrame)
    local self = setmetatable({}, Element)

    self._properties = Properties
    self._callback = Callback
    self._prop = nil --/ clone here
    self._maid = Maid.new()

    return self
end

function Element:Initialize()
    if self._properties.Color ~= nil then
        self._properties.Color = getColor(self._properties.Color)
    end
end

function Element:Destroy()
    self._maid:Destroy()
    self._prop:Destroy()
    return nil
end

return {
    Element = Element;
    Deprecated = {false, nil};
    inBeta = true;
}