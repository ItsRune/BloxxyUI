local Colors = {
    Primary = {
        Bkgd = Color3.fromRGB(0, 232, 126);
        TextColor = Color3.fromRGB(255, 255, 255);
        Outlined = false
    };
    Secondary = {
        Bkgd = Color3.fromRGB(255, 255, 255);
        TextColor = Color3.fromRGB(70, 70, 70);
        Outlined = false
    };
    Alert = {
        Bkgd = Color3.fromRGB(255, 91, 91);
        TextColor = Color3.fromRGB(255, 255, 255);
        Outlined = false
    };
    Outlined = {
        Bkgd = Color3.fromRGB(51, 51, 51);
        TextColor = Color3.fromRGB(255, 255, 255);
        Outlined = true;
    };
    Dark = {
        Bkgd = Color3.fromRGB(51, 51, 51);
        TextColor = Color3.fromRGB(255, 255, 255);
        Outlined = false;
    };
    Light = {
        Bkgd = Color3.fromRGB(255, 255, 255);
        TextColor = Color3.fromRGB(51, 51, 51);
        Outlined = false;
    };
    Link = {
        Bkgd = Color3.fromRGB(44, 44, 44);
        TextColor = Color3.fromRGB(69, 118, 255);
        Outlined = false
    };
}

local function getColor(clr)
    if typeof(clr) == "Color3" then
        return {
            Bkgd = clr;
            TextColor = (clr.R > 155 and clr.G > 155 and clr.B > 155) and Color3.new(0, 0, 0) or Color3.new(1, 1, 1);
            Outlined = false;
        }
    end

    local firstChar = string.sub(clr, 1, 1)
    local others = string.sub(clr, 2, string.len(clr))
    local color = string.upper(firstChar) .. string.lower(others)

    return Colors[color]
end

local function contrastColor(pastColor, toAddOrSubtract)
    if typeof(pastColor) ~= "Color3" then return pastColor end
    toAddOrSubtract = toAddOrSubtract or 100;

    if pastColor.R > 0 and pastColor.G > 0 and pastColor.B > 0 then
        return Color3.fromRGB(pastColor.R - toAddOrSubtract, pastColor.G - toAddOrSubtract, pastColor.B - toAddOrSubtract)
    else
        return Color3.fromRGB(pastColor.R + toAddOrSubtract, pastColor.G + toAddOrSubtract, pastColor.B + toAddOrSubtract)
    end
end

return {
    Func = getColor;
    Vals = Colors;
    SecondaryFunc = contrastColor;
}