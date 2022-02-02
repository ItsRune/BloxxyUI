--// Variables \\--
local Effect = {}
Effect.__index = Effect

local Types = {
    ["circleClick"] = 0;
    ["effect2"] = 1;
    ["effect3"] = 2;
    ["effect4"] = 3;
}

--// Functions \\--
function Effect.new(Type, Callback)
    local self = setmetatable({}, Effect)

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
    return setmetatable(Effect, nil)
end

return Effect