local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local Maid = require(script.Parent.Parent.Maid)
local Colors = require(script.Parent.Parent.Colors)
-- local loadingEffect = require(script.Parent.Parent.Modules.elements.Loading)
local getColor = Colors.Func
local contrastColor = Colors.SecondaryFunc
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
    self._amountOfLines = 0

    for i,v in next, createdSettings do
        if self._properties[i] ~= nil then continue end
        self._properties[i] = v
    end

    self:Initialize("Input")
    return self
end

function Element:Initialize(Type)
    if self._properties.Color ~= nil then
        self._properties.Color = getColor(self._properties.Color)
    end
    self._prop = Instances[Type]:Clone()
    self:UpdateProperties()
    self._prop.Background.Input.TextColor3 = contrastColor(self._properties.Color.TextColor)
    self._prop.Background.Input.PlaceholderColor3 = contrastColor(self._properties.Color.TextColor)

    if (typeof(self._properties["ErrorCheck"]) == "boolean" and self._properties["ErrorCheck"] == true) or typeof(self._properties["CharacterCheck"]) == "table" then
        if self._properties.CharacterCheck[1] ~= nil then
            self._properties.minChars = self._properties["CharacterCheck"][1]
            self._properties.maxChars = self._properties["CharacterCheck"][2] or "inf"
        elseif self._properties.CharacterCheck["min"] ~= nil then
            self._properties.minChars = self._properties["CharacterCheck"].min
            self._properties.maxChars = self._properties["CharacterCheck"].max or "inf"
        elseif self._properties.CharacterCheck["max"] ~= nil then
            self._properties.minChars = self._properties["CharacterCheck"].min or 0
            self._properties.maxChars = self._properties["CharacterCheck"].max
        end
    else
        self._properties.minChars = 0
        self._properties.maxChars = "inf"
    end

    self._prop.Title.Text = (typeof(self._properties["Title"]) ~= "nil") and self._properties.Title .. " " or ""
    self._prop.Background.Size = UDim2.new(1, -4, 0, (self._prop.AbsoluteSize.Y * self._prop.Background.Size.Y.Scale) + self._prop.Background.Size.Y.Offset)
    local titleTxt = self._prop.Title.Text

    if self._properties.maxChars ~= 0 and self._properties.maxChars ~= "inf" and self._properties.minChars ~= 0 then
        titleTxt = titleTxt .. string.format("(%s - %s characters)", self._properties.minChars, self._properties.maxChars)
    elseif self._properties.maxChars ~= 0 and self._properties.maxChars ~= "inf" then
        titleTxt = titleTxt .. string.format("(maximum %s characters)", self._properties.maxChars)
    elseif self._properties.minChars ~= 0 then
        titleTxt = titleTxt .. string.format("(minimum %s characters)", self._properties.minChars)
    end
    self._prop.Title.Text = titleTxt

    local sizeOfTitle = TextService:GetTextSize(titleTxt, self._prop.Title.TextSize, self._prop.Title.Font, self._prop.AbsoluteSize)
    if (self._prop.AbsoluteSize.X > sizeOfTitle.X) then
       self._prop.Title.Size = UDim2.fromOffset(self._prop.AbsoluteSize.X, sizeOfTitle.Y)
    else
        self._prop.Title.Size = UDim2.fromOffset(sizeOfTitle.X, sizeOfTitle.Y)
    end
    self._prop.Title.Position = self._prop.Title.Position - UDim2.new(0, 0, 0, (self._prop.Title.Size.Y.Offset / 2) + ((self._properties.errorStroke ~= nil) and self._properties.errorStroke or 0))

    self._maid["Bindable"] = self._bindable.Event:Connect(function(Command, ...)
        local Data = {...}
        if Command == "PropertyChange" then
            local Prop, Value = Data[1], Data[2]
            
            assert(self._properties[Prop] ~= nil, debug.traceback("Couldn't change a nil property type!", 2))
            assert(typeof(self._properties[Prop]) == typeof(Value), debug.traceback("Invalid property change, expected a '" .. typeof(self._properties[Prop]) .. "' got '" .. typeof(Value) .. "'!"))

            self._properties[Prop] = Value;
            self:UpdateProperties()
        elseif Command == "ChangeState" then
            local State = Data[1]
            self._state = State;
        end
    end)

    local isMultiLined = false
    if self._properties["MultiLine"] == true then
        self._prop.Background.Input.MultiLine = true
        self._originalsize = self._prop.Size
        self._originalbackgroundsize = self._prop.Background.Size
        self._textboundsY = self._prop.Background.Input.TextSize

        self._prop.Background.AnchorPoint = Vector2.new(0, 1)
        self._prop.Background.Position = UDim2.new(0, 2, 1, -2)
        isMultiLined = true
    end

    local function checkChars()
        local len = string.len(self._prop.Background.Input.Text) - self._amountOfLines
        return (len >= self._properties.minChars and self._properties.maxChars == "inf") or (len >= self._properties.minChars and len <= self._properties.maxChars)
    end

    local function handleChangeOfLines()
        local bounds = self._prop.Background.Input.TextBounds
        local fontSize = self._prop.Background.Input.TextSize
        
        local amountOfLines = bounds.Y / self._textboundsY
        local toAddToSize = UDim2.new(0, 0, 0, fontSize * (amountOfLines - 1))

        self._prop.Size = self._originalsize + toAddToSize
        self._prop.Background.Size = self._originalbackgroundsize + toAddToSize
        
        self._amountOfLines = amountOfLines - 1
    end

    self._maid:GiveTask(self._prop.Background.Input.Focused:Connect(function()
        if self._properties["Disabled"] == true then
            self._prop.Background.Input:ReleaseFocus()
            return
        end

        self._bindable:Fire("ChangeState", 2)
        self._properties["Focused"] = true

        self._prop.Background.Input.TextColor3 = self._properties.Color.TextColor
        self._prop.Background.Input.PlaceholderColor3 = self._properties.Color.TextColor

        if isMultiLined == true then
            self._maid["TextBounds"] = self._prop.Background.Input:GetPropertyChangedSignal("TextBounds"):Connect(handleChangeOfLines)
        end

        self._maid["RenderSteppedFocused"] = RunService.RenderStepped:Connect(function()
            if self._properties["Disabled"] == true then
                return
            end

            if self._properties.maxChars ~= 0 then
                local okay = checkChars()

                if okay == false then
                    self._bindable:Fire("ChangeState", 3)
                end

                self._prop.Background.Outline.Enabled = not okay
                self._prop.Background.Outline.Color = Color3.fromRGB(255, 129, 129)
            end
        end)
    end))

    self._maid:GiveTask(self._prop.Background.Input.FocusLost:Connect(function()
        if self._properties["Disabled"] == true then
            return
        end
        local Text = checkChars() and self._prop.Background.Input.Text or nil

        local pastColor = self._prop.Background.Input.TextColor3
        self._prop.Background.Input.TextColor3 = contrastColor(pastColor)
        self._prop.Background.Input.PlaceholderColor3 = contrastColor(pastColor)

        if string.len(self._prop.Background.Input.Text) > 0 then
            self._callback(Text, self._prop, self)
        else
            self._prop.Background.Outline.Enabled = false
        end

        self._maid["RenderSteppedFocused"] = nil
        self._maid["TextBounds"] = nil
        self._bindable:Fire("ChangeState", 1)
    end))

    self._prop.Visible = true
end

function Element:ChangeProperty(Property, Value)
    self._bindable:Fire("PropertyChange", Property, Value)
end

createdSettings = {
    ["Disabled"] = false;
    ["ErrorCheck"] = false;
    ["errorStroke"] = 1;
    ["PlaceHolder"] = "";
}

function Element:UpdateProperties()
    for i,v in next, self._properties do
        if i == "Color" then
            local color = (typeof(v) == "table") and v or getColor(v)
            
            self._prop.Background.BackgroundColor3 = color.Bkgd
            self._prop.Title.TextColor3 = color.TextColor

            self._properties.Color = color;
        elseif i == "Parent" then
            self._prop.Parent = v
        elseif i == "ErrorCheck" then
            self._prop.Background.Outline.Enabled = v
        elseif i == "PlaceHolder" then
            self._prop.Background.Input.PlaceholderText = v
        elseif i == "errorStroke" then
            self._prop.Background.Outline.Thickness = v
        elseif i == "Disabled" then
            if v == true then
                local toAdd = 90
                self._prop.Background.BackgroundColor3 = contrastColor(self._properties.Color.Bkgd, toAdd)
                self._prop.Background.Input.TextColor3 = contrastColor(self._properties.Color.TextColor, toAdd)

                self._prop.Background.Input.ClearTextOnFocus = false
            elseif v == false then
                local color = self._properties.Color

                self._prop.Background.Input.ClearTextOnFocus = (self._properties.ClearTextOnFocus ~= nil) and self._properties.ClearTextOnFocus or true
                self._prop.Background.BackgroundColor3 = color.Bkgd
                self._prop.Title.TextColor3 = color.TextColor
            end

            self._properties.Disabled = v
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
    return nil
end

return {
    Element = Element;
    Deprecated = {false, nil};
    inBeta = false;
}