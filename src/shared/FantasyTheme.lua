--!strict
-- Alnair / paleta autoral de fantasia artesanal e aventureira.
local Theme = {}
Theme.background = Color3.fromRGB(17, 27, 30)
Theme.shadow = Color3.fromRGB(15, 29, 31)
Theme.wood = Color3.fromRGB(79, 58, 42)
Theme.woodLight = Color3.fromRGB(110, 80, 50)
Theme.parchment = Color3.fromRGB(235, 211, 162)
Theme.cream = Color3.fromRGB(249, 238, 215)
Theme.muted = Color3.fromRGB(174, 176, 148)
Theme.gold = Color3.fromRGB(235, 193, 119)
Theme.goldDark = Color3.fromRGB(156, 105, 54)
Theme.leaf = Color3.fromRGB(110, 165, 94)
Theme.moss = Color3.fromRGB(49, 87, 72)
Theme.sky = Color3.fromRGB(134, 191, 202)
Theme.red = Color3.fromRGB(211, 91, 73)
Theme.blue = Color3.fromRGB(93, 169, 213)
Theme.purple = Color3.fromRGB(149, 121, 207)
Theme.white = Color3.fromRGB(248, 239, 220)
Theme.fontTitle = Enum.Font.Merriweather
Theme.fontText = Enum.Font.BuilderSans
Theme.fontBold = Enum.Font.BuilderSansBold

function Theme.corner(parent,radius)
    local r=Instance.new("UICorner")
    r.CornerRadius=UDim.new(0,radius or 8)
    r.Parent=parent
    return r
end
function Theme.stroke(parent,color,alpha,width)
    local s=Instance.new("UIStroke")
    s.Color=color or Theme.goldDark
    s.Thickness=width or 1
    s.Transparency=alpha or .3
    s.Parent=parent
    return s
end
function Theme.gradient(parent,colors,rotation)
    local g=Instance.new("UIGradient")
    local key={}
    for i,c in ipairs(colors) do
        table.insert(key,ColorSequenceKeypoint.new((i-1)/(#colors-1),c))
    end
    g.Color=ColorSequence.new(key)
    g.Rotation=rotation or 90
    g.Parent=parent
    return g
end
return Theme
