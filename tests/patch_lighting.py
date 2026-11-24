from pathlib import Path
p=Path(r"C:\Users\bartk\Desktop\Alnair\src\server\World.lua")
s=p.read_text("utf-8")
cfg={
"Lighting.ClockTime = 17.6":"Lighting.ClockTime = 15.1",
"Lighting.Brightness = 2.2":"Lighting.Brightness = 3",
"Lighting.Ambient = Color3.fromRGB(94,93,117)":"Lighting.Ambient = Color3.fromRGB(163,166,178)",
"Lighting.OutdoorAmbient = Color3.fromRGB(112,119,135)":"Lighting.OutdoorAmbient = Color3.fromRGB(180,184,196)",
"Lighting.FogColor = Color3.fromRGB(121,139,156)":"Lighting.FogColor = Color3.fromRGB(183,193,202)",
"Lighting.FogStart = 100":"Lighting.FogStart = 220",
"Lighting.FogEnd = 510":"Lighting.FogEnd = 770",
"atmosphere.Density = .29":"atmosphere.Density = .20",
"atmosphere.Haze = 1.7":"atmosphere.Haze = 1.0",
"atmosphere.Glare = .12":"atmosphere.Glare = .07",
"atmosphere.Color = Color3.fromRGB(195,190,209)":"atmosphere.Color = Color3.fromRGB(205,210,220)",
"atmosphere.Decay = Color3.fromRGB(77,103,133)":"atmosphere.Decay = Color3.fromRGB(126,146,169)",
"bloom.Intensity = .32":"bloom.Intensity = .18",
"color.Contrast = .11":"color.Contrast = .055",
"color.Saturation = -.08":"color.Saturation = .055",
"color.TintColor = Color3.fromRGB(222,225,245)":"color.TintColor = Color3.fromRGB(246,239,229)"
}
for old,new in cfg.items():
 if old not in s:raise RuntimeError(old)
 s=s.replace(old,new)
p.write_text(s,"utf-8",newline="\n")
print("LIGHTING UPDATED",len(cfg))
