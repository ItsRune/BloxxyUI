local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Maid = require(script.Parent.Parent.Maid)
local getColor = require(script.Parent.Parent.Colors).Func
local Instances = script.Parent.Parent.Parent.Instances
local createdSettings

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
    self._type = "Transparency and color"
    self._max = 100
    self._radialtrans = 0
    self._backgroundtrans = .25
    self._flipped = false
    self._lastValue = 0
    self._lastMoved = 0
    self._delayTime = .5
    self._tweening = false

    for i,v in next, createdSettings do
        if self._properties[i] ~= nil then continue end
        self._properties[i] = v
    end

    self:Initialize("Progress", self._callback)
    return self
end

function Element:Initialize(Type, Callback)
    if self._properties.Color ~= nil then
        self._properties.Color = getColor(self._properties.Color)
    end

    self._prop = Instances[Type]:Clone()
    self:UpdateProperties()
    self._prop.Visible = true
    
    local Left, Right = self._prop.Left, self._prop.Right
    local leftColorSeq, rightColorSeq;
    local leftTransSeq, rightTransSeq;

    if string.find(string.lower(tostring(self._type)), "and") ~= nil then
        leftTransSeq = NumberSequence.new({NumberSequenceKeypoint.new(0, self._radialtrans),NumberSequenceKeypoint.new(0.5, self._radialtrans),NumberSequenceKeypoint.new(0.501, self._backgroundtrans),NumberSequenceKeypoint.new(1, self._backgroundtrans)})
        leftColorSeq = ColorSequence.new({ColorSequenceKeypoint.new(0, self._percentpartcolor),ColorSequenceKeypoint.new(0.5, self._percentpartcolor),ColorSequenceKeypoint.new(0.501, self._missingpartcolor),ColorSequenceKeypoint.new(1, self._missingpartcolor)})
        
        rightTransSeq = NumberSequence.new({NumberSequenceKeypoint.new(0, self._radialtrans),NumberSequenceKeypoint.new(0.5, self._radialtrans),NumberSequenceKeypoint.new(0.501, self._backgroundtrans),NumberSequenceKeypoint.new(1, self._backgroundtrans)})
        rightColorSeq = ColorSequence.new({ColorSequenceKeypoint.new(0, self._percentpartcolor),ColorSequenceKeypoint.new(0.5, self._percentpartcolor),ColorSequenceKeypoint.new(0.501, self._missingpartcolor),ColorSequenceKeypoint.new(1, self._missingpartcolor)})
    elseif string.lower(tostring(self._type)) == "color" then
        leftColorSeq = ColorSequence.new({ColorSequenceKeypoint.new(0, self._percentpartcolor),ColorSequenceKeypoint.new(0.5, self._percentpartcolor),ColorSequenceKeypoint.new(0.501, self._missingpartcolor),ColorSequenceKeypoint.new(1, self._missingpartcolor)})
        leftTransSeq = NumberSequence.new(0)
        
        rightColorSeq = ColorSequence.new({ColorSequenceKeypoint.new(0, self._percentpartcolor),ColorSequenceKeypoint.new(0.5, self._percentpartcolor),ColorSequenceKeypoint.new(0.501, self._missingpartcolor),ColorSequenceKeypoint.new(1, self._missingpartcolor)})
        rightTransSeq = NumberSequence.new(0)
    elseif string.find(string.lower(tostring(self._type)), "trans") ~= nil then
        leftTransSeq = NumberSequence.new({NumberSequenceKeypoint.new(0, self._radialtrans),NumberSequenceKeypoint.new(0.5, self._radialtrans),NumberSequenceKeypoint.new(0.501, self._backgroundtrans),NumberSequenceKeypoint.new(1, self._backgroundtrans)})
        leftColorSeq = ColorSequence.new(Color3.new(1,1,1))
        
        rightTransSeq = NumberSequence.new({NumberSequenceKeypoint.new(0, self._radialtrans),NumberSequenceKeypoint.new(0.5, self._radialtrans),NumberSequenceKeypoint.new(0.501, self._backgroundtrans),NumberSequenceKeypoint.new(1, self._backgroundtrans)})
        rightColorSeq = ColorSequence.new(Color3.new(1,1,1))
    end

    Left.Radial.UIGradient.Transparency = leftTransSeq
    Left.Radial.UIGradient.Color = leftColorSeq
    Right.Radial.UIGradient.Transparency = rightTransSeq
    Right.Radial.UIGradient.Color = rightColorSeq

    Left.Radial.Image = "rbxassetid://3587367081"
    Right.Radial.Image = "rbxassetid://3587367081"
    
    self._maid["Bindable"] = self._bindable.Event:Connect(function(Command, ...)
        local Data = {...}
        if Command == "PropertyChange" then
            local Prop, Value = Data[1], Data[2]
            
            assert(self._properties[Prop] ~= nil, debug.traceback("Couldn't change a nil property type!", 2))
            assert(typeof(self._properties[Prop]) == typeof(Value), debug.traceback("Invalid property change, expected a '" .. typeof(self._properties[Prop]) .. "' got '" .. typeof(Value) .. "'!"))
            
            self._properties[Prop] = Value;
        elseif Command == "ChangeState" then
            local State = Data[1]
            
            self._state = State;
        end
    end)

    self._maid:GiveTask(RunService.RenderStepped:Connect(function()
        if self._tweening == false and os.time() - self._lastMoved >= self._delayTime and self._properties.Value ~= self._lastValue then
            self._bindable:Fire("ChangeState", 2)
            if self._tweenConnection ~= nil then
                self._tweenConnection:Wait()
                task.wait(.5)
            end
            local percentNumber = math.clamp(self._properties.Value * 3.6, 0, 360)
            
            local leftRotation = self._flipped == false and math.clamp(percentNumber, 180, 360) or 180 - math.clamp(percentNumber, 0, 180)
            local rightRotation = self._flipped == false and math.clamp(percentNumber, 0, 180) or 180 - math.clamp(percentNumber, 180, 360)
            
            local leftFrameTween = TweenService:Create(self._prop.Left.Radial.UIGradient, TweenInfo.new(1), {
                Rotation = leftRotation
            })
            local rightFrameTween = TweenService:Create(self._prop.Right.Radial.UIGradient, TweenInfo.new(1), {
                Rotation = rightRotation
            })

            local right, left;
            self._tweening = true
            right = rightFrameTween.Completed:Connect(function()
                leftFrameTween:Play()

                left = leftFrameTween.Completed:Connect(function()
                    task.wait()
                    self._tweening = false
                    left:Disconnect()
                end)
                right:Disconnect()
            end)
            rightFrameTween:Play()
        end
    end))
    
    Callback(self)
end

function Element:ChangeProperty(Property, Value)
    self._bindable:Fire("PropertyChange", Property, Value)
end

createdSettings = {
    ["Value"] = 0;
    ["MaxValue"] = 100;
    ["Type"] = "Transparency and color";
}

function Element:UpdateProperties()
    for i,v in next, self._properties do
        if i == "Color" then
            local color = (typeof(v) == "table") and v or getColor(v)
            
            self._prop.Left.Radial.ImageColor3 = color.TextColor
            self._prop.Right.Radial.ImageColor3 = color.TextColor

            self._prop.Left.Radial.ImageTransparency = self._radialtrans
            self._prop.Right.Radial.ImageTransparency = self._radialtrans

            self._missingpartcolor = color.Bkgd
            self._percentpartcolor = color.TextColor
            
            self._properties.Color = color;
        elseif i == "Parent" then
            self._prop.Parent = v
        elseif i == "Type" then
            self._properties.Type = v
        elseif i == "Value" then
            self._properties.Value = v
        elseif i == "MaxValue" then
            self._max = v
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
    self._maid:Destroy()
end

return {
    Element = Element;
    Deprecated = {false, nil};
    inBeta = false;
}