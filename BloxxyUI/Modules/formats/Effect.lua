--// Variables \\--
local Maid = require(script.Parent.Parent.Maid)
local Effect = {}
Effect.__index = Effect

local Types = {
    ["circleClick"] = 0;
    ["Loading"] = 1;
    ["effect3"] = 2;
    ["effect4"] = 3;
}

--// Functions \\--
function Effect.new(Type, Callback)
    local self = setmetatable({}, Effect)

    self._maid = Maid.new()
    self._type = Types[Type] or -1
    self._state = 0
    self._tweening = false

    Callback(self)
    return self
end

function Effect:ChangeState(new)
    assert(typeof(new) == "number", "State needs to be a number!")
    self._state = new
end

function Effect:Destroy()
    self._maid:Destroy()
    return nil
end

return Effect