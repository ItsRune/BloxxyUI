local Maid = require(script.Parent.Parent.Maid)
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

function Element:Destroy()
    self._maid:Destroy()
end

return {
    Element = Element;
    Deprecated = {false, nil};
    inBeta = true;
}