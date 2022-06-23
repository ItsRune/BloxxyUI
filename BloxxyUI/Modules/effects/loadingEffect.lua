--// Services \\--
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

--// Modules \\--
local Effect = require(script.Parent.Parent.formats.Effect)

return function(Obj)
    return Effect.new("Loading", function(self)
        local Prop = Obj._prop
        local Background = Prop.Background
        local Folder = Background.Effects

        local newLoadingEffect = Instance.new("Frame", Folder)
        newLoadingEffect.Name = "Loading"
        newLoadingEffect.Size = UDim2.new(1, 0, 1, 0)

        local gradientToTween = Instance.new("UIGradient", newLoadingEffect)
        gradientToTween.Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(1,1,1), Color3.new(0, 0, 0))
        gradientToTween.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(.5, .5),
            NumberSequenceKeypoint.new(1, 1)
        })

        local Tween = TweenService:Create(gradientToTween, TweenInfo.new(0.5), {
            Offset = Vector2.new(Obj._prop.AbsoluteSize.X * 1.5, 0)
        })

        Tween.Completed:Connect(function()
            self._tweening = false
            gradientToTween.Offset = Vector2.new(-Obj._prop.AbsoluteSize.X, 0)
        end)

        self._maid:GiveTask(RunService.RenderStepped:Connect(function()
            if self._state == 1 and self._tweening == false then
                self._tweening = true
                Tween:Play()
            end
        end))
    end)
end