-- Parent has to be a ScreenGui

local controller = require(game.ReplicatedStorage.BloxxyUI).new(script.Parent)
local Base, PlayButton;

Base, Element = controller:AddElement("BaseFrame", {
	Color = "Light";
	Size = UDim2.new(1, 0, 1, 0);
	
	Components = {
		{
			Name = "Input";
			Properties = {
				Color = Color3.fromRGB(26, 26, 26);
				errorStroke = 4;
				Position = UDim2.new(.5, 0, .5, 0);
				AnchorPoint = Vector2.new(.5, .5);
				Size = UDim2.new(0, 200, 0, 50);
				CharacterCheck = {
					min = 2;
					max = 10;
				};
			};
			
			Callback = function(text, obj, this)
				local _, labelThis = controller:AddElement("Label", {
					Size = "auto";
					Text = (text) and text or string.format("Error, you weren't within the character limit of %s - %s", this._properties.CharacterCheck.min, this._properties.CharacterCheck.max);
					Color = "Dark";
					Position = obj.Position + UDim2.new(0, 0, 0, 75);
					AnchorPoint = obj.AnchorPoint;
				});
				
				this:ChangeProperty("Disabled", true)
				task.wait(5)
				labelThis:Destroy()
				this:ChangeProperty("Disabled", false)
			end,
		};
	};
})