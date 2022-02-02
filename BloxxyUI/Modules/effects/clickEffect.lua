--// Services \\--
local TweenService = game:GetService("TweenService")

--// Modules \\--
local Effect = require(script.Parent.Parent.formats.Effect)

--// Variables \\--
local tweenClick = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)

return function(Obj)
    return Effect.new("circleClick", function(self)
        self:ChangeState(1)

        local Background = Obj._prop.Background
        local Folder = Background.Effects
        local Mouse = Obj._mouse
        local newClickEffect = Instance.new("ImageLabel", Folder)
        local IMAGE_COLOR = (Background.BackgroundColor3 == Color3.fromRGB(255,255,255)) and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(255, 255, 255)
        
        newClickEffect.Name = "Click"
        newClickEffect.ScaleType = Enum.ScaleType.Fit
        newClickEffect.Size = UDim2.new(0, 0, 0, 0)
        newClickEffect.Image = "rbxassetid://660373145"
        newClickEffect.ImageColor3 = IMAGE_COLOR
        newClickEffect.BorderSizePixel = 0
        newClickEffect.BackgroundTransparency = 1
        newClickEffect.ImageTransparency = .5
        newClickEffect.AnchorPoint = Vector2.new(0.5, 0.5)
        newClickEffect.Position = UDim2.fromOffset(Mouse.X - Background.AbsolutePosition.X, Mouse.Y - Background.AbsolutePosition.Y)
    
        task.spawn(function()
            self:ChangeState(1)
            local Tween = TweenService:Create(newClickEffect, tweenClick, {
                Size = UDim2.new(1.5, 0, 1.5, 0);
                ImageTransparency = 1;
            });
            Tween.Completed:Connect(function()
                self:Destroy()
                newClickEffect:Destroy()
            end)
            Tween:Play()
        end)
    end)
end