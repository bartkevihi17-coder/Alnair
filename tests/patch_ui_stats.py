from pathlib import Path
f=Path(r"C:\Users\bartk\Desktop\Alnair\src\client\GameplayUI.client.luau")
s=f.read_text("utf-8")
def p(old,new):
 global s
 if old not in s:raise Exception("Missing "+repr(old[:100]))
 s=s.replace(old,new,1);print("PATCHED",old[:55].replace("\n"," "))
p('''local gameplay=false''',
'''local gameplay=false
local showAttributes=function() end''')
p('''curve(xpFill,5)
local questPanel''',
'''curve(xpFill,5)
local attrButton=button(stats,"J  ATRIBUTOS",
    UDim2.fromScale(.67,.57),UDim2.fromScale(.28,.20),
    function() showAttributes() end)
attrButton.TextSize=10
local questPanel''')
p('''    rowInfo(scroll,"EQUIPADO","Arma: "..(equips.weapon or "--").."   |   Armadura: "..(equips.armor or "--"))''',
'''    rowInfo(scroll,"EQUIPADO","Arma: "..(equips.weapon or "--").."  |  Armadura: "..(equips.armor or "--").."  |  Botas: "..(equips.boots or "--"))''')
p('''(typ=="weapon" or typ=="armor") and "EQUIPAR"''',
'''(typ=="weapon" or typ=="armor" or typ=="boots") and "EQUIPAR"''')
p('''end
local function showShop()''',
'''end
showAttributes=function()
    local win=createModal("ATRIBUTOS  /  EVOLUCAO","attributes")
    if not profile then return end
    local info=profile.attributes or {}
    local vals=info.values or {}
    local available=info.available or 0
    local class=profile.class or "warrior"
    local race=profile.race or "human"
    label(win,"PONTOS DISPONIVEIS:  "..available.."   |   "..string.upper(race).."  /  "..string.upper(class),14,
        UDim2.fromScale(.045,.125),UDim2.fromScale(.90,.065),C.gold,Enum.Font.GothamBold)
    label(win,"ATAQUE "..math.floor(profile.attack or 0).."     DEFESA "..math.floor(profile.defense or 0)..
        "     •  GANHE "..Rules.ATTRIBUTE_POINTS_PER_LEVEL.." PONTOS POR NIVEL",12,
        UDim2.fromScale(.045,.19),UDim2.fromScale(.9,.052),C.mute)
    local sc=makeScroll(win)
    sc.Position=UDim2.fromScale(.043,.28)
    sc.Size=UDim2.fromScale(.914,.65)
    for _,key in ipairs(Rules.ATTRIBUTE_ORDER) do
        local spec=Rules.ATTRIBUTE_INFO[key]
        local value=math.floor(vals[key] or 0)
        rowInfo(sc,string.upper(spec.name).."   "..value.."  (+ "..tostring((info.allocated or {})[key] or 0).." investidos)",
            spec.description,available>0 and "MELHORAR" or nil,function()
                action:FireServer("allocateStat",key)
            end)
    end
end
local function showShop()''')
p('''    elseif kind=="dev" then showDeveloper() end''',
'''    elseif kind=="dev" then showDeveloper()
    elseif kind=="attributes" then showAttributes() end''')
p('''        if modalKind=="dev" and profile and profile.dev then
            showDeveloper()
        end
        refreshHUD()''',
'''        if modalKind=="dev" and profile and profile.dev then
            showDeveloper()
        elseif modalKind=="attributes" then
            showAttributes()
        elseif modalKind=="inventory" then
            showInventory()
        end
        refreshHUD()''')
p('''    if input.KeyCode==Enum.KeyCode.K then toggle("skills");return end''',
'''    if input.KeyCode==Enum.KeyCode.K then toggle("skills");return end
    if input.KeyCode==Enum.KeyCode.J then toggle("attributes");return end''')
f.write_text(s,"utf-8",newline="\n")
print("UI UPDATED",len(s))
