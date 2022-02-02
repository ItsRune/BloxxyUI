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
    self._index = 0

    self:Initialize("Spinner", self._callback)
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
        elseif Command == "ChangeState" then
            local State = Data[1]
            
            self._state = State;
        end
    end)

    self._prop.Image = "rbxassetid://7996219298"

    local NumberOfFrames = self._properties.NumberOfFrames or 81
    local Rows, Columns = self._properties.Rows or 9, self._properties.Columns or 9
    local ImageHeight, ImageWidth = self._properties.Height or 1296, self._properties.Width or 1296
    local FPS = self._properties.FPS or 60
    
    local RobloxMaxImageSize = 1024
	local RealWidth, RealHeight

	if math.max(ImageWidth,ImageHeight) > RobloxMaxImageSize then
		local Longest = ImageWidth > ImageHeight and "Width" or "Height"

		if Longest == "Width" then
			RealWidth = RobloxMaxImageSize
			RealHeight = (RealWidth / ImageWidth) * ImageHeight
		elseif Longest == "Height" then
			RealHeight = RobloxMaxImageSize
			RealWidth = (RealHeight / ImageHeight) * ImageWidth
		end
	else
		RealWidth,RealHeight = ImageWidth,ImageHeight
	end

	local FrameSize = Vector2.new(RealWidth / Columns, RealHeight / Rows)
	self._prop.ImageRectSize = FrameSize

	local CurrentRow, CurrentColumn = 0,0
	local Offsets = {}

	for i = 1, NumberOfFrames do
		local CurrentX = CurrentColumn * FrameSize.X
		local CurrentY = CurrentRow * FrameSize.Y

		table.insert(Offsets,Vector2.new(CurrentX, CurrentY))
		CurrentColumn += 1

		if CurrentColumn >= Columns then
			CurrentColumn = 0
			CurrentRow += 1
		end
	end
	local TimeInterval = FPS and 1/FPS or 0.1
	
	task.spawn(function()
		while task.wait(TimeInterval) and self._prop:IsDescendantOf(game) do
			self._index += 1

			self._prop.ImageRectOffset = Offsets[self._index]
			if self._index >= NumberOfFrames then
				self._index = 0
			end
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
            
            self._prop.ImageColor3 = color.Bkgd
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