local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BloxxyUI = require(ReplicatedStorage.BloxxyUI)

local Controller = BloxxyUI.new(script.Parent)
Controller:AddElement("Progress", {
    Color = "Alert";
    Size = UDim2.new(0, 100, 0, 100);
    Position = UDim2.new(.5, 0, .5, 0);
    AnchorPoint = Vector2.new(.5, .5);
    Value = 25;
    MaxValue = 100;

    Components = {
        {
            Name = "Label";
            Properties = {
                Size = "auto";
                Text = "Loading";
                Color = "Dark";
                Position = UDim2.new(.5, 0, .5, 0);
                AnchorPoint = Vector2.new(.5, .5);
            };
            Callback = function(value, obj, this)
                this:ChangeProperty("Text", string.format("Loading %s%%", math.floor(value * 100 / this._properties.MaxValue)))
            end,
        };
    };
}, function(self)
    warn(self)
end)