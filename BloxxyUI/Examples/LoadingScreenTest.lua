-- Parent has to be a ScreenGui

local controller = require(game.ReplicatedStorage.BloxxyUI).new(script.Parent)
local Base, PlayButton;

Base, Element = controller:AddElement("BaseFrame", {
	Color = "Light";
	Size = UDim2.new(1, 0, 1, 0);
	IgnoreGuiInset = true;
	Components = {
		{
			Name = "Spinner";
			Properties = {
				Name = "Loader";
				Color = "Dark";
				AnchorPoint = Vector2.new(0, 1);
				Position = UDim2.new(0, 10, 1, -5);
				Size = UDim2.new(0, 60, 0, 60);
				FPS = 60;
			};
		};
		{
			Name = "Label";
			Properties = {
				Name = "LoadingText";
				Color = "Light";
				Text = "Loading...";
				Position = UDim2.new(0, 75, 1, -5);
				AnchorPoint = Vector2.new(0, 1);
				Size = UDim2.new(0, 200, 0, 60);
				BackgroundTransparency = 1;
				TextXAlignment = Enum.TextXAlignment.Left;
			};
		}
	};
	
	Callback = function(this)
		task.wait(5)
		PlayButton = controller:AddElement("Button", {
			Parent = this._prop;
			Position = UDim2.new(.5, 0, .5, 0);
			AnchorPoint = Vector2.new(.5, .5);
			Text = "Play";
			Color = "Alert";
			Size = UDim2.new(.15, 0, 0, 50);
			
			Callback = function(Player, Data)
				local Prop = Data[1]
				local Element = Data[2]
				
				task.wait(2)
				Base:Destroy()
			end,
		})
	end,
})